
% ##################################################################
% ##                          2020-03-01                          ##
% ##             Contact:huanyuan.zhang@ouce.ox.ac.uk             ##
% ##                  This is prepared for Beni,                  ##
% ##    in order to calculate Model_variables_ANN_INIT_MEAN.nc    ##
% ##            and Model_variables_ANN_FINAL_MEAN.nc             ##
% ##            as input data for collect_gdf_bymodl.R            ##
% ##################################################################



% ##################################################################################
% ##  because esmFixClim1 require models to increase CO2 concentration by 1%      ##
% ##  every year, to compare with NCC 2019 paper, we take the difference of Cveg  ##
% ##  between 28th year (372ppm) and 78th year (616ppm), then we calculate delta  ##
% ##  Cveg and delta Csoil Input data: CIMP5 esmFixClim1 Csoil or Cveg or Cwood   ##
% ##  or Croot or cLeaf or npp                                                    ##
% ##################################################################################

clc
clear
close all

%These models are selected because they have all variables available
Model_list={'CanESM2';'GFDL-ESM2M';'HadGEM2-ES';'IPSL-CM5A-LR';'NorESM1-ME';'MRI-ESM1'};
Variable_list={'cLeaf','cRoot','cSoil','cVeg','cWood','npp'};
% A list of model we could use (available on the database),
% file cVeg_Lmon_HadGEM2-ES_esmFixClim1_r1i1p1_185912-188411.nc is broken,
% need to replace with other file. This would not change our final result
% because we will use the 28th year.

%% read maps

cd E:\Cesar_project_csoil\CMIP5\rawdata2
% All the nc files downloaded from CMIP5 database stored here
% To download input file, go to https://esgf-index1.ceda.ac.uk/search/cmip5-ceda/
% set filter as "esmfixclim1" and "cveg" / "csoil"

%% Csoil
for Variable_to_read_num=1:length(Variable_list)
for Modelnum=1:length(Model_list)
    Variable_to_read=Variable_list{Variable_to_read_num};
    Model_name=Model_list{Modelnum};
    File = dir(strcat(Variable_to_read,'*',Model_name,'*.nc'));
    if ~isempty(File)
        
        for ii=1:length(File)
            filename=strcat(File(ii).folder,filesep,File(ii).name);
            disp(filename)
            if ii==1
                Csoil=ncread(filename,Variable_to_read);
            else
                Csoil=cat(3,Csoil,ncread(filename,Variable_to_read));
            end
            % read all the Csoil files of the given model, put them into a 3d matrix:
            % latitude*Longitude*year
        end
        %lets assume first year is 285ppm, so 372ppm should be year 28. amd 616ppm should be year 78 (well, if they do increase by 1% every year )
        %Csoil_before=nanmean(Csoil(:,:,325:358),3); % Average across the 27 28 29th years
        %Csoil_After=nanmean(Csoil(:,:,925:960),3);% Average across the 77 78 79th years
      
      
        Csoil_before=nanmean(Csoil(:,:,277:384),3); % Average across the 24 25 26 27 28 29 30 31 32th years
        Csoil_After=nanmean(Csoil(:,:,877:984),3);% Average across the 74 75 76 77 78 79 80 81 82th years
        
%         Csoil_before=Gap_fill_function(Csoil_before); %this is to fill as much NaN as possible, otherwise, average across several models will lost lots of grids.
%         Csoil_before=Gap_fill_function(Csoil_before); %this is to fill as much NaN as possible, otherwise, average across several models will lost lots of grids.
%         Csoil_After=Gap_fill_function(Csoil_After); %this is to fill as much NaN as possible, otherwise, average across several models will lost lots of grids.
%         Csoil_After=Gap_fill_function(Csoil_After); %this is to fill as much NaN as possible, otherwise, average across several models will lost lots of grids.

        %%%This part is used to remove NA value
        Na_to_remove=mode(Csoil_before(:));%my new idea is that the most common values must be the missing value
        if numel(Csoil_before(isnan(Csoil_before))) < numel(Csoil_before(Csoil_before==Na_to_remove)) %make sure that the amount of this value is larger than the amount of NAn
        Csoil_before(Csoil_before==Na_to_remove)=NaN;
        end  
        
        Na_to_remove=mode(Csoil_After(:));%my new idea is that the most common values must be the missing value
        if numel(Csoil_After(isnan(Csoil_After))) < numel(Csoil_After(Csoil_After==Na_to_remove)) %make sure that the amount of this value is larger than the amount of NAn
        Csoil_After(Csoil_After==Na_to_remove)=NaN;
        end  
        
        Lon=ncread(filename,'lon');
        Lat=ncread(filename,'lat');
        lon_bnds=ncread(filename,'lon_bnds');
        lat_bnds=ncread(filename,'lat_bnds');
        [lon_num,lat_num]=size(Csoil_before);
        New_file_name=strcat('processed',filesep,Model_name,'_',Variable_to_read,'_','INIT_MEAN.nc');
        fprintf('for model %s lon_num is %d and lat_num is %d',Model_name,lon_num,lat_num)
        if exist(New_file_name,'file')==2
            delete(New_file_name)
        end
        nccreate(New_file_name,'lon','Dimensions',{'lon',lon_num},'Datatype','double')
        ncwrite(New_file_name,'lon',Lon);
        ncwriteatt(New_file_name,'lon','bnds','for bnds check CMIP5 metadata');
        
        nccreate(New_file_name,'lat','Dimensions',{'lat',lat_num},'Datatype','double')
        ncwrite(New_file_name,'lat',Lat);
        
        
        nccreate(New_file_name,Variable_to_read,'Dimensions',{'lon',lon_num,'lat',lat_num},'Datatype','single');
        ncwrite(New_file_name,Variable_to_read,Csoil_before);
        ncwriteatt(New_file_name,Variable_to_read,'units','check CMIP5 metadata');
        ncwriteatt(New_file_name,Variable_to_read,'Description','this is a mean value Average across the 24 25 26 27 28 29 30 31 32th years, CMIP5 esmfixclim1');
        
        %% write the second nc file
        
        New_file_name=strcat('processed',filesep,Model_name,'_',Variable_to_read,'_','FINAL_MEAN.nc');
        fprintf('for model %s lon_num is %d and lat_num is %d',Model_name,lon_num,lat_num)
        if exist(New_file_name,'file')==2
            delete(New_file_name)
        end
        nccreate(New_file_name,'lon','Dimensions',{'lon',lon_num},'Datatype','double')
        ncwrite(New_file_name,'lon',Lon);
        ncwriteatt(New_file_name,'lon','bnds','for bnds check CMIP5 metadata');
        
        
        nccreate(New_file_name,'lat','Dimensions',{'lat',lat_num},'Datatype','double')
        ncwrite(New_file_name,'lat',Lat);
        
        nccreate(New_file_name,Variable_to_read,'Dimensions',{'lon',lon_num,'lat',lat_num},'Datatype','single');
        ncwrite(New_file_name,Variable_to_read,Csoil_After);
        ncwriteatt(New_file_name,Variable_to_read,'units','check CMIP5 metadata');
        ncwriteatt(New_file_name,Variable_to_read,'Description','this is a mean value Average across the 74 75 76 77 78 79 80 81 82th years, CMIP5 esmfixclim1');
        
    end
    
end
end

%% let's get Csoil change
for Modelnum=1:length(Model_list)
    Variable_to_read=Variable_list{3};
    Model_name=Model_list{Modelnum};
    File = dir(strcat(Variable_to_read,'*',Model_name,'*.nc'));
    if ~isempty(File)
        
        for ii=1:length(File)
            filename=strcat(File(ii).folder,filesep,File(ii).name);
            disp(filename)
            if ii==1
                Csoil=ncread(filename,Variable_to_read);
            else
                Csoil=cat(3,Csoil,ncread(filename,Variable_to_read));
            end
            % read all the Csoil files of the given model, put them into a 3d matrix:
            % latitude*Longitude*year
        end
        %lets assume first year is 285ppm, so 372ppm should be year 28. amd 616ppm should be year 78 (well, if they do increase by 1% every year )
        %Csoil_before=nanmean(Csoil(:,:,325:358),3); % Average across the 27 28 29th years
        %Csoil_After=nanmean(Csoil(:,:,925:960),3);% Average across the 77 78 79th years
        
        Csoil_before=nanmean(Csoil(:,:,277:384),3); % Average across the 24 25 26 27 28 29 30 31 32th years
        Csoil_After=nanmean(Csoil(:,:,877:984),3);% Average across the 74 75 76 77 78 79 80 81 82th years
        Na_to_remove=mode(Csoil_before(:));%my new idea is that the most common values must be the missing value
        if numel(Csoil_before(isnan(Csoil_before))) < numel(Csoil_before(Csoil_before==Na_to_remove)) %make sure that the amount of this value is larger than the amount of NAn
        Csoil_before(Csoil_before==Na_to_remove)=NaN;
        end  
        
        Na_to_remove=mode(Csoil_After(:));%my new idea is that the most common values must be the missing value
        if numel(Csoil_After(isnan(Csoil_After))) < numel(Csoil_After(Csoil_After==Na_to_remove)) %make sure that the amount of this value is larger than the amount of NAn
        Csoil_After(Csoil_After==Na_to_remove)=NaN;
        end  

        Csoil_change=Csoil_After-Csoil_before;
%         Csoil_change=Gap_fill_function(Csoil_change); %this is to fill as much NaN as possible, otherwise, average across several models will lost lots of grids.

        Lon=ncread(filename,'lon');
        Lat=ncread(filename,'lat');
        lon_bnds=ncread(filename,'lon_bnds');
        lat_bnds=ncread(filename,'lat_bnds');
        [lon_num,lat_num]=size(Csoil_before);
        New_file_name=strcat('processed',filesep,Model_name,'_',Variable_to_read,'_','CHANGE.nc');
        fprintf('for model %s lon_num is %d and lat_num is %d',Model_name,lon_num,lat_num)
        if exist(New_file_name,'file')==2
            delete(New_file_name)
        end
        nccreate(New_file_name,'lon','Dimensions',{'lon',lon_num},'Datatype','double')
        ncwrite(New_file_name,'lon',Lon);
        ncwriteatt(New_file_name,'lon','bnds','for bnds check CMIP5 metadata');
        
        nccreate(New_file_name,'lat','Dimensions',{'lat',lat_num},'Datatype','double')
        ncwrite(New_file_name,'lat',Lat);
        
        
        nccreate(New_file_name,Variable_to_read,'Dimensions',{'lon',lon_num,'lat',lat_num},'Datatype','single');
        ncwrite(New_file_name,Variable_to_read,Csoil_change);
        ncwriteatt(New_file_name,Variable_to_read,'units','check CMIP5 metadata');
        ncwriteatt(New_file_name,Variable_to_read,'Description','this is the difference between cSoil 28th year and cSoil 78th year, CMIP5 esmfixclim1');
       
         
    end
    
end


%% Gap_fill function
function Csoil=Gap_fill_function(New_soc)
Csoil=New_soc;
[Lat_total,Lon_total]=size(Csoil);
Step=3;
for lat=Step+1:Lat_total-Step
    for lon=Step+1:Lon_total-Step
        if isnan(Csoil(lat,lon))
          
            Mother_grid=Csoil(lat-Step:lat+Step,lon-Step:lon+Step);
            
            if sum(sum(isnan(Mother_grid)))<(size(Mother_grid,1)*size(Mother_grid,2)/3) % so, the amount of NAn must smaller than one thrid of the number of mother grids (Otherwise, you are going to fill everything.)
            Csoil(lat,lon)=nanmean(nanmean(Mother_grid));
            end
        end
    end
end
end
