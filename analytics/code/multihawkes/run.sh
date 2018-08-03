#!/bin/bash
nohup python multihawkes.py ../../data/Iraq_abm_events.csv r1000/ --breakearly >iraq.out &
nohup python multihawkes.py ../../data/Afghanistan_abm_events.csv r1000/ --breakearly > afg.out &
nohup python multihawkes.py ../../data/Colombia_abm_events.csv r1000/ --breakearly > col.out &
