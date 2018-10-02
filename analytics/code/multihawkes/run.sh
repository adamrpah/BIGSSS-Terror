#!/bin/bash
i=$1
nohup python multihawkes.py ../../data/Iraq_abm_events.csv ../../results/multihawkes/tol_runs0001/v$i/  >iraq$i.out &
#nohup python multihawkes.py ../../data/Afghanistan_abm_events.csv ../../results/multihawkes/tol_runs0001/v$i/  > afg$i.out &
#nohup python multihawkes.py ../../data/Colombia_abm_events.csv ../../results/multihawkes/tol_runs0001/v$i/  > col$i.out &
sleep 5
