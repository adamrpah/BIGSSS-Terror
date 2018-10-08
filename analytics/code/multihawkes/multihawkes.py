'''
File: multihawkes.py
Author: Adam Pah
Description: 
Runs the networked hawkes simulation
'''

#Standard path imports
from __future__ import division, print_function
import argparse
import sys
import os
import json

#Non-standard imports
import pandas as pd
from pyhawkes.models import DiscreteTimeNetworkHawkesModelSpikeAndSlab
import numpy as np
import pyhawkes
import matplotlib.pyplot as plt

sys.path.append('..')
from support import loaders

#Global directories and variables

def tol_checker(ptraces, tol=0.000001):
    tolpass = None
    tolcheck = []
    for trace in ptraces.values():
        mean_trace = np.mean(trace[-500:])
        if np.mean([(trace_value-mean_trace)/mean_trace for trace_value in trace[-100:]]) < tol:
            tolcheck.append(1)
        else:
            tolcheck.append(0)
    if np.mean(tolcheck) == 1:
        tolpass=True
    else:
        tolpass=False
    return tolpass

def main(args):
    try:
        os.system('mkdir {0}'.format(args.savedir))
    except:
        pass
    #Get teh country
    country = args.datafile.split('/')[-1].split('_')[0]
    #Load the data
    df = loaders.load_country_data(args.datafile, index_col=False)
    #Stitch the data together on a real number range
    date_ordinals = pd.DataFrame(pd.date_range('2001-01-01', '2005-12-31').values, columns=['date'])
    #Convert each group to the date range
    print('generate the groups to the dates')
    gnames = []
    date_grouped = df.groupby(['gname', 'date']).agg({'eventid': 'count'}).reset_index()
    for group, groupdf in date_grouped.groupby('gname'):
        gnames.append(group)
        #Set the new columns
        rgdf = groupdf.rename(columns={'eventid':group})
        #merge it
        date_ordinals = date_ordinals.merge( rgdf.loc[:,['date', group]], how='left')
    #Now we have a merged date_ordinals, so write it out
    date_ordinals.to_csv('../../data/%s_multihawkes_data.csv' % country)
    #read it back in
    date_ordinals = pd.read_csv('../../data/%s_multihawkes_data.csv' % country, index_col=0)
    date_ordinals.fillna(0, inplace=True)
    #Set the index on 'date' since we don't care about it
    date_ordinals.set_index('date', inplace=True)
    date_ordinals = date_ordinals.applymap(int)
    #Multiple runs
    for i in range(args.runs):
        newdir = args.savedir + 'v' + str(i+1)
        try:
            os.system('mkdir {0}'.format(newdir))
        except:
            pass
        #Parameter setting
        K = len(date_ordinals.columns)
        dt_max = len(date_ordinals)
        p=0.25
        network_hypers = {"p": p, "allow_self_connections": True}
        #set-up the model
        hawkes_model = DiscreteTimeNetworkHawkesModelSpikeAndSlab(K=K, dt_max=dt_max, network_hypers=network_hypers) 
        hawkes_model.add_data( np.array(date_ordinals.values.tolist()) )
        #Set-up the runs
        tolpass = False
        loopcount = 0
        lps_runs = list( range(0, 100, 10) )
        parameter_trace = {g:[] for g in gnames}
        while tolpass == False:
            hawkes_model.resample_model()
            #record the log probability
            lps_runs.append(hawkes_model.log_probability())
            #Record the parameters
            for i,group in enumerate(gnames):
                parameter_trace[group].append(hawkes_model.lambda0[i])
            #increment
            print(loopcount)
            loopcount += 1
            #Start checking
            if loopcount > 1000:
                tolpass = tol_checker(parameter_trace)
            #break early
            if loopcount>1000 and args.breakearly == True:
                break
        #Pull the data
        dataset = {}
        header = ['gname', 'A', 'B', 'W_effective', 'lambda0']
        for i, group in enumerate(gnames):
            dataset[group] = {
                'B': float(hawkes_model.B),
                'W': hawkes_model.W_effective[i].tolist(),
                'lambda': float(hawkes_model.lambda0[i])
            }
        json.dump(dataset, open('%s/%s_multihawkes.json' % (newdir, country), 'w'), indent=4)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('datafile', action='store', help='Country csv datafile')
    parser.add_argument('savedir', action='store')
    parser.add_argument('--runs', action='store', type=int, default=10)
    parser.add_argument('--breakearly', action='store_true', default=False, help='Break at 1000 runs')
    parser.add_argument('--start_year', default=2001, action='store', type=int)
    parser.add_argument('--end_year', default=2005, action='store', type=int)
    parser.add_argument('--threshold', default=1, action='store', type=int)
    args = parser.parse_args()
    main(args)
    
