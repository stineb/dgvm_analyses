collect_gdf_bymodl <- function(modl, dir, filn_cSoil_init, filn_cSoil_final, filn_cVeg_init, filn_cVeg_final, filn_npp_init, filn_npp_final, filn_cSoil_change){
  
  gdf <- read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_init, ".nc"), ignore_time = TRUE) %>% 
    nc_to_df() %>% 
    tidyr::drop_na(myvar) %>% 
    dplyr::rename(csoil_init = myvar) %>% 
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df() %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(csoil_final = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_init, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df() %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_init = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cVeg_final, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df() %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(cveg_final = myvar),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_npp_init, ".nc"), ignore_time = TRUE) %>%
        nc_to_df() %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(npp_init = myvar) %>%
        mutate(npp_init = npp_init * 60 * 60 * 24 * 365),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_npp_final, ".nc"), ignore_time = TRUE) %>%
        nc_to_df() %>%
        tidyr::drop_na(myvar) %>%
        dplyr::rename(npp_final = myvar) %>%
        mutate(npp_final = npp_final * 60 * 60 * 24 * 365),
      by = c("lon", "lat")
    ) %>%
    left_join(
      read_nc_onefile(paste0(dir, "/processed/", filn_cSoil_change, ".nc"), ignore_time = TRUE) %>% 
        nc_to_df() %>% 
        tidyr::drop_na(myvar) %>% 
        dplyr::rename(csoil_change = myvar),
      by = c("lon", "lat")
    )
  
  return(gdf)
}