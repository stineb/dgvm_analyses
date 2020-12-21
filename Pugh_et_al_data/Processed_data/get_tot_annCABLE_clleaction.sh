#!/bin/bash
##----------------------------------------------------
## converting variable in kg C m-2 s-1 to annual totals in kg C m-2 yr-1
##----------------------------------------------------
## Arguments:
## 1. File name
## 2. Directory path; for example: dir="/cluster/home/bestocke/data/trendy/v8/"
##----------------------------------------------------
## converting variable in kg C m-2 s-1 to annual totals in kg C m-2 yr-1
##----------------------------------------------------
## Arguments:
## 1. File name
## 2. Directory path; for example: dir="/cluster/home/bestocke/data/trendy/v8/"
## converting npp
## get annual mean
cdo -O yearmean CABLE-POP_cruncep_npp_month_1901_2015.nc4 ./processed/CABLE-POP_cruncep_npp_month_1901_2015_ANN_SEC.nc
## multiply with seconds per year to get annual total
cdo -O mulc,31536000 ./processed/CABLE-POP_cruncep_npp_month_1901_2015_ANN_SEC.nc ./processed/CABLE-POP_cruncep_npp_month_1901_2015_ANN_third.nc
## remove pft
ncwa -a pft -y sum ./processed/CABLE-POP_cruncep_npp_month_1901_2015_ANN_third.nc ./processed/CABLE-POP_cruncep_npp_annual_1901_2015.nc

## converting cleaf
## get annual mean
cdo -O yearsum CABLE-POP_cruncep_cleaf_month_1901_2015.nc4 ./processed/CABLE-POP_cruncep_cleaf_month_1901_2015_ANN_SEC.nc
## remove pft
ncwa -a pft -y sum ./processed/CABLE-POP_cruncep_cleaf_month_1901_2015_ANN_SEC.nc ./processed/CABLE-POP_cruncep_cleaf_annual_1901_2015.nc

## converting croot
## get annual mean
cdo -O yearsum CABLE-POP_cruncep_croot_month_1901_2015.nc4 ./processed/CABLE-POP_cruncep_croot_month_1901_2015_ANN_SEC.nc
## remove pft
ncwa -a pft -y sum ./processed/CABLE-POP_cruncep_croot_month_1901_2015_ANN_SEC.nc ./processed/CABLE-POP_cruncep_croot_annual_1901_2015.nc

## converting csoil
## get annual mean
cdo -O yearsum CABLE-POP_cruncep_csoil_month_1901_2015.nc4 ./processed/CABLE-POP_cruncep_csoil_annual_1901_2015.nc

## converting cveg
## get annual mean
cdo -O yearsum CABLE-POP_cruncep_cveg_month_1901_2015.nc4 ./processed/CABLE-POP_cruncep_cveg_annual_1901_2015.nc

## converting cwood
## get annual mean
cdo -O yearsum CABLE-POP_cruncep_cwood_month_1901_2015.nc4 ./processed/CABLE-POP_cruncep_cwood_month_1901_2015_ANN_SEC.nc
## remove pft
ncwa -a pft -y sum ./processed/CABLE-POP_cruncep_cwood_month_1901_2015_ANN_SEC.nc ./processed/CABLE-POP_cruncep_cwood_annual_1901_2015.nc
