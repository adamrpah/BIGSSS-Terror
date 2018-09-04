'''
File: pull_abm_data.py
Author: Adam Pah
Description: 
Condenses the abm data
'''

#Standard path imports
from __future__ import division, print_function
import argparse
import glob

#Non-standard imports
import pandas as pd
import numpy as np
from scipy.stats import ks_2samp, binom_test

#Global directories and variables
max_file_count = 210
alphas = [0.05, 0.1, 0.15, 0.2, 0.3, 0.5, 0.7, 0.9]
betas = [4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8]
omegas = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

def main(args):
    wfile =  open('../../results/%s_pvalue_analysis_v2_direct.csv' % fdir, 'w')
    print('country,alpha,beta,omega,pvalue', file = wfile)

    for country in ['Afghanistan', 'Colombia', 'Iraq']:
        print(country)
        #Load the Empirical data
        empirical_data = {}
        df = pd.read_csv('../../data/%s_abm_events.csv' % country)
        for group in df.gname.unique():
            #I'm going to cut out groups who have less than 10 attacks
            interevent = df[df.gname == group].idate.diff()[1:].values.tolist()
            if len(intervent) >= args.threshold - 1:
                empirical_data[group] = df[df.gname == group].idate.diff()[1:].values.tolist()
        #ROll through the alphas
        for alpha in alphas:
            for beta in betas:
                print(alpha,beta)
                for omega in omegas:
                    group_pvalues = {g:[] for g in empirical_data.keys() if len(empirical_data[g])>1}
                    #Read through all the parameter files
                    flist = glob.glob('../../results/%s/%s_%s_%s_%s_*.csv' % (fdir, country, str(alpha), str(beta), str(omega)))
                    if len(flist) > 0:
                        for parameter_file in flist:
                            #Run dataframe is 
                            run_df = pd.read_csv(parameter_file, header=None, names=['group', 'tick', 'attack'])
                            run_groups = run_df.group.unique().tolist()
                            grouprun = run_df.groupby('group')
                            for group, gdf in grouprun.groupby('group'):
                                if group in group_pvalues:
                                    timeset = []
                                    for tick, attack in gdf.loc[:, ['tick', 'attack']].values:
                                        for i in range(attack):
                                            timeset.append(tick)
                                    sim_interevent = np.diff(timeset)
                                    D, p = ks_2samp(sim_interevent, empirical_data[group])
                                    group_pvalues[group].append(p)
                        #Do the pass fail
                        pass_groups, fail_groups = 0, 0
                        for group, pval_list in group_pvalues.items():
                            fail_percentage = len([p for p in pval_list if p <0.05]) / max_file_count
                            if fail_percentage >0.05:
                                fail_groups += 1
                            else:
                                pass_groups += 1
                        #Run the binomial test
                        p = binom_test(pass_groups, pass_groups + fail_groups)
                        #keep it
                        print('%s,%.1f,%.1f,%.1f,%f' % (country, alpha, beta, omega, p), file = wfile)
                    else:
                        print('%s,%.1f,%.1f,%.1f,%f' % (country, alpha, beta, omega, 0), file = wfile)
                            

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('fdir', action='store', help='directory where abm files are stored')
    parser.add_argument('--threshold', action='store', help='groups to exclude')
    args = parser.parse_args()
    main(args)
