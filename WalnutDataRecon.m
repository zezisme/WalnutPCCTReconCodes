clear all
close all
reset(gpuDevice());
% add present working path
addpath(genpath(pwd));
% add TIGRE toolbox to the matlab path
addpath(genpath('~\TIGRE-master\MATLAB')) %adding tigre main path to matlab


data_dir_root  = '.\Projections';%Projections path
save_path = '.\Reconstructions';%Recon save path
recon_para.CaliTablePath = '.\CalibrationTable'; %calibration table path
recon_para.NonUniformityCorr = 1; % 1(default)/0: is using the ring artifact remove in proj images
recon_para.RingArtifactCorr = 1; % 1(default)/0: is using the ring artifact remove in proj images
recon_para.recon_type = 2;%1:FDK,2:FDK+TV
recon_para.FDK_filter = 'hann'; %'ram-lak'、'shepp-logan'、'cosine'、'hamming' 、'hann'
recon_para.TV_niter = 100;
recon_para.TV_lambda = 20;
recon_para.dose_ratio = 1; %recon dose，1：full dose，2：1/2 dose；4: 1/4 dose ......
recon_para.recon_Bin = [1 1 1]; %1:recon this energy bin，0：don't recon; [Low,High,Total]
%recon setting
recon_para.nVoxel =[1000;1000;300];  % recon voxel size
recon_para.sVoxel=[50;50;15];   %mm，recon FOV size
recon_para.is_write2dicom = 1;%1:save to dicom file, 0:save to png pictures

ReconAllEnergy([data_dir_root,'\','Walnut_1'],[save_path,'\','Walnut_1'],recon_para);


