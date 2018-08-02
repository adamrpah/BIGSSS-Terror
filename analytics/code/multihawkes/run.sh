#!/bin/bash
nohup python multihawkes.py ../../data/Iraq_abm_events.csv ../../results/multihawkes/abmr10000/ >iraq3.out &
nohup python multihawkes.py ../../data/Afghanistan_abm_events.csv ../../results/multihawkes/abmr10000/ > afg3.out &
nohup python multihawkes.py ../../data/Colombia_abm_events.csv ../../results/multihawkes/abmr10000/ > col3.out &
