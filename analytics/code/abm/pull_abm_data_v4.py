'''
Runs all groups/matches and reduces to a single country
'''
import pandas as pd
from scipy import stats

countries = ['Afghanistan', 'Colombia', 'Iraq']
trans = {
         'Hizb-I-Islami': 'Hizb-I-Islami', 
         'Taliban': 'Taliban',
         'Al-Qaeda': 'Al-Qa`ida', 
         'Revolutionary Armed Forces of Colombia (FARC)': 'Revolutionary Armed Forces of Colombia (FARC)', 
         'United Self Defense Units of Colombia (AUC)': 'United Self Defense Units of Colombia (AUC)', 
         'National Liberation Army of Colombia (ELN)': 'National Liberation Army of Colombia (ELN)', 
         "People's Revolutionary Army (ERP)": "People's Revolutionary Army (ERP)", 
         'AQI':'Al-Qa`ida in Iraq',  
         'Ansar al-Islam': 'Ansar al-Islam',
         'Ansar al-Sunna': 'Ansar al-Sunna'
         }


#results file
wfile = open('temp_v4.csv', 'w')
print('run,alpha,beta,omega,country,pfrac', file=wfile)
#Grab the header
header = open('../../results/abm_runs_v3/header.csv').read().strip().split(',')
#Go through each country
for country in countries:
    #Load the empirical dataj
    empdf = pd.read_csv('../../data/%s_abm_events.csv' % country)
    empirical_data = {}
    for group in empdf.gname.unique():
        #I'm going to cut out groups who have less than 5 attacks
        interevent = empdf[empdf.gname == group].idate.diff()[1:].values.tolist()
        if len(interevent) >= 5:
            empirical_data[group] = empdf[empdf.gname == group].idate.diff()[1:].values.tolist()
    #Load the abm data
    abmdf = pd.read_csv('../../results/abm_runs_v3/%s_20181009.csv' % country, header=None,
                         names = header)
    #extract the params
    alpha = abmdf.alpha.unique()
    beta = abmdf.beta.unique()
    omega = abmdf.omega.unique()
    groups = abmdf.group.unique()
    #Group it up
    lvl_one_gdf = abmdf.groupby(['alpha', 'beta', 'omega'])
    for a in alpha:
        for b in beta:
            for o in omega:
                #Create the rundata
                rundata = []
                #Pull the level two groups together by run
                lvl_two_gdf = lvl_one_gdf.get_group((a, b, o)).groupby('run')
                for r in lvl_two_gdf.groups.keys():
                    tdf = lvl_two_gdf.get_group(r)
                    for group in tdf.group.unique():
                        if group in trans.keys() and trans[group] in empirical_data:
                            diffset = tdf[tdf.group==group].step.diff()[1:].tolist()
                            D, p = stats.ks_2samp(empirical_data[trans[group]], diffset)
                            rundata.append(p)
                #Now write it out
                print('%d,%f,%f,%f,%s,%f' % (r, float(a), float(b), float(o), country, len([x for x in rundata if x<0.05])/len(rundata)), file=wfile)
