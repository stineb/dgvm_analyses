library(dplyr)

cesar_bg <- read.csv( paste0( myhome, "/data/face/terrer17nphyt/terrer17nphyt.csv" ) )
cesar_bg <- cesar_bg %>% mutate( dfnacq=nup_elev/nup_amb, dcroot=fr_elev/fr_amb ) %>% mutate( roi_bnf=dfnacq/dcroot )

cesar_ag <- read.csv( paste0( myhome, "/data/face/terrer17nphyt/ANPPforBeni.csv" ) )
cesar_ag <- cesar_ag %>% mutate( id=paste( SITE_Sps, N, myc, sep="_" ) )
cesar_bg <- cesar_bg %>% left_join( dplyr::select( cesar_ag, id, ANPP ), by="id" ) %>% mutate( dcleaf=exp(ANPP) ) %>% mutate( dfroot=dcroot/dcleaf  )

df_cesar <- cesar_bg %>% rename( modl=myc ) %>% mutate( dfbnf=NA, dfnup=NA, roi=NA ) %>% dplyr::select( modl, dcroot, dfroot, dfnup, dfbnf, dfnacq, roi, roi_bnf )

df <- rbind( df, df_cesar )

sub <- dplyr::select( df, modl ) %>% unique()
sub <- sub %>% left_join( dplyr::select(modeltype, modl, col), by="modl" )

sub$col[ which( sub$modl %in% c("ECM", "AM", "N-fixing") ) ] <- "grey70"