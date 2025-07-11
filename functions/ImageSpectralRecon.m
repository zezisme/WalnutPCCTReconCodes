function ImageSpectralRecon(data_path,save_data_path,cali_path,recon_para)

%% ---------------- Load corrTable -----------------
data = load([cali_path,'\WalnutMDTable.mat']);
Walnut_caliData = data.cali_data;
MaterialNames = data.cali_M;

data = load([cali_path,'\Watercali.mat']);
Watercali = data.Watercali;
data = load([cali_path,'\HAPcali.mat']);
HAPcali = data.HAPcali;

data = load([cali_path,'\H2O_massAttenuationCoeff.mat']);
H2O_massAttenuationCoeff = data.H2O_massAttenuationCoeff;
data = load([cali_path,'\HAP_massAttenuationCoeff.mat']);
HA_massAttenuationCoeff = data.HA_massAttenuationCoeff;

%% ----------------- load data list ------------------
low_data_path = [data_path,'\Low'];
high_data_path = [data_path,'\High'];

low_file_list = dir([low_data_path '\*.dcm']);
high_file_list = dir([high_data_path '\*.dcm']);

%% ----------------- Spectral Recon Begining ------------
tic
fprintf(' Spectral Recon Begining：%s  ...\n',data_path);
image_num = min(size(low_file_list,1),size(high_file_list,1));
for i=1:1:image_num
    if (mod(i,100)==1)
        fprintf(['Processing: ',num2str(i),'/',num2str(image_num),'... total running time: %.3f s  \n'], toc);
    end
    info = dicominfo([low_file_list(i).folder,'\',low_file_list(i).name]);
    imgL = double(dicomread(info));
    imgL = imgL.*info.RescaleSlope + info.RescaleIntercept;
    info = dicominfo([high_file_list(i).folder,'\',high_file_list(i).name]);
    imgH = double(dicomread(info));
    imgH = imgH.*info.RescaleSlope + info.RescaleIntercept;
    % CT+1000
    imgL = imgL+1000;
    imgH = imgH+1000;

    img_size = size(imgL);
    img = [imgL(:)';imgH(:)'];

    if recon_para.WalnutMD_Enable
        DM = [Walnut_caliData(1,1), Walnut_caliData(2,1); Walnut_caliData(1,2), Walnut_caliData(2,2)];
        temp = DM\img * 1000;% g/cm^3 to mg/cm^3
        MaterialPair.M1 = reshape(temp(1,:),img_size);
        MaterialPair.M2 = reshape(temp(2,:),img_size);
        MaterialPairDicomSave(MaterialPair, MaterialNames, save_data_path, info);
    end

    if recon_para.WalnutVMI_Enable
        Kevs = recon_para.WalnutVMI_E;
        keVnum = length(Kevs);
        DM = [Watercali(1,1), HAPcali(1,1); Watercali(1,2), HAPcali(1,2)];
        temp = DM\img;
        MaterialPair.M1 = reshape(temp(1,:),img_size);
        MaterialPair.M2 = reshape(temp(2,:),img_size);
        for k=1:keVnum
            lineatten_keV = MaterialPair.M1*H2O_massAttenuationCoeff(Kevs(k)) + MaterialPair.M2*HA_massAttenuationCoeff(Kevs(k));
            MonoImage = lineatten_keV./H2O_massAttenuationCoeff(Kevs(k))*1000 - 1000; %miu → HU
            % save dicom
            VirtualMonoDicomSave(MonoImage, Kevs(k), save_data_path, info);
        end
    end
end
fprintf('#####  Spectral Recon : total running time is %.3f s  #####\n', toc)
end