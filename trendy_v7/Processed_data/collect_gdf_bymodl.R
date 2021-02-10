collect_gdf_bymodl <- function(modl, dir, 
                               filn_cSoil_init, filn_cSoil_final, 
                               filn_cVeg_init, filn_cVeg_final, 
                               filn_cLeaf_init, filn_cLeaf_final,
                               filn_cRoot_init, filn_cRoot_final,
                               filn_cWood_init, filn_cWood_final,
                               filn_npp_init, filn_npp_final,
                               filn_cSoil_change, filn_cVeg_change,
                               filn_gpp_init,filn_gpp_final,
                               filn_rh_init,filn_rh_final
                               ){
  
  rlang::inform(paste("Collecting outputs for", modl))
  
  ## first get cSoil
  gdf <- read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_init, ".nc"), ignore_time = TRUE, varnam = "cSoil") %>% 
    nc_to_df(varnam = "cSoil") %>% 
    tidyr::drop_na(myvar) %>% 
    dplyr::rename(csoil_init = myvar) %>% 
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_final, ".nc"), ignore_time = TRUE, varnam = "cSoil") %>% 
        nc_to_df(varnam = "cSoil") %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(csoil_final = myvar),
      by = c("lon", "lat")
    ) %>%
    
    ## cVeg
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_init, ".nc"), ignore_time = TRUE, varnam = "cVeg") %>% 
        nc_to_df(varnam = "cVeg") %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_final, ".nc"), ignore_time = TRUE, varnam = "cVeg") %>% 
        nc_to_df(varnam = "cVeg") %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_final = myvar),
      by = c("lon", "lat")
    ) %>%
    
    ## cLeaf
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cLeaf_init, ".nc"), ignore_time = TRUE, varnam = "cLeaf") %>%
        nc_to_df(varnam = "cLeaf") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(cleaf_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cLeaf_final, ".nc"), ignore_time = TRUE, varnam = "cLeaf") %>%
        nc_to_df(varnam = "cLeaf") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(cleaf_final = myvar),
      by = c("lon", "lat")
    ) %>%

    ## cRoot
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cRoot_init, ".nc"), ignore_time = TRUE, varnam = "cRoot") %>%
        nc_to_df(varnam = "cRoot") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(croot_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cRoot_final, ".nc"), ignore_time = TRUE, varnam = "cRoot") %>%
        nc_to_df(varnam = "cRoot") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(croot_final = myvar),
      by = c("lon", "lat")
    ) %>%

    ## cWood
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cWood_init, ".nc"), ignore_time = TRUE, varnam = "cWood") %>%
        nc_to_df(varnam = "cWood") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(cwood_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cWood_final, ".nc"), ignore_time = TRUE, varnam = "cWood") %>%
        nc_to_df(varnam = "cWood") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(cwood_final = myvar),
      by = c("lon", "lat")
    ) %>%

    ## NPP
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_npp_init, ".nc"), ignore_time = TRUE, varnam = "npp") %>%
        nc_to_df(varnam = "npp") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(npp_init = myvar) %>%
        mutate(npp_init = npp_init),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_npp_final, ".nc"), ignore_time = TRUE, varnam = "npp") %>%
        nc_to_df(varnam = "npp") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(npp_final = myvar) %>%
        mutate(npp_final = npp_final),
      by = c("lon", "lat")
    ) %>%
    
    ## soil C change during the last decade
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_change, ".nc"), ignore_time = TRUE, varnam = "cSoil") %>% 
        nc_to_df(varnam = "cSoil") %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(csoil_change = myvar),
      by = c("lon", "lat")
    ) %>% 
    
    ## Veg C change during the last decade
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_change, ".nc"), ignore_time = TRUE, varnam = "cVeg") %>% 
        nc_to_df(varnam = "cVeg") %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_change = myvar),
      by = c("lon", "lat")
    ) %>%  
    ### GPP
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_gpp_init, ".nc"), ignore_time = TRUE, varnam = "gpp") %>%
        nc_to_df(varnam = "gpp") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(gpp_init = myvar) %>%
        mutate(gpp_init = gpp_init*31536000),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_gpp_final, ".nc"), ignore_time = TRUE, varnam = "gpp") %>%
        nc_to_df(varnam = "gpp") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(gpp_final = myvar) %>%
        mutate(gpp_final = gpp_final*31536000),
      by = c("lon", "lat")
    ) %>%
    ### heterotrophic respiration
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_rh_init, ".nc"), ignore_time = TRUE, varnam = "rh") %>%
        nc_to_df(varnam = "rh") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(rh_init = myvar) %>%
        mutate(rh_init = rh_init*31536000),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_rh_final, ".nc"), ignore_time = TRUE, varnam = "rh") %>%
        nc_to_df(varnam = "rh") %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(rh_final = myvar) %>%
        mutate(rh_final = rh_final*31536000),
      by = c("lon", "lat")
    ) %>%
    
    ## add model name as column
    mutate(modl = modl)
  
  ## manipulated
  if (modl == "SDGVM"){
    gdf <- gdf %>% 
      mutate(cwood_final = cwood_final * 0.0, cwood_init = cwood_init * 0.0)
  }
  
  return(gdf)
}