'''
File: parameter_average_calculators.py
Author: Adam Pah
Description: 
Pulls out the average paramter values across runs
'''

#Standard path imports
from __future__ import division, print_function
import argparse
import glob

#Non-standard imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#Global directories and variables

param_names = ['mu', 'alpha', 'beta']

def param_averager(dfset):
    result = {}
    dpoints = {}
    for param in dfset[0].index:
        result[param] = np.average([df.loc[param][' Mean'] for df in dfset])
        dpoints[param] = [df.loc[param][' Mean'] for df in dfset]
    return result, dpoints

def row_creator(param_average, param_names):
    rowline = []
    for param in param_names:
        if param in param_average:
            rowline.append( param_average[param] )
        else:
            rowline.append( np.nan )
    return rowline


def main(filedir):
    rdf = pd.DataFrame(columns=param_names)
    #Iterate through the files
    pd_line = 0
    dfset = [pd.read_csv(infile, index_col = 0) for infile in glob.glob(filedir + '*params*csv')]
    param_averages, dpoints = param_averager(dfset)
    param_line = row_creator(param_averages, param_names)
    #Add the line
    rdf.loc[pd_line] = param_line
    #Save it out
    rdf.to_csv(filedir + 'averaged_parameters.csv')
    print(rdf)
    #Do the parameter plots as a data plot
    fig = plt.figure()
    ax = fig.add_subplot(111)
    axis_labels = []
    for i, (param_name, param_values) in enumerate(dpoints.items()):
        axis_labels.append(param_name)
        ax.plot([i for xi in range(len(param_values))], param_values, 'o')
    ax.set_xticks([0, 1, 2])
    ax.set_xticklabels(axis_labels)
    ax.set_xlim(-0.75, 2.75)
    plt.tight_layout()
    plt.savefig(filedir + 'run_parameters.eps')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('filedir', action='store')
    args = parser.parse_args()
    main(args.filedir)
