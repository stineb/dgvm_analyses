#!/bin/bash

##----------------------------------------------------
## Getting annual maximum of monthly values
##----------------------------------------------------
## Arguments:
## 1. File name
## 2. directory path of input file
## 3. directory path of output file

## sum monthly to annual
cdo -O yearsum ${3}/${1}.nc ${3}/${1}_ANN.nc

## select box
cdo -O sellonlatbox,-72,-51,-12,4.5 ${3}/${1}_ANN.nc ${3}/${1}_ANN_AMAZON.nc

## mean across all grids (area-weighted?)
cdo -O fldmean ${3}/${1}_ANN_AMAZON.nc ${3}/${1}_ANN_AMAZON_MEAN.nc