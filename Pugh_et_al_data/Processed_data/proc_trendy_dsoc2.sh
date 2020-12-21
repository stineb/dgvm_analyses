#!/bin/bash
##----------------------------------------------------
## Initial and final mean over 10 years
##----------------------------------------------------
## Arguments:
## 1. File name
## 2. Directory path
# For example: dir="/cluster/home/bestocke/data/trendy/v8/"
## select years
rm ${2}/processednew/${1}_t1.nc
rm ${2}/processednew/${1}_t2.nc
cdo -O selyear,2005 ${2}/${1}.nc ${2}/processednew/${1}_t1.nc
cdo -O selyear,2014 ${2}/${1}.nc ${2}/processednew/${1}_t2.nc
## get change in soil C
rm ${2}/processednew/${1}_CHANGE.nc
cdo -O sub ${2}/processednew/${1}_t2.nc ${2}/processednew/${1}_t1.nc ${2}/processednew/${1}_CHANGE.nc
