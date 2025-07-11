clear all
close all
% add present working path
addpath(genpath(pwd));

recon_para.WalnutMD_Enable = 1;
recon_para.WalnutVMI_Enable = 1;
recon_para.WalnutVMI_E = 10:10:80;

data_dir_root  = '.\Reconstructions';%recon pics path
save_path = '.\Reconstructions';%result save path
cali_path = '.\CalibrationTable'; %calibration table path

ImageSpectralRecon([data_dir_root,'\','Walnut_3\FDK_Dose_1_hann_TV_100_20'],[save_path,'\','Walnut_3\FDK_Dose_1_hann_TV_100_20'],cali_path,recon_para);
