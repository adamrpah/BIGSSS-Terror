#!/bin/bash
nohup python multihawkes.py ../../data/Iraq_abm_events.csv ../../results/multihawkes/tol_runs000001/  >iraq.out &
sleep 2
nohup python multihawkes.py ../../data/Afghanistan_abm_events.csv ../../results/multihawkes/tol_runs000001/  > afg.out &
sleep 2
nohup python multihawkes.py ../../data/Colombia_abm_events.csv ../../results/multihawkes/tol_runs000001/  > col.out &
sleep 2
