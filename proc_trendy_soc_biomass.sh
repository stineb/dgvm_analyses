#!/bin/bash

##----------------------------------------------------
## Initial and final mean over 10 years
##----------------------------------------------------
## Arguments:
## 1. File name

## 2. Directory path
# For example: dir="/cluster/home/bestocke/data/trendy/v8/"

## select years at simulation start
cdo -O selyear,1701/1710 ${2}${1}.nc ${2}/processed/${1}_INIT.nc

## take mean across years at simulation start
rm ${2}/processed/${1}_INIT_MEAN.nc
cdo -O timmean ${2}/processed/${1}_INIT.nc ${2}/processed/${1}_INIT_MEAN.nc

## select years at simulation end
cdo -O selyear,2009/2018 ${2}${1}.nc ${2}/processed/${1}_FINAL.nc

## take mean across years at simulation end
rm ${2}/processed/${1}_FINAL_MEAN.nc
cdo -O timmean ${2}/processed/${1}_FINAL.nc ${2}/processed/${1}_FINAL_MEAN.nc
