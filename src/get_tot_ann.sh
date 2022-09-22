#!/bin/bash

##----------------------------------------------------
## converting variable in kg C m-2 s-1 to annual totals in kg C m-2 yr-1
##----------------------------------------------------
## Arguments:
## 1. File name
## 2. Directory path; for example: dir="/cluster/home/bestocke/data/trendy/v8/"

## get annual mean
cdo -O yearmean ${2}${1}.nc ${2}/processed/${1}_ANN_SEC.nc

## multiply with seconds per year to get annual total
cdo -O mulc,31536000 ${2}/processed/${1}_ANN_SEC.nc ${2}/processed/${1}_ANN.nc
