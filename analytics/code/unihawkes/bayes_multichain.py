import argparse
import pymc as pm
import pandas
import sys
import math
import os
import random
import numpy as np
sys.path.append('..')
from support import loaders

def name_cleaner(iname):
    '''
    Cleans a groups name to make it usable for the folder name
    '''
    import string
    return ''.join([x for x in iname if x not in string.punctuation and x!=' '])

def param_selector(data):
    #Parameters for the hawkes process
    #Take the number events/ divided by the number of days
    mu = pm.Exponential('mu', len(data)/data[-1] + (random.choice([0,1]) * 0.01 * random.random()) )
    #Alpha is the coefficient for creation - should be an exponential since it's increasingly less likely to be large
    alpha = pm.Exponential('alpha', len(data)/data[-1] + (random.choice([0,1]) * 0.01 * random.random()) )
    #We are sure that the impact of one event, if it has one, decreases over time so beta must be positive
    beta = pm.Exponential('beta', 1)
    return mu, alpha, beta

def srf_checker(srf, tol=0.000001):
    srfpass = None
    for val in srf.values():
        if 1 - tol < val and val < 1+tol:
            srfpass = False
    if srfpass == None:
        srfpass = True
    return srfpass

def bayes_model(data, savedir, num_jobs = 1):
    mu, alpha, beta = param_selector(data)

    @pm.stochastic(observed=True)
    def custom_stochastic(value = data, mu = mu, alpha = alpha, beta = beta):
        r = np.zeros( len(value) )
        for i in range(1, len(value) ):
            r[i] = math.exp(-beta*(value[i]-value[i-1]))*(1+r[i-1])
        #Calculate the loglikelihood
        loglik  = -value[-1] * mu
        loglik = loglik + alpha/beta * sum( np.exp(-beta*(value[-1]-value)) - 1)
        loglik = loglik + np.sum( np.log(mu + alpha*r))
        return loglik

    model = pm.MCMC([mu, alpha, beta, custom_stochastic])

    srfpass = False
    while srfpass == False:
        for i in range(num_jobs):
            model.sample(300000, 60000, 7)
            model.write_csv('{0}full_params{1}.csv'.format(savedir, i) )
        srfpass = srf_checker(pm.gelman_rubin(model))
    with open('{0}srf.csv'.format(savedir), 'w') as wfile:
        print('Parameter,SRF', file = wfile)
        srfdict = pm.gelman_rubin(model)
        for k,v in srfdict.items():
            print('{0},{1}'.format(k,v), file=wfile)

def event_series_constructor(tdf):
    series = tdf.date.diff()[1:] / np.timedelta64(1, '[D]')
    try: 
        taus = series.tolist()
    except AttributeError:
        taus = series
    #Create the event list
    events = [0]
    for i,t in enumerate(taus):
        events.append(events[i] + t)
    data = np.array(events)
    return data

def main(args):
    #Make the base folder
    os.system('mkdir {0}'.format(args.savedir))
    #Load the data
    df = loaders.load_country_data(args.datafile, start = args.start_year, end = args.end_year)
    #Group it into individual groups
    name_trans = []
    gdf = df.groupby('gname')
    for gname, groupdf in gdf:
        #Check the threshold
        if len(groupdf) >= args.threshold:
            #clean the name
            name_trans.append( [gname, name_cleaner(gname)] )
            #Convert to the inter-event times
            data = event_series_constructor(groupdf)
            #Now make the grougname directory
            gdir = args.savedir + '/' + name_trans[-1][1] + '/'
            os.system('mkdir {0}'.format(gdir))
            #Run the model
            bayes_model(data, gdir, num_jobs = args.num_rep)
    transdf = pd.DataFrame(name_trans, columns = ['gname', 'dirname'])
    transdf.to_csv(args.savedir + 'trans.csv', index=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('datafile', action='store', help='Country csv datafile')
    parser.add_argument('savedir', default = 'runs/', action='store')
    parser.add_argument('--num_rep', default = 10, action = 'store', type = int)
    parser.add_argument('--start_year', default=2001, action='store', type=int)
    parser.add_argument('--end_year', default=2005, action='store', type=int)
    parser.add_argument('--threshold', default=10, action='store', type=int)
    args = parser.parse_args()
    main(args)
