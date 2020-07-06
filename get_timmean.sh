#!/bin/bash

##----------------------------------------------------
## Calculate the mass fraction of a pool (e.g. wood)
##----------------------------------------------------
## Arguments:
## 1. input file base name
# For example: filn_cRoot="CLASS-CTEM_S1_cRoot"

## 2. Directory path
# For example: dir="/cluster/home/bestocke/data/trendy/v5/CLASS-CTEM/S1/"

## select years
cdo -O selyear,1986/2015 ${2}${1}.nc tmp.nc

## take mean across years
cdo -O timmean tmp.nc ${2}${1}_MEAN.nc

