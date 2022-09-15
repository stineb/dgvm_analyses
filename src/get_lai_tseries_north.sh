#!/bin/bash

##----------------------------------------------------
## Getting annual maximum of monthly values
##----------------------------------------------------
## Arguments:
## 1. File name
## 2. directory path of input file
## 3. directory path of output file

## create all output subdirectories
mkdir -p ${3}/ANN_MAX
mkdir -p ${3}/ANN_MAX_NORTH
mkdir -p ${3}/ANN_MAX_NORTH_MEAN

## get annual max
cdo -O yearmax ${2}${1}.nc ${3}/ANN_MAX/${1}_ANN_MAX.nc

## select latitudinal band
cdo -O sellonlatbox,-180,180,65,90 ${3}/ANN_MAX/${1}_ANN_MAX.nc ${3}/ANN_MAX_NORTH/${1}_ANN_MAX_NORTH.nc

## mean across all grids (area-weighted?)
cdo -O fldmean ${3}/ANN_MAX_NORTH/${1}_ANN_MAX_NORTH.nc ${3}/ANN_MAX_NORTH_MEAN/${1}_ANN_MAX_NORTH_MEAN.nc