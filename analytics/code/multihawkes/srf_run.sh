#!/bin/bash
nohup python multihawkes_srf.py ../../data/Iraq_abm_events.csv hawkes_srf/  >iraq.out &
nohup python multihawkes_srf.py ../../data/Afghanistan_abm_events.csv hawkes_srf/  > afg.out &
nohup python multihawkes_srf.py ../../data/Colombia_abm_events.csv hawkes_srf/  > col.out &
