import pandas as pd
import numpy as np
import glob
from scipy.stats import ks_2samp, binom_test

#runv2
max_file_count = 210
alphas = [0.05 0.1 0.15 0.2 0.3 0.5 0.7 0.9]
betas = [4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8]
omegas = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 1]

#Original
#max_file_count = 1000
#alphas = np.arange(0.5, 1.4, 0.1)
#betas = np.arange(5, 10.5, 0.5)
#omegas = [0, 0.1, 1]

#Testing
#alphas = [0.5]
#betas = [5.5]
#omegas=[0.1]


record = []

for country in ['Afghanistan', 'Colombia', 'Iraq']:
    print(country)
    empirical_data = {}
    df = pd.read_csv('../../data/%s_abm_events.csv' % country)
    for group in df.gname.unique():
        empirical_data[group] = df[df.gname == group].idate.diff()[1:].values.tolist()
    for alpha in alphas:
        for beta in betas:
            print(alpha,beta)
            for omega in omegas:
                group_pvalues = {g:[] for g in empirical_data.keys() if len(empirical_data[g])>1}
                #Read through all the parameter files
                flist = glob.glob('../../results/abm_runs_v2/%s_%s_%s_%s_*.csv' % (country, str(alpha), str(beta), str(omega)))
                if len(flist) > 0:
                    for parameter_file in flist:
                        #Run dataframe is 
                        run_df = pd.read_csv(parameter_file, header=None, names=['group', 'tick', 'attack'])
                        for group, gdf in run_df.groupby('group'):
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
                    record.append([country, alpha, beta, omega, p])
#create the dataframe and write it
with open('../../results/abm_pvalue_analysis_v2.csv', 'w') as wfile:
    print('country,alpha,beta,omega,pvalue', file = wfile)
    for d in record:
        print('%s,%.1f,%.1f,%.1f,%f' % (d[0], d[1], d[2], d[3], d[4]), file=wfile )
                        
