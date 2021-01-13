1. Download data from CMIP5 database, select esmFixClim1, Variable_list={'cLeaf','cRoot','cSoil','cVeg','cWood','npp'}; Model_list={'CanESM2';'GFDL-ESM2M';'HadGEM2-ES';'IPSL-CM5A-LR';'NorESM1-ME';'MRI-ESM1'};
2. process these files into nc files in \dgvm_analyses\CMIP5\Processed_data\processed, using CMIP5_make_init_final_mean_for_beni.m, they are INIT - average of the first 10 years, Final - average of the last ten years
3. Make gdf.rda file from nc files processed in step 2 using soc_biomass_CMIP5.Rmd
4. soc_biomass_CMIP5.Rmd will also produce pdf files which are our final figures