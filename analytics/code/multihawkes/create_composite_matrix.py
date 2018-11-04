'''
File: create_composite_matrix.py
Author: Adam Pah
Description: 
Creates the composite network matrix
'''

#Standard path imports
from __future__ import division, print_function
import argparse
import glob
import json
import seaborn as sns
import numpy as np
from collections import OrderedDict
import networkx as nx
from networkx.readwrite import json_graph

#Non-standard imports

#Global directories and variables

def main(args):
    '''
    Creates averaged matrices
    '''
    outputs = {'Colombia': {}, 'Afghanistan': {}, 'Iraq': {}}
    for country in outputs.keys():
        for viter in range(9):
            try:
                jstr = open('../../results/multihawkes/tol_burn_runs001/v%d/%s_multihawkes_500burn_5thin.json' % \
                                        (viter + 1, country)).read()
                jload = json.loads(jstr, object_pairs_hook=OrderedDict)
                outputs[country][viter] = jload
            except FileNotFoundError:
                pass
    lambda_set = {}
    matrices = {'Colombia': [], 'Afghanistan': [], 'Iraq': []}
    for country in outputs.keys():
        for vnum in outputs[country]:
            num_groups = len(outputs[country][vnum])
            group_names = outputs[country][vnum].keys()
            temp_mat = np.zeros((num_groups, num_groups))
            for gi, gname  in enumerate(group_names):
                temp_mat[gi] = outputs[country][vnum][gname]['W']
                if gname not in lambda_set:
                    lambda_set[gname] = []
                lambda_set[gname].append(outputs[country][vnum][gname]['lambda'])
            matrices[country].append(temp_mat)
        #Create the averaged matrix and save it
        amat = np.mean(np.array(matrices[country]), axis=0)
        G = nx.from_numpy_matrix(amat)
        np.savetxt('../../results/multihawkes/tol_burn_runs001/%s_composite.csv' % country, amat, delimiter=",")
        with open('../../results/multihawkes/tol_burn_runs001/%s_groupnames.txt' % country, 'w') as wfile:
            for gname in group_names:
                print(gname, file=wfile)
        #And then save the network
        H = nx.relabel_nodes(G, dict(enumerate(group_names)))
        nx.write_weighted_edgelist(H, '../../results/multihawkes/tol_burn_runs001/%s_wnet.csv' % country, delimiter=',')
        jstr = json_graph.node_link_data(H)
        with open('../../results/multihawkes/tol_burn_runs001/%s_net.json' % country, 'w') as wfile:
            print(jstr, file=wfile)
        with open('../../results/multihawkes/tol_burn_runs001/group_lambdas.csv', 'w') as wfile:
            print('group,lambda', file=wfile)
            for g, lset in lambda_set.items():
                print('%s,%f' % (g, np.mean(lset)), file=wfile  )

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="")
    args = parser.parse_args()
    main(args)
