function SN = ReconDataSave(ReconData, AcqPara, RecPara,SN,save_path)

Energy = RecPara.Energy;
ReconType = RecPara.ReconType;
%% ------------HU corr---------------
corr_table_path = RecPara.CaliTablePath;
load([corr_table_path,'\','HU_water_table.mat']);
if strcmp(Energy,'Low')
    ReconData = ReconData*HU_water_table.low-1000;
elseif strcmp(Energy,'High')
    ReconData = ReconData*HU_water_table.high-1000;
elseif strcmp(Energy,'Total')
    ReconData = ReconData*HU_water_table.total-1000;
end

% data save
if RecPara.is_write2dicom
    %% ------------Write2Dicom-----------------
    DcmPara.name = ReconType;
    DcmPara.path = [save_path,'\',ReconType,'\',RecPara.Energy];
    tic
    fprintf('WriteToDicom begin ...\n');
    SN = Write2Dicom(ReconData, DcmPara, AcqPara, RecPara,SN);
    fprintf(['WriteToDicom' ':total running time is %.3f s\n'], toc);
else
    %% -----------Write2PNG--------------------
    ImagePath = [save_path,'\',ReconType,'\',RecPara.Energy];
    tic
    fprintf('WriteToPNG begin ...\n');
    SN = Write2PNG(ReconData, ImagePath, RecPara, SN);
    fprintf(['WriteToPNG' ':total running time is %.3f s\n'], toc);

    fid = fopen([save_path,'\','recon_HU_',ReconType,'_',AcqPara.Energy,'.data'],'w');
    ReconData = reshape(ReconData,[],1);
    fwrite(fid,ReconData,'float32');
    fclose(fid);
end
end