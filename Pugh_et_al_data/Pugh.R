library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(readr)
library(stringr)

setwd("F:/Side_project/Beni/dgvm_analyses/Pugh_et_al_data/")
# filnams <- read_csv( "filnams_trendy_v8_S1.csv" ) %>% 
filnams <- read_csv( "Processed_data/filnams_Pugh_S1.csv" ) %>% 
  setNames(c("modl", paste0("filn_", names(.)[-1])))

modls <- filnams %>% 
  filter(!is.na(filn_cSoil) & !is.na(filn_cVeg) & !is.na(filn_npp)) %>%
  
  ## for separate aboveground biomass
  filter(!is.na(filn_cWood) & !is.na(filn_cLeaf)) %>%
  
  
  pull(modl)


df <- filnams %>% 
  
  ## filter based on above
  filter(modl %in% modls) %>%
  
  # mutate(dir = paste0("/cluster/home/bestocke/data/trendy/v8/")) %>% 
  # mutate(dir = paste0("~/data/trendy/v8/")) %>% 
  mutate(dir = paste0("Processed_data")) %>% 
  mutate_at(vars(starts_with("filn")), ~str_replace(., "\\.nc", "")) %>%
  mutate_at(vars(starts_with("filn")), ~str_replace(., "cleaf", "cLeaf")) %>%
  mutate_at(vars(starts_with("filn")), ~str_replace(., "croot", "cRoot")) %>%
  mutate_at(vars(starts_with("filn")), ~str_replace(., "csoil", "cSoil")) %>%
  mutate_at(vars(starts_with("filn")), ~str_replace(., "cveg", "cVeg")) %>%
  mutate_at(vars(starts_with("filn")), ~str_replace(., "cwood", "cWood")) %>%
  mutate_at(vars(starts_with("filn")), ~str_replace(., "cRootf", "cRoot"))%>%
  
  ## get starting year
  left_join(read_csv("Processed_data/startyear_Pugh_S1.csv"), by = "modl") %>% 
  rename(startyear_init = startyear, startyear_npp_init = startyear_npp) %>% 
  mutate(endyear_init = startyear_init + 9, endyear_npp_init = startyear_npp_init + 9) %>% 
  
  ## create CDO command to convert flux (per seconds) to annual total (per year)
  mutate(cmd_npp_units = paste("E:/RA/Pugh/processed_well_done/processed/get_tot_annCABLE_clleaction.sh", filn_npp, dir)) %>% 
  
  ## create CDO command to take mean across years at simulation start and end
  mutate(cmd_cVeg  = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_soc_biomass3.sh", filn_cVeg,  dir, startyear_init, endyear_init),
         cmd_cSoil = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_soc_biomass3.sh", filn_cSoil, dir, startyear_init, endyear_init),
         cmd_npp   = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_soc_biomass3.sh", filn_npp_ANN,  dir, startyear_npp_init, endyear_npp_init),
         cmd_cLeaf = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_soc_biomass3.sh", filn_cLeaf, dir, startyear_init, endyear_init),
         cmd_cWood = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_soc_biomass3.sh", filn_cWood, dir, startyear_init, endyear_init),
         cmd_cRoot = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_soc_biomass3.sh", filn_cRoot, dir, startyear_init, endyear_init),
         cmd_dcSoil = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_dsoc2.sh", filn_cSoil, dir),
         cmd_dcVeg  = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_dsoc2.sh", filn_cVeg,  dir),
         cmd_dcLeaf  = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_dsoc2.sh", filn_cLeaf,  dir),
         cmd_dcWood  = paste("E:/RA/Pugh/processed_well_done/processed/proc_trendy_dsoc2.sh", filn_cWood,  dir)
  ) %>% 
  
  rowwise() %>% 
  mutate(filn_cVeg_init  = paste0(filn_cVeg, "_INIT_MEAN"),
         filn_cVeg_final = paste0(filn_cVeg, "_FINAL_MEAN"),
         
         filn_cLeaf_init  = paste0(filn_cLeaf, "_INIT_MEAN"),
         filn_cLeaf_final = paste0(filn_cLeaf, "_FINAL_MEAN"),
         
         filn_cRoot_init  = paste0(filn_cRoot, "_INIT_MEAN"),
         filn_cRoot_final = paste0(filn_cRoot, "_FINAL_MEAN"),
         
         filn_cWood_init  = paste0(filn_cWood, "_INIT_MEAN"),
         filn_cWood_final = paste0(filn_cWood, "_FINAL_MEAN"),
         
         filn_cSoil_init  = paste0(filn_cSoil, "_INIT_MEAN"),
         filn_cSoil_final = paste0(filn_cSoil, "_FINAL_MEAN"),
         
         filn_cSoil_change = paste0(filn_cSoil, "_CHANGE"),
         filn_cVeg_change  = paste0(filn_cVeg, "_CHANGE"),
         filn_cLeaf_change = paste0(filn_cLeaf, "_CHANGE"),
         filn_cWood_change = paste0(filn_cWood, "_CHANGE"),
         
         filn_npp_init  = paste0(filn_npp_ANN, "_INIT_MEAN"),
         filn_npp_final = paste0(filn_npp_ANN, "_FINAL_MEAN")
  )

#######change the variable name
#cabsoil<-nc_open('lpjml_cruncep_cSoil_annual_1901_2014_INIT_MEAN.nc')
#ncvarrename(cabsoil,'csoil_fast','csoil')

source("Processed_data/collect_gdf_bymodl.R")
source("Processed_data/read_nc_onefile.R")
source("Processed_data/nc_to_df.R")
source("Processed_data/collect_gdf_bymodl.R")
gdf <- purrr::map(
  
  as.list(seq(nrow(df))),
  
  ~collect_gdf_bymodl(
    
    df$modl[.],
    df$dir[.],
    
    df$filn_cSoil_init[.],
    df$filn_cSoil_final[.],
    
    df$filn_cVeg_init[.],
    df$filn_cVeg_final[.],
    
    df$filn_cLeaf_init[.],
    df$filn_cLeaf_final[.],
    
    df$filn_cRoot_init[.],
    df$filn_cRoot_final[.],
    
    df$filn_cWood_init[.],
    df$filn_cWood_final[.],
    
    df$filn_npp_init[.],
    df$filn_npp_final[.],
    
    df$filn_cSoil_change[.],
    df$filn_cVeg_change[.]
  )) %>% 
  
  bind_rows() %>%
  
  ## get aboveground biomass as sum of cWood and cLeaf
  mutate(cveg_ag_init = cleaf_init + cwood_init,
         cveg_ag_final = cleaf_final + cwood_final
  ) %>%
  
  group_by(modl) %>%
  nest()

## Calculate relationships
get_deltas <- function(df){
  df %>%
    mutate(dcveg = (cveg_final - cveg_init)/cveg_init,
           dcveg_ag = (cveg_ag_final - cveg_ag_init)/cveg_ag_init,
           dnpp = (npp_final - npp_init)/npp_init,
           dcsoil = (csoil_final - csoil_init)/csoil_init,
           dcsoil_star = (csoil_star_final - csoil_star_init)/csoil_star_init
    )
}

get_csoil_star <- function(df){
  df %>%
    mutate(csoil_star_init  = csoil_init) %>%
    # mutate(csoil_change = csoil_final - csoil_init) %>%   # overwriting what's read from file - XXX This was wrong XXX
    mutate(csoil_change = csoil_change / 104.0) %>%
    mutate(csoil_star_final = csoil_final / (1.0 - (csoil_change)/npp_final ))
}

gdf <- gdf %>%
  mutate(data = purrr::map(data, ~get_csoil_star(.))) %>%
  mutate(data = purrr::map(data, ~get_deltas(.)))

#Plot relationships:

### Biomass vs. NPP change
## just one model
source("Processed_data/analyse_modobs2.R")
source("Processed_data/LSD.heatscatter.R")


modobs <- gdf$data[[2]] %>%
  dplyr::filter(dnpp < 2 & dnpp > -2 & dcveg < 2 & dcveg > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg), !is.infinite(dnpp), !is.infinite(dcveg)) %>%
  analyse_modobs2("dnpp", "dcveg", type = "heat", plot_subtitle = FALSE, plot_linmod = FALSE)
modobs$gg +
  xlim(c(-0.5,1)) + ylim(c(-0.5,1)) +
  labs(title = gdf$modl[[2]])

## all models pooled
gdf %>%
  unnest(data) %>%
  dplyr::filter(dnpp < 2 & dnpp > -2 & dcveg < 2 & dcveg > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg), !is.infinite(dnpp), !is.infinite(dcveg)) %>%
  ggplot(aes(x = dnpp, y = dcveg)) +
  stat_density_2d(aes(fill = after_stat(level)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5))

## all models separately (facet_grid)
gdf %>%
  dplyr::filter(modl != "CABLE-POP") %>%
  unnest(data) %>%
  bind_rows(
    .,
    gdf %>%
      dplyr::filter(modl != "CABLE-POP") %>%
      mutate(n = purrr::map_int(data, ~nrow(.))) %>%
      mutate(data = purrr::map(data, ~slice_sample(., n = 4420))) %>% # smallest set here
      unnest(data) %>%
      mutate(modl = "ALL")
  ) %>%
  dplyr::filter(dnpp>-0.9) %>% # remove points where veg collapses
  dplyr::filter(dnpp < 2 & dnpp > -2 & dcveg < 2 & dcveg > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg), !is.infinite(dnpp), !is.infinite(dcveg)) %>%
  ggplot(aes(x = dnpp, y = dcveg)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.1, 0.9) + ylim(-0.1, 0.9) +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(filename="cveg_dnpp_Pugh_bymodl.pdf", width = 9, height = 7, path = "E:/RA/Pugh/processed_well_done/processed/processednew")


##csoil
## one model
modobs <- gdf$data[[2]] %>%
  dplyr::filter(dnpp < 2 & dnpp > -2 & dcsoil_star < 2 & dcsoil_star > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcsoil_star), !is.infinite(dnpp), !is.infinite(dcsoil_star)) %>%
  analyse_modobs2("dnpp", "dcsoil_star", type = "heat", plot_subtitle = FALSE, plot_linmod = FALSE)
modobs$gg +
  xlim(c(-0.5,1)) + ylim(c(-0.5,1)) +
  labs(title = gdf$modl[[2]])

## all models pooled
modobs <- gdf %>%
  unnest(data) %>%
  dplyr::filter(dnpp < 2 & dnpp > -2 & dcsoil_star < 2 & dcsoil_star > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcsoil_star), !is.infinite(dnpp), !is.infinite(dcsoil_star)) %>%
  analyse_modobs2("dnpp", "dcsoil_star", type = "hex", plot_subtitle = FALSE, plot_linmod = FALSE)
modobs$gg +
  xlim(c(-0.1,0.7)) + ylim(c(-0.1,0.7)) +
  labs(title = "All models pooled")

## cSoil* vs. NPP, all models separately (facet_grid)
gdf %>%
  dplyr::filter(modl != "CABLE-POP") %>%
  unnest(data) %>%
  bind_rows(
    .,
    gdf %>%
      dplyr::filter(modl != "CABLE-POP") %>%
      mutate(n = purrr::map_int(data, ~nrow(.))) %>%
      mutate(data = purrr::map(data, ~slice_sample(., n = 4420))) %>% # smallest set here
      unnest(data) %>%
      mutate(modl = "ALL")
  ) %>%
  dplyr::filter(dcsoil_star < 2 & dcsoil_star > -2 & dnpp < 2 & dnpp > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dnpp), !is.infinite(dnpp), !is.infinite(dnpp)) %>%
  ggplot(aes(x = dnpp, y = dcsoil_star)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.3, 1.2) + ylim(-0.3, 1.2) +
  labs(x = expression(paste(Delta, "NPP", "/NPP")),
       y = expression(paste(Delta, "C"[soil], "/C"[soil]))) +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(filename = "csoil_dnpp_Pugh_bymodl.pdf", width = 9, height = 7, path = "E:/RA/Pugh/processed_well_done/processed/processednew")


## cSoil*, all models pooled
gdf %>%
  unnest(data) %>%
  dplyr::filter(dcsoil_star < 2 & dcsoil_star > -2 & dcveg < 2 & dcveg > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg), !is.infinite(dnpp), !is.infinite(dcveg)) %>%
  
  ggplot(aes(x = dcveg, y = dcsoil_star)) +
  
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  xlim(-0.1, 1) + ylim(-0.1, 1) +
  labs(x = expression(paste(Delta, "C"[veg], "/C"[veg])),
       y = expression(paste(Delta, "C"[soil], "/C"[soil])))
# theme(legend.position = "none",
#       strip.background = element_blank())

## cSoil*, all models separately (facet_grid)
gdf %>%
  unnest(data) %>%
  bind_rows(
    .,
    gdf %>%
      mutate(n = purrr::map_int(data, ~nrow(.))) %>%
      mutate(data = purrr::map(data, ~slice_sample(., n = 1956))) %>% # smallest set here
      unnest(data) %>%
      mutate(modl = "ALL")
  ) %>%
  dplyr::filter(dcsoil_star < 2 & dcsoil_star > -2 & dcveg < 2 & dcveg > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg), !is.infinite(dnpp), !is.infinite(dcveg)) %>%
  
  ggplot(aes(x = dcveg, y = dcsoil_star)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.1, 1) + ylim(-0.1, 1) +
  labs(x = expression(paste(Delta, "C"[veg], "/C"[veg])),
       y = expression(paste(Delta, "C"[soil], "/C"[soil]))) +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(filename = "csoil_cveg_Pugh_bymodl.pdf", width = 9, height = 7, path = "E:/RA/Pugh/processed_well_done/processed/processednew")


## cSoil, all models separately (facet_grid)
gdf %>%
  unnest(data) %>%
  bind_rows(
    .,
    gdf %>%
      mutate(n = purrr::map_int(data, ~nrow(.))) %>%
      mutate(data = purrr::map(data, ~slice_sample(., n = 4420))) %>% # smallest set here
      unnest(data) %>%
      mutate(modl = "ALL")
  ) %>%
  dplyr::filter(dcsoil < 2 & dcsoil > -2 & dcveg < 2 & dcveg > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg), !is.infinite(dnpp), !is.infinite(dcveg)) %>%
  
  ggplot(aes(x = dcveg, y = dcsoil)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.1, 0.9) + ylim(-0.1, 0.9) +
  theme(legend.position = "none",
        strip.background = element_blank())

### SOC vs. aboveground biomass change

## cSoil*, all models separately (facet_grid)
gdf %>%
  unnest(data) %>%
  # bind_rows(
  #   .,
  #   gdf %>%
  #     mutate(n = purrr::map_int(data, ~nrow(.))) %>%
  #     mutate(data = purrr::map(data, ~slice_sample(., n = 4420))) %>% # smallest set here
  #     unnest(data) %>%
  #     mutate(modl = "ALL")
  # ) %>%
  dplyr::filter(dcsoil_star < 2 & dcsoil_star > -2 & dcveg_ag < 2 & dcveg_ag > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg_ag), !is.infinite(dnpp), !is.infinite(dcveg_ag)) %>%
  
  ggplot(aes(x = dcveg_ag, y = dcsoil_star)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  geom_vline(xintercept = 0, color = "grey50", size = 0.2) +
  geom_hline(yintercept = 0, color = "grey50", size = 0.2) +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.2, 1.0) + ylim(-0.2, 1.0) +
  labs(x = expression(paste(Delta, "C"[ag-veg], "/C"[ag-veg])),
       y = expression(paste(Delta, "C"[soil], "/C"[soil]))) +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(filename = "csoil_cveg_ag_Pugh_bymodl.pdf", width = 7, height = 7, path = "E:/RA/Pugh/processed_well_done/processed/processednew")


## cSoil*, all models pooled
gdf %>%
  
  ## sample 1957 points from each model (corresponds to the number of gridcell of the model with coarsest res.)
  mutate(data = purrr::map(data, ~slice_sample(., n = 1957))) %>% # smallest set here
  unnest(data) %>%
  mutate(modl = "ALL") %>%
  
  dplyr::filter(dcsoil_star < 2 & dcsoil_star > -2 & dcveg_ag < 2 & dcveg_ag > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg_ag), !is.infinite(dnpp), !is.infinite(dcveg_ag)) %>%
  
  ggplot(aes(x = dcveg_ag, y = dcsoil_star)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  geom_vline(xintercept = 0, color = "grey50", size = 0.2) +
  geom_hline(yintercept = 0, color = "grey50", size = 0.2) +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  # facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.2, 1.0) + ylim(-0.2, 1.0) +
  labs(x = expression(paste(Delta, "C"[ag-veg], "/C"[ag-veg])),
       y = expression(paste(Delta, "C"[soil], "/C"[soil]))) +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(filename = "csoil_cveg_ag_Pugh_pooled.pdf", width = 4, height = 3, path = "E:/RA/Pugh/processed_well_done/processed/processednew")

## cSoil, all models separately (facet_grid)
gdf %>%
  dplyr::filter(modl != "CABLE-POP") %>%
  unnest(data) %>%
  bind_rows(
    .,
    gdf %>%
      dplyr::filter(modl != "CABLE-POP") %>%
      mutate(n = purrr::map_int(data, ~nrow(.))) %>%
      mutate(data = purrr::map(data, ~slice_sample(., n = 4420))) %>% # smallest set here
      unnest(data) %>%
      mutate(modl = "ALL")
  ) %>%
  dplyr::filter(dcsoil < 2 & dcsoil > -2 & dcveg_ag < 2 & dcveg_ag > -2) %>%
  dplyr::filter(!is.nan(dnpp), !is.nan(dcveg_ag), !is.infinite(dnpp), !is.infinite(dcveg_ag)) %>%
  ggplot(aes(x = dcveg_ag, y = dcsoil)) +
  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon") +
  theme_classic() +
  geom_abline(intercept=0, slope=1, linetype="dotted") +
  scale_fill_gradientn(colours = colorRampPalette( c("gray65", "navy", "red", "yellow"))(5),
                       guide = "legend") +
  facet_wrap(. ~ modl, nrow = 3,  scales = "free") +
  xlim(-0.1, 0.9) + ylim(-0.1, 0.9) +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(filename = "dcsoil_dcveg_ag_Pugh.pdf", width = 4, height = 3, path = "E:/RA/Pugh/processed_well_done/processed/processednew")
#save(gdf, file = "gdf.RData")


# Because Beni asked me to: One thing that needs verification is whether the NPP averaging and units conversion are correct. Could you check whether globally integrated NPP is on the order of 60-80 PgC yr-1 (order-of-magnitude check). And a second point: whether the ratio csoil_change/npp_final is between 0 and 1 for all grid cells (calculated in get_csoil_star function in soc_biomass.Rmd).

##::::::::::::::::::::::::::::
##  check globally total NPP  
##::::::::::::::::::::::::::::
load("Processed_data/gdf.RData")

source("Processed_data/df_to_grid.R")
rotate_matrix <- function(x) apply(t(x), 2, rev)
suppressMessages(library(raster))

par(mfrow=c(2,3))
for (model_num in 1:nrow(gdf)){
  npp_init<-gdf$data[[model_num]]%>% 
    dplyr::select(lon,lat,npp_init)%>% 
    df_to_grid(varnam = "npp_init")%>%
    rotate_matrix()
  
  map_kg_m2 <-raster::raster(npp_init,crs=sp::CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'),xmn=0, xmx=360,
                             ymn=-90, ymx=+90) #unit: kg/m2, it was kg/m2/s but has been converted in collect_gdf_bymodl.R
  plot(map_kg_m2)
  a <- raster::area(map_kg_m2)
  map_MgPixel <- map_kg_m2 * a * 1000000 #convert /s to /year and convert km2 to m2
  npp_sum_init<-cellStats(map_MgPixel,"sum", na.rm=T) * 10^(-12) #from kg to Pg
  
  
  npp_init<-gdf$data[[model_num]]%>% 
    dplyr::select(lon,lat,npp_final)%>% 
    df_to_grid(varnam = "npp_final")%>% 
    rotate_matrix()
  
  map_kg_m2 <-raster::raster(npp_init,crs=sp::CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')  ,xmn=0, xmx=360,
                             ymn=-90, ymx=+90) #unit: kg/m2, it was kg/m2/s but has been converted in collect_gdf_bymodl.R
  a <- raster::area(map_kg_m2)
  map_MgPixel <- map_kg_m2 * a * 1000000 #convert /s to /year and convert km2 to m2
  npp_sum_final<-cellStats(map_MgPixel,"sum", na.rm=T) * 10^(-12) #from kg to Pg
  print(paste("model name:",gdf$modl[model_num],"npp_init",round(npp_sum_init),"npp_sum_final",round(npp_sum_final)))
  print(dim(npp_init))
}

#This print out NPP magnitude first. then dimension of the map

for (model_num in 1:nrow(gdf)){
  npp_init<-gdf$data[[model_num]]%>% 
    dplyr::select(csoil_change,npp_final)%>% 
    mutate(Beni_checker=csoil_change/npp_final)%>%
    dplyr::select(Beni_checker)
  colnames(npp_init)<-gdf$modl[[model_num]]
  print(gdf$modl[[model_num]])
  print(npp_init[,1] %>% quantile(., probs = c(0.1, 0.5, 0.9), na.rm=T))
}

```