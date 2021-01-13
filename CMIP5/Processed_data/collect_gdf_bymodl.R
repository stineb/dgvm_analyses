collect_gdf_bymodl <- function(modl, dir, 
                               filn_cSoil_init, filn_cSoil_final, 
                               filn_cVeg_init, filn_cVeg_final, 
                               filn_cLeaf_init, filn_cLeaf_final, 
                               filn_cRoot_init, filn_cRoot_final, 
                               filn_cWood_init, filn_cWood_final, 
                               filn_npp_init, filn_npp_final, 
                               filn_cSoil_change
                               ){
  
  ## first get cSoil
  rotate_matrix <- function(x) apply(t(x), 2, rev)
  
  gdf <- read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_init, ".nc"), ignore_time = TRUE) %>% 
    nc_to_df(varnam = "cSoil") %>% 
    #tidyr::drop_na(myvar) %>% 
    dplyr::rename(csoil_init = myvar) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cSoil") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(csoil_final = myvar),
      by = c("lon", "lat")
    ) %>%
    
    ## cVeg
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_init, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cVeg") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cVeg") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_final = myvar),
      by = c("lon", "lat")
    ) %>%
    
    ## cLeaf
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cLeaf_init, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cLeaf") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(cleaf_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cLeaf_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cLeaf") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(cleaf_final = myvar),
      by = c("lon", "lat")
    ) %>%
    
    ## cRoot
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cRoot_init, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cRoot") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(croot_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cRoot_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cRoot") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(croot_final = myvar),
      by = c("lon", "lat")
    ) %>%

    ## cWood
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cWood_init, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cWood") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(cwood_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cWood_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cWood") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(cwood_final = myvar),
      by = c("lon", "lat")
    ) %>%
    
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_npp_init, ".nc"), ignore_time = TRUE) %>%
        nc_to_df(varnam = "npp") %>%
        #tidyr::drop_na(myvar) %>%
        dplyr::rename(npp_init = myvar) %>%
        mutate(npp_init = npp_init * 60 * 60 * 24 * 365),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_npp_final, ".nc"), ignore_time = TRUE) %>%
        nc_to_df(varnam = "npp") %>%
        # tidyr::drop_na(myvar) %>%
        dplyr::rename(npp_final = myvar) %>%
        mutate(npp_final = npp_final * 60 * 60 * 24 * 365),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_change, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df(varnam = "cSoil") %>% 
        #tidyr::drop_na(myvar) %>% 
        dplyr::rename(csoil_change = myvar),
      by = c("lon", "lat")
    )
  
  return(gdf)
}