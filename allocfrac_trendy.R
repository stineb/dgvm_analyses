library(ncdf4)
library(fields)
library(dplyr)
library(LSD)

syshome <- Sys.getenv( "HOME" )
source( paste( syshome, "/.Rprofile", sep="" ) )

availvars <- read.csv( "availvars_trendy_v5_S1.csv" )
filnams <- read.csv( "filnams_trendy_v5_S1.csv", as.is=TRUE )
varnams <- read.csv( "varnams_trendy_v5_S1.csv", as.is=TRUE )
modeltype <- read.csv( "modeltype_trendy_v5.csv", as.is=TRUE )
modeltype <- modeltype %>% mutate( col=ifelse( cn==1, "royalblue3", "springgreen3" ) )

do_modl <- availvars %>% dplyr::filter( cRoot==1 & cLeaf==1 )

df <- data.frame()

for (imodl in do_modl$modl){

  dir <- paste0( myhome, "data/trendy/", imodl,"/S1/" )
  print(paste0( dir ))
  get_acq <- TRUE

  ## Get leaf data
  print("getting cleaf data ...")
  filnam <- dplyr::filter( filnams, modl==imodl )$cLeaf
  varnam <- dplyr::filter( varnams, modl==imodl )$cLeaf
  print(paste0( filnam ))
  nc <- nc_open( paste0( dir, filnam ) )
  cleaf <- ncvar_get( nc, varid=varnam )
  nc_close( nc )

  ## Get root data
  print("getting croot data ...")
  filnam <- dplyr::filter( filnams, modl==imodl )$cRoot
  varnam <- dplyr::filter( varnams, modl==imodl )$cRoot
  print(paste0( filnam ))
  nc <- nc_open( paste0( dir, filnam ) )
  croot <- ncvar_get( nc, varid=varnam )
  nc_close( nc )

  ## change in root mass
  ltime <- dim(cleaf)[3]
	croot_0 <- apply( croot[,,1:10], c(1,2), FUN=mean )
	croot_1 <- apply( croot[,,(ltime-9):ltime], c(1,2), FUN=mean )
	dcroot <- croot_1 / croot_0
	dcroot[which(is.infinite(dcroot))] <- NA
	vec_dcroot <- as.vector(dcroot)

  ## get ratio of allocation belowground
	froot <- croot / cleaf
	froot_0 <- apply( froot[,,1:10], c(1,2), FUN=mean )
	froot_1 <- apply( froot[,,(ltime-9):ltime], c(1,2), FUN=mean )
	dfroot <- froot_1 / froot_0
	dfroot[which(is.infinite(dfroot))] <- NA
	vec_dfroot <- as.vector(dfroot)
	ndata <- length(vec_dfroot)

	## N uptake 
  filnam <- dplyr::filter( filnams, modl==imodl )$fNup
  varnam <- dplyr::filter( varnams, modl==imodl )$fNup
  if (filnam!=""){
	  print("getting fNup data ...")
	  print(paste0( filnam ))
	  nc <- nc_open( paste0( dir, filnam ) )
	  fnup <- ncvar_get( nc, varid=varnam )
	  nc_close( nc )  	

	  if (imodl=="ISAM"){
	  	fnup <- apply( fnup, c(1,2,4), FUN=sum )
	  }
	  if (imodl=="LPJ-GUESS"){
	  	fnup <- apply( fnup, c(2,3,4), FUN=sum )
	  }	  

	  ltime <- dim(fnup)[3]
		fnup_0 <- apply( fnup[,,1:10], c(1,2), FUN=mean )
		fnup_1 <- apply( fnup[,,(ltime-9):ltime], c(1,2), FUN=mean )
		dfnup <- fnup_1 / fnup_0
		dfnup[which(is.infinite(dfnup))] <- NA
		vec_dfnup <- as.vector(dfnup)

	  ## return on investment
	  vec_roi <- as.vector( dfnup / dcroot )

  } else {

  	vec_dfnup <- rep( NA, ndata )
  	vec_roi <- rep( NA, ndata )
  	get_acq <- FALSE

  }

	## Biological N fixation
  filnam <- dplyr::filter( filnams, modl==imodl )$fBNF
  varnam <- dplyr::filter( varnams, modl==imodl )$fBNF
  if (filnam!=""){
	  print("getting fBNF data ...")
	  print(paste0( filnam ))
	  nc <- nc_open( paste0( dir, filnam ) )
	  fbnf <- ncvar_get( nc, varid=varnam )
	  nc_close( nc )  	

	  if (imodl=="ISAM"){
	  	fbnf <- apply( fbnf, c(1,2,4), FUN=sum )
	  }

	  ltime <- dim(fbnf)[3]
		fbnf_0 <- apply( fbnf[,,1:10], c(1,2), FUN=mean )
		fbnf_1 <- apply( fbnf[,,(ltime-9):ltime], c(1,2), FUN=mean )
		dfbnf <- fbnf_1 / fbnf_0
		dfbnf[which(is.infinite(dfbnf))] <- NA
		vec_dfbnf <- as.vector(dfbnf)

  } else {

  	vec_dfbnf <- rep( NA, ndata )
  	get_acq <- FALSE

  }

  ## total N acquisition
  if (get_acq){
	  fnacq <- fbnf + fnup

	  ltime <- dim(fnacq)[3]
		fnacq_0 <- apply( fnacq[,,1:10], c(1,2), FUN=mean )
		fnacq_1 <- apply( fnacq[,,(ltime-9):ltime], c(1,2), FUN=mean )
		dfnacq <- fnacq_1 / fnacq_0
		dfnacq[which(is.infinite(dfnacq))] <- NA
		vec_dfnacq <- as.vector(dfnacq)

	  ## return on investment
	  vec_roi_bnf <- as.vector( dfnacq / dcroot )

  } else {

  	vec_dfnacq <- rep( NA, ndata )
  	vec_roi_bnf <- rep( NA, ndata )

  }

	df_tmp <- data.frame( modl=rep(imodl, ndata), dcroot=vec_dcroot, dfroot=vec_dfroot, dfnup=vec_dfnup, dfbnf=vec_dfbnf, dfnacq=vec_dfnacq, roi=vec_roi, roi_bnf=vec_roi_bnf )
	df <- rbind( df, df_tmp )

}

save( df, file="data_trendy.Rdata" )

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

pdf("dfroot_trendy.pdf", width=9, height=6 )
	par( las=1 )
	boxplot( dfroot ~ modl, data=df , outline=FALSE, col=sub$col )
	abline( h=1, lty=3 )
dev.off()

par( las=1 )
boxplot( dcroot ~ modl, data=df , outline=FALSE, col=sub$col, ylim=c(0,3) )
abline( h=1, lty=3 )

boxplot( dfnup ~ modl, data=df , outline=FALSE, col=sub$col )
abline( h=1, lty=3 )

boxplot( dfnacq ~ modl, data=df , outline=FALSE, col=sub$col )
abline( h=1, lty=3 )

boxplot( dfbnf ~ modl, data=df , outline=FALSE, col=sub$col )
abline( h=1, lty=3 )

boxplot( roi ~ modl, data=df , outline=FALSE, col=sub$col )
abline( h=1, lty=3 )


with( dplyr::filter( df, modl=="CLM" ), plot( dcroot-1, dfnup-1, xlim=c(-1,3), ylim=c(-1,3), pch=16, col=rgb(0,0,0,0.3), main="CLM" ) )
abline( h=0, lty=3 )
abline( v=0, lty=3 )

with( dplyr::filter( df, modl=="ISAM" ), plot( dcroot-1, dfnup-1, xlim=c(-1,3), ylim=c(-1,3), pch=16, col=rgb(0,0,0,0.3), main="ISAM" ) )
abline( h=0, lty=3 )
abline( v=0, lty=3 )

with( dplyr::filter( df, modl=="LPJ-GUESS" ), plot( dcroot-1, dfnup-1, xlim=c(-1,3), ylim=c(-1,3), pch=16, col=rgb(0,0,0,0.3), main="LPJ-GUESS" ) )
abline( h=0, lty=3 )
abline( v=0, lty=3 )

with( dplyr::filter( df, modl=="LPX-Bern" ), plot( dcroot-1, dfnup-1, xlim=c(-1,3), ylim=c(-1,3), pch=16, col=rgb(0,0,0,0.3), main="LPX-Bern" ) )
abline( h=0, lty=3 )
abline( v=0, lty=3 )

