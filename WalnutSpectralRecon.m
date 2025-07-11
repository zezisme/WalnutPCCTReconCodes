clear all
close all

recon_para.WalnutMD_Enable = 1;
recon_para.WalnutVMI_Enable = 1;
recon_para.WalnutVMI_E = 10:10:80;

data_dir_root  = '\\169.254.10.119\zhouenze\核桃数据集（202412）\单帧生数据_简单处理\Reconstructions';%recon pics path
save_path = '\\169.254.10.119\zhouenze\核桃数据集（202412）\单帧生数据_简单处理\Reconstructions';%result save path
cali_path = '\\169.254.10.119\zhouenze\核桃数据集（202412）\单帧生数据_校正\CalibrationTable'; %calibration table path

ImageSpectralRecon([data_dir_root,'\','Walnut_3\FDK_Dose_1_hann_TV_100_20'],[save_path,'\','Walnut_3\FDK_Dose_1_hann_TV_100_20'],cali_path,recon_para);
