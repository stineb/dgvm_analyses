#!/bin/bash

proc_trendy_single (){
	##-----------------------------
	## argument 1: base file name
	##-----------------------------
	## detrend at each gridcell
    if [ $2 = "timestep" ]
    then
		cdo detrend -seltimestep,82/111 -selname,gpp $1_gpp_ANN.nc $1_gpp_DETR.nc
		# cdo detrend -seltimestep,101/111 -selname,gpp $1_gpp_ANN.nc $1_gpp_DETR20XX.nc
	else
		cdo detrend -selyear,1982/2011 -selname,gpp $1_gpp_ANN.nc $1_gpp_DETR.nc
		# cdo detrend -selyear,2001/2011 -selname,gpp $1_gpp_ANN.nc $1_gpp_DETR20XX.nc
	fi

	## get variance of annual GPP at each pixel
	cdo timvar $1_gpp_DETR.nc $1_gpp_VAR.nc
	# cdo timvar $1_gpp_DETR20XX.nc $1_gpp_VAR20XX.nc

	## get mean field
    if [ $2 = "timestep" ]
    then
		cdo timmean -seltimestep,82/111 -selname,gpp $1_gpp_ANN.nc $1_gpp_MEAN.nc
		# cdo timmean -seltimestep,82/111 -selname,gpp $1_gpp_ANN.nc $1_gpp_MEAN20XX.nc  		
 	else
		cdo timmean -selyear,1982/2011 -selname,gpp $1_gpp_ANN.nc $1_gpp_MEAN.nc
		# cdo timmean -selyear,2001/2011 -selname,gpp $1_gpp_ANN.nc $1_gpp_MEAN20XX.nc  		
  	fi

	## get relative variance field
	cdo div $1_gpp_VAR.nc $1_gpp_MEAN.nc $1_gpp_RELVAR.nc
	# cdo div $1_gpp_VAR20XX.nc $1_gpp_MEAN20XX.nc $1_gpp_RELVAR20XX.nc

	## get global totals
	## NBP
	cdo gridarea $1_nbp_ANN.nc gridarea.nc
	cdo mulc,1 -seltimestep,1 $1_nbp_ANN.nc tmp.nc
	cdo div tmp.nc tmp.nc ones.nc
	cdo selname,nbp ones.nc mask.nc
	cdo mul mask.nc gridarea.nc gridarea_masked.nc
	cdo mul gridarea_masked.nc $1_nbp_ANN.nc tmp2.nc
	cdo fldsum tmp2.nc tmp3.nc
	cdo mulc,1e-15 tmp3.nc $1_nbp_GLOB.nc

	## GPP
	cdo mul gridarea_masked.nc $1_gpp_ANN.nc tmp4.nc
	cdo fldsum tmp4.nc tmp5.nc
	cdo mulc,1e-15 tmp5.nc $1_gpp_GLOB.nc

	## detrend
    if [ $2 = "timestep" ]
    then
		cdo detrend -seltimestep,82/111 -selname,nbp $1_nbp_GLOB.nc $1_nbp_DETR_GLOB.nc
		cdo detrend -seltimestep,82/111 -selname,gpp $1_gpp_GLOB.nc $1_gpp_DETR_GLOB.nc

		# cdo detrend -seltimestep,101/111 -selname,nbp $1_nbp_GLOB.nc $1_nbp_DETR_GLOB20XX.nc
		# cdo detrend -seltimestep,101/111 -selname,gpp $1_gpp_GLOB.nc $1_gpp_DETR_GLOB20XX.nc
	else 
		cdo detrend -selyear,1982/2011 -selname,nbp $1_nbp_GLOB.nc $1_nbp_DETR_GLOB.nc
		cdo detrend -selyear,1982/2011 -selname,gpp $1_gpp_GLOB.nc $1_gpp_DETR_GLOB.nc

		# cdo detrend -selyear,2001/2011 -selname,nbp $1_nbp_GLOB.nc $1_nbp_DETR_GLOB20XX.nc
		# cdo detrend -selyear,2001/2011 -selname,gpp $1_gpp_GLOB.nc $1_gpp_DETR_GLOB20XX.nc
	fi


	## variance
	cdo timvar $1_nbp_DETR_GLOB.nc $1_nbp_VAR_GLOB.nc
	cdo timvar $1_gpp_DETR_GLOB.nc $1_gpp_VAR_GLOB.nc

	# cdo timvar $1_nbp_DETR_GLOB20XX.nc $1_nbp_VAR_GLOB20XX.nc
	# cdo timvar $1_gpp_DETR_GLOB20XX.nc $1_gpp_VAR_GLOB20XX.nc

	## remove temporary files
	rm tmp.nc tmp2.nc tmp3.nc tmp4.nc tmp5.nc gridarea.nc gridarea_masked.nc *SUB.nc *DPM.nc *SPM.nc mask.nc ones.nc

	return 0
}

here=`pwd`
myhome=~

##----------------------------------------------------
## CABLE
##----------------------------------------------------
cd $myhome/data/trendy/v5/CABLE/S2

if [[ ! -e CABLE-POP_S2_nbp_ANN.nc || ! -e CABLE-POP_S2_gpp_ANN.nc ]]
then

	## select years
	cdo selyear,1901/2015 CABLE-POP_S2_nbp.nc CABLE-POP_S2_nbp_SUB.nc
	cdo selyear,1901/2015 CABLE-POP_S2_gpp.nc CABLE-POP_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm CABLE-POP_S2_nbp_SUB.nc CABLE-POP_S2_nbp_DPM.nc
	cdo muldpm CABLE-POP_S2_gpp_SUB.nc CABLE-POP_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 CABLE-POP_S2_nbp_DPM.nc CABLE-POP_S2_nbp_SPM.nc
	cdo mulc,86400000 CABLE-POP_S2_gpp_DPM.nc CABLE-POP_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum CABLE-POP_S2_nbp_SPM.nc CABLE-POP_S2_nbp_ANN.nc
	cdo yearsum CABLE-POP_S2_gpp_SPM.nc CABLE-POP_S2_gpp_ANN.nc

fi

proc_trendy_single CABLE-POP_S2

cd $here

#----------------------------------------------------
# CLASS-CTEM: messed up dimensions - therefore not used
#----------------------------------------------------

##----------------------------------------------------
## CLM
##----------------------------------------------------
cd $myhome/data/trendy/v5/CLM/S2

if [[ ! -e CLM4.5_S2_nbp_ANN.nc  || ! -e CLM4.5_S2_gpp_ANN.nc ]]
then

	## select years
	cdo selyear,1901/2015 CLM4.5_S2_nbp.nc CLM4.5_S2_nbp_SUB.nc
	cdo selyear,1901/2015 CLM4.5_S2_gpp.nc CLM4.5_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm CLM4.5_S2_nbp_SUB.nc CLM4.5_S2_nbp_DPM.nc
	cdo muldpm CLM4.5_S2_gpp_SUB.nc CLM4.5_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 CLM4.5_S2_nbp_DPM.nc CLM4.5_S2_nbp_SPM.nc
	cdo mulc,86400000 CLM4.5_S2_gpp_DPM.nc CLM4.5_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum CLM4.5_S2_nbp_SPM.nc CLM4.5_S2_nbp_ANN.nc
	cdo yearsum CLM4.5_S2_gpp_SPM.nc CLM4.5_S2_gpp_ANN.nc

fi

proc_trendy_single CLM4.5_S2

cd $here


##----------------------------------------------------
## DLEM - can't convert to normal NetCDF
##----------------------------------------------------


##----------------------------------------------------
## ISAM
##----------------------------------------------------
cd $myhome/data/trendy/v5/ISAM/S2

if [[ ! -e ISAM_S2_nbp_ANN.nc || ! -e ISAM_S2_gpp_ANN.nc ]]
then

	## select years. time steps 42:156 are for 1901-2015
	cdo seltimestep,42/156 ISAM_S2_nbp.nc ISAM_S2_nbp_SUB.nc
	cdo seltimestep,42/156 ISAM_S2_gpp.nc ISAM_S2_gpp_SUB.nc

	## sum over vertical dimension (given in kgC m-2 month-1)
	cdo mulc,1000 -vertsum ISAM_S2_nbp_SUB.nc ISAM_S2_nbp_ANN.nc
	cdo mulc,1000 -vertsum ISAM_S2_gpp_SUB.nc ISAM_S2_gpp_ANN.nc

fi

proc_trendy_single ISAM_S2 "timestep"

cd $here

##----------------------------------------------------
## JSBACH
##----------------------------------------------------
cd $myhome/data/trendy/v5/JSBACH/S2

if [[ ! -e JSBACH_S2_nbp_ANN.nc || ! -e JSBACH_S2_gpp_ANN.nc ]]
then

	## select years
	cdo selyear,1901/2015 JSBACH_S2_nbp.nc JSBACH_S2_nbp_SUB.nc
	cdo selyear,1901/2015 JSBACH_S2_gpp.nc JSBACH_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm JSBACH_S2_nbp_SUB.nc JSBACH_S2_nbp_DPM.nc
	cdo muldpm JSBACH_S2_gpp_SUB.nc JSBACH_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 JSBACH_S2_nbp_DPM.nc JSBACH_S2_nbp_SPM.nc
	cdo mulc,86400000 JSBACH_S2_gpp_DPM.nc JSBACH_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum JSBACH_S2_nbp_SPM.nc JSBACH_S2_nbp_ANN.nc
	cdo yearsum JSBACH_S2_gpp_SPM.nc JSBACH_S2_gpp_ANN.nc

fi

proc_trendy_single JSBACH_S2

cd $here


##----------------------------------------------------
## LPJ-GUESS
##----------------------------------------------------
cd $myhome/data/trendy/v5/LPJ-GUESS/S2

if [[ ! -e LPJ-GUESS_S2_nbp_ANN.nc  || ! -e LPJ-GUESS_S2_gpp_ANN.nc ]]
then

	## select years
	cdo mulc,3.1536e10 -chname,nbp.yearly,nbp -selyear,1901/2015 LPJ-GUESS_S2_nbp.nc LPJ-GUESS_S2_nbp_ANN.nc
	cdo chname,gpp.monthly,gpp -selyear,1901/2015 LPJ-GUESS_S2_gpp_fEst.nc LPJ-GUESS_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm LPJ-GUESS_S2_gpp_SUB.nc LPJ-GUESS_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 LPJ-GUESS_S2_gpp_DPM.nc LPJ-GUESS_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum LPJ-GUESS_S2_gpp_SPM.nc LPJ-GUESS_S2_gpp_ANN.nc

fi

proc_trendy_single LPJ-GUESS_S2

cd $here


##----------------------------------------------------
## LPX-Bern
##----------------------------------------------------
cd $myhome/data/trendy/v5/LPX-Bern/S2

if [[ ! -e LPX_S2_nbp_ANN.nc || ! -e LPX_S2_gpp_ANN.nc ]]
then

	# Pre-process data
	Rscript /Users/benjaminstocker/emcon_iav/preproc_lpx.R

	## select years WARNING: THERE IS SOMETHING WRONG WITH THE LAST YEAR, THEREFORE REMOVING 2015
	cdo selyear,1901/2014 LPX_S2_nbp_NICE.nc LPX_S2_nbp_SUB.nc
	cdo selyear,1901/2014 LPX_S2_gpp_NICE.nc LPX_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm LPX_S2_nbp_SUB.nc LPX_S2_nbp_DPM.nc
	cdo muldpm LPX_S2_gpp_SUB.nc LPX_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 LPX_S2_nbp_DPM.nc LPX_S2_nbp_SPM.nc
	cdo mulc,86400000 LPX_S2_gpp_DPM.nc LPX_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum LPX_S2_nbp_SPM.nc LPX_S2_nbp_ANN.nc
	cdo yearsum LPX_S2_gpp_SPM.nc LPX_S2_gpp_ANN.nc

fi

proc_trendy_single LPX_S2

cd $here


##----------------------------------------------------
## ORCHIDEE
##----------------------------------------------------
cd $myhome/data/trendy/v5/ORCHIDEE/S2

if [[ ! -e orchidee_S2_nbp_ANN.nc || ! -e orchidee_S2_gpp_ANN.nc ]]
then

	## correcting messed up time axis and selecting years 1901-2015
	Rscript /Users/benjaminstocker/emcon_iav/preproc_orchidee.R

	## multiply with days per month
	cdo muldpm orchidee_S2_nbp_NICE.nc orchidee_S2_nbp_DPM.nc
	cdo muldpm orchidee_S2_gpp_NICE.nc orchidee_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 orchidee_S2_nbp_DPM.nc orchidee_S2_nbp_SPM.nc
	cdo mulc,86400000 orchidee_S2_gpp_DPM.nc orchidee_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum orchidee_S2_nbp_SPM.nc orchidee_S2_nbp_ANN.nc
	cdo yearsum orchidee_S2_gpp_SPM.nc orchidee_S2_gpp_ANN.nc

fi

proc_trendy_single orchidee_S2

cd $here


##----------------------------------------------------
## SDGVM
##----------------------------------------------------
cd $myhome/data/trendy/v5/SDGVM/S2

if [[ ! -e SDGVM_S2_nbp_ANN.nc || ! -e SDGVM_S2_gpp_ANN.nc ]]
then

	## select years (original from Jan 1860 - Oct 2013, total 1872 time steps = 156 years. Therefore should be to Dec 2015. Correct the damn file.)
	Rscript preproc_sdgvm.R

	## subset years
	cdo selyear,1901/2015 SDGVM_S2_nbp_NICE.nc SDGVM_S2_nbp_SUB.nc
	cdo selyear,1901/2015 SDGVM_S2_gpp_NICE.nc SDGVM_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm SDGVM_S2_nbp_SUB.nc SDGVM_S2_nbp_DPM.nc
	cdo muldpm SDGVM_S2_gpp_SUB.nc SDGVM_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 SDGVM_S2_nbp_DPM.nc SDGVM_S2_nbp_SPM.nc
	cdo mulc,86400000 SDGVM_S2_gpp_DPM.nc SDGVM_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum SDGVM_S2_nbp_SPM.nc SDGVM_S2_nbp_ANN.nc
	cdo yearsum SDGVM_S2_gpp_SPM.nc SDGVM_S2_gpp_ANN.nc

fi

proc_trendy_single SDGVM_S2

cd $here


##----------------------------------------------------
## VEGAS
##----------------------------------------------------
cd $myhome/data/trendy/v5/VEGAS/S2

if [[ ! -e VEGAS_S2_nbp_ANN.nc || ! -e VEGAS_S2_gpp_ANN.nc ]]
then

	## subset years
	cdo selyear,1901/2015 VEGAS_S2_nbp.nc VEGAS_S2_nbp_SUB.nc
	cdo selyear,1901/2015 VEGAS_S2_gpp.nc VEGAS_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm VEGAS_S2_nbp_SUB.nc VEGAS_S2_nbp_DPM.nc
	cdo muldpm VEGAS_S2_gpp_SUB.nc VEGAS_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 VEGAS_S2_nbp_DPM.nc VEGAS_S2_nbp_SPM.nc
	cdo mulc,86400000 VEGAS_S2_gpp_DPM.nc VEGAS_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum VEGAS_S2_nbp_SPM.nc VEGAS_S2_nbp_ANN.nc
	cdo yearsum VEGAS_S2_gpp_SPM.nc VEGAS_S2_gpp_ANN.nc

fi

proc_trendy_single VEGAS_S2

cd $here


##----------------------------------------------------
## VISIT
##----------------------------------------------------
cd $myhome/data/trendy/v5/VISIT/S2

if [[ ! -e VISIT_S2_nbp_ANN.nc || ! -e VISIT_S2_gpp_ANN.nc ]]
then

	## subset years
	cdo selyear,1901/2015 VISIT_S2_nbp.nc VISIT_S2_nbp_SUB.nc
	cdo selyear,1901/2015 VISIT_S2_gpp.nc VISIT_S2_gpp_SUB.nc

	## multiply with days per month
	cdo muldpm VISIT_S2_nbp_SUB.nc VISIT_S2_nbp_DPM.nc
	cdo muldpm VISIT_S2_gpp_SUB.nc VISIT_S2_gpp_DPM.nc

	## multiply with seconds per day and convert from kg C to g C
	cdo mulc,86400000 VISIT_S2_nbp_DPM.nc VISIT_S2_nbp_SPM.nc
	cdo mulc,86400000 VISIT_S2_gpp_DPM.nc VISIT_S2_gpp_SPM.nc

	## get annual sums
	cdo yearsum VISIT_S2_nbp_SPM.nc VISIT_S2_nbp_ANN.nc
	cdo yearsum VISIT_S2_gpp_SPM.nc VISIT_S2_gpp_ANN.nc

fi

proc_trendy_single VISIT_S2

cd $here



# doesn't work:
# cdo fldsum -mul -mul -selname,nbp -div mulc,1 -seltimestep,1 CABLE-POP_S2_nbp_ANN.nc mulc,1 -seltimestep,1 CABLE-POP_S2_nbp_ANN.nc -gridarea CABLE-POP_S2_nbp_ANN.nc CABLE-POP_S2_nbp_ANN.nc CABLE-POP_S2_nbp_GLOB.nc


# import csv
# import os

# wdir = '/Users/benjaminstocker/data/trendy/v5/'
# filnams_s2_gpp = wdir + 'trendy_s2_filnams_gpp.csv'

# with open(filnams_s2_gpp, 'r') as csvfile:

#     csvreader = csv.reader(csvfile)

#     for row in csvreader:
#         if not row[1] in (None, ""):
#             base = row[7][0:-3]
#             modl = row[1]
#             print base
#             print modl

#             ## detrending data for each gridcell
#             os.system('cdo detrend ' + base + '.nc ' + base + '_detr.nc' )

#             ## take variance over years for each gridcell
#             os.system('cdo timvar ' + base + '_detr.nc ' + base + '_var.nc' )

#             ## take mean across year for each gridcell
#             os.system('cdo timmean ' + base + '.nc ' + base + '_mean.nc' )

#             ## divide variance by mean
#             os.system('cdo div ' + base + '_var.nc ' + base + '_mean.nc ' + base + '_relvar.nc' )

#             ## time series of global total
#             os.system('cdo fldsum ' + base + '.nc ' + base + '_globaltotal.nc' )

