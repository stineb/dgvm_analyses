#!/bin/bash

##----------------------------------------------------
## Calculate the mass fraction of a pool (e.g. wood)
##----------------------------------------------------
## Arguments:
## 1. File name cPOOL
# For example: filn_cRoot="CLASS-CTEM_S1_cRoot"

## 2. File name cVeg
# For example: filn_cveg="CLASS-CTEM_S1_cVeg"

## 3. Directory path
# For example: dir="/cluster/home/bestocke/data/trendy/v5/CLASS-CTEM/S1/"

## select years
cdo -O selyear,1986/2015 ${3}${1}.nc ${3}${1}_SUB.nc
cdo -O selyear,1986/2015 ${3}${2}.nc ${3}${2}_SUB.nc

## divide
cdo -O div ${3}${1}_SUB.nc ${3}${2}_SUB.nc ${3}${1}MF.nc

## take mean across years
cdo -O timmean ${3}${1}MF.nc ${3}${1}MF_MEAN.nc

