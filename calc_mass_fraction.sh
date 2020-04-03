#!/bin/bash

##----------------------------------------------------
## Calculate the mass fraction of a pool (e.g. wood)
##----------------------------------------------------
## Arguments:
## 1. File name cPOOL
# For example: filn_cwood="CLASS-CTEM_S1_cWood"

## 2. File name cVeg
# For example: filn_cveg="CLASS-CTEM_S1_cVeg"

## 3. Variable name cPOOL
# For example: varn_cwood="cWood"

## 4. Variable name cVeg
# For example: varn_cveg="cVeg"

## 5. Directory path
# For example: dir="/cluster/home/bestocke/data/trendy/v5/CLASS-CTEM/S1/"

## select years
cdo -O selyear,1986/2015 ${5}${1}.nc ${5}${1}_SUB.nc
cdo -O selyear,1986/2015 ${5}${2}.nc ${5}${2}_SUB.nc

## divide
cdo -O div ${5}${1}_SUB.nc ${5}${2}_SUB.nc ${5}${1}MF.nc

## take mean across years
cdo -O timmean ${5}${1}MF.nc ${5}${1}MF_MEAN.nc

