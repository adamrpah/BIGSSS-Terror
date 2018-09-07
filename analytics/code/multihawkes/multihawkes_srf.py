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

def calcB(tstats, gnames, n):
    '''
    Calculates the between chain variance
    calc B is n/m-1*sum(variance_chain_i - avg_varaicne_chains)
    returns it for each variable

    Need to do this for each group
    '''
    resultB = {}
    #Iterate through each group
    for gname in gnames:
        #Average variance across the chains 
        avgVar = np.mean( [tstats[ichain][gname]['std']**2 for ichain in range(n) ] )
        #B calculation
        B = n/(n-1) * sum( [(tstats[ichain][gname]['std'] - avgVar)**2 for ichain in range(n)] )
        #Store it
        resultB[gname] = B
    return resultB

def calcW(tstats, gnames, n):
    '''
    Calculates the within chain variance
    1/(m) sum( variance_i )^2
    returns it for each variable
    '''
    resultW = {}
    #Iterate thorugh each group
    for gname in gnames:
        #Sum the chain variances
        sumVariances = sum( [tstats[ichain][gname]['std']**2 for ichain in range(n)] ) 
        #Caluclate w and store it
        W = sumVariances / n
        resultW[gname] = W
    return resultW

def calcVar(W, B, n):
    resultVar = {}
    #iterate through the groups
    for gname in W.keys():
        Var = (1 - 1/n)*W[gname] + 1/n * B[gname]
        resultVar[gname] = Var
    return resultVar

def calcR(Var, W):
    resultR = {}
    for gname in W.keys():
        R = np.sqrt(Var[gname]/W[gname])
        resultR[gname] = R
    return resultR

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
    #Parameter setting
    K = len(date_ordinals.columns)
    dt_max = len(date_ordinals)
    p=0.25
    network_hypers = {"p": p, "allow_self_connections": True}
    #set-up the model
    hawkes_model = DiscreteTimeNetworkHawkesModelSpikeAndSlab(K=K, dt_max=dt_max, network_hypers=network_hypers) 
    hawkes_model.add_data( np.array(date_ordinals.values.tolist()) )
    #Set-up the runs
    srfpass = False
    loopcount = 0
    #set-up the model
    hawkes_models = {}
    for ichain in range(args.num_chains):
        hawkes_models[ichain] = DiscreteTimeNetworkHawkesModelSpikeAndSlab(K=K, dt_max=dt_max, network_hypers=network_hypers) 
        hawkes_models[ichain].add_data( np.array(date_ordinals.values.tolist()) )
    #hold variables
    parameter_trace = {ichain:{g:[] for g in gnames} for ichain in range(args.num_chains)}
    trace_stats = {ichain:{g:{'mean':0, 'std':0} for g in gnames} for ichain in range(args.num_chains)}
    while srfpass == False:
        #resample all chains
        for ichain in range(args.num_chains):
            hawkes_models[ichain].resample_model()
            #Record the parameters
            for i,group in enumerate(gnames):
                parameter_trace[ichain][group].append(hawkes_model.lambda0[i])
                #Calculate the stats
                trace_stats[ichain][group]['mean'] = np.mean(parameter_trace[ichain][group][args.burn::args.thin])
                trace_stats[ichain][group]['std'] = np.std(parameter_trace[ichain][group][args.burn::args.thin])
        #increment
        print(loopcount)
        loopcount += 1
        #Start checking
        if loopcount > 1000 and loopcount % args.thin == 0:
            #Calculate out the parts
            B = calcB(trace_stats, gnames, args.num_chains)
            W = calcW(trace_stats, gnames, args.num_chains)
            VarSig = calcVar(W, B, args.num_chains)
            R = calcR(VarSig, W)
            #SRF pass check
            srf_pass_set = []
            for param, srf_val in R.items():
                if abs(srf_val-1.0) < args.tol:
                    srf_pass_set.append(1)
            if np.mean(srf_pass_set) == 1:
                srfpass = True
    #Write out the SRFs
    with open('%s/%s_srf.csv' % (args.savedir, country), 'w') as wfile:
        print('group,B,W,V,R', file = wfile)
        for gname in B.keys():
            print('%s,%f,%f,%f,%f' % (gname, B[gname], W[gname], VarSig[gname], R[gname]), file=wfile)
    #Pull the data
    dataset = {}
    header = ['gname', 'A', 'B', 'W_effective', 'lambda0']
    for i, group in enumerate(gnames):
        dataset[group] = {
            'B': float(hawkes_model.B),
            'W': hawkes_model.W_effective[i].tolist(),
            'lambda': float(hawkes_model.lambda0[i])
        }
    json.dump(dataset, open('%s/%s_multihawkes.json' % (args.savedir, country), 'w'), indent=4)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('datafile', action='store', help='Country csv datafile')
    parser.add_argument('savedir', action='store')
    parser.add_argument('--start_year', default=2001, action='store', type=int)
    parser.add_argument('--end_year', default=2005, action='store', type=int)
    parser.add_argument('--threshold', default=1, action='store', type=int)
    parser.add_argument('--num_chains', default = 8, action='store', type=int)
    parser.add_argument('--burn', default = 500, action='store', type=int)
    parser.add_argument('--thin', default = 5, action='store', type=int)
    parser.add_argument('--tol', default = 0.0001, action='store', type=int)
    args = parser.parse_args()
    main(args)
    
