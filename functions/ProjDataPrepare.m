function [rawdata_proj,AcqPara,recon_para] = ProjDataPrepare(data_path,recon_para,Energy)
tid = tic;
lowThreshold = 5;
highThreshold = 4090;
badPixelIndex = [];
fprintf('#ProjDataPrepare begining: ...\n');
dose_ratio = max(fix(recon_para.dose_ratio),1); %
corr_table_path = recon_para.CaliTablePath;
recon_para.Energy = Energy;
%% ---------- Step1:Load RawData -------------
tic
load([data_path,'\Total\','AcqPara.mat']);
nChannelNum = AcqPara.nChannelNum;

nSliceNum = AcqPara.nSliceNum;
file_list_high = dir([data_path '\High\*.raw']);
file_list_total = dir([data_path '\Total\*.raw']);
rawdata_proj_high = zeros(nChannelNum,nSliceNum,fix(length(file_list_high)/dose_ratio),'single');
rawdata_proj_total = zeros(nChannelNum,nSliceNum,fix(length(file_list_high)/dose_ratio),'single');
rawdata_proj_low = zeros(nChannelNum,nSliceNum,fix(length(file_list_high)/dose_ratio),'single');
n = 0;
for i=1:dose_ratio:length(file_list_high)
    n = n + 1;
    file_name = file_list_high(i).name;
    file_path = [data_path,'\High\',file_name];
    fid = fopen(file_path,'r');
    proj = fread(fid,'uint16');
    fclose(fid);
    temp_high = reshape(proj,nChannelNum,nSliceNum);

    file_name = file_list_total(i).name;
    file_path = [data_path,'\Total\',file_name];
    fid = fopen(file_path,'r');
    proj = fread(fid,'uint16');
    
    fclose(fid);
    temp_total = reshape(proj,nChannelNum,nSliceNum);
    temp_low = temp_total - temp_high;
    rawdata_proj_high(:,:,n) = temp_high;
    rawdata_proj_total(:,:,n) = temp_total;
    rawdata_proj_low(:,:,n) = temp_low;
    %% ----------------- find bad pixels-----------------
    index1 = find(temp_total <= lowThreshold);
    index2 = find(temp_total >= highThreshold);
    badPixelIndex = [badPixelIndex;index1;index2];
    index1 = find(temp_high <= lowThreshold);
    index2 = find(temp_high >= highThreshold);
    badPixelIndex = [badPixelIndex;index1;index2];
    index1 = find(temp_low <= lowThreshold);
    index2 = find(temp_low >= highThreshold);
    badPixelIndex = [badPixelIndex;index1;index2]; 
end
badPixelIndex = sort(unique(badPixelIndex));
fprintf(['Load RawData',':total running time is %.3f s\n'], toc);

%% --------- Step2: AirCorrection --------------
tic
    fileID = fopen([corr_table_path,'\','air_table_low.raw']);
    airtable = fread(fileID,nChannelNum*nSliceNum,'uint16');
    fclose(fileID);
    airtable = reshape(airtable,nChannelNum,nSliceNum,[]);
    rawdata_proj_low = -log(max(rawdata_proj_low,0)) + log(max(airtable,0));
    rawdata_proj_low = single(rawdata_proj_low);

    fileID = fopen([corr_table_path,'\','air_table_high.raw']);
    airtable = fread(fileID,nChannelNum*nSliceNum,'uint16');
    fclose(fileID);
    airtable = reshape(airtable,nChannelNum,nSliceNum,[]);
    rawdata_proj_high = -log(max(rawdata_proj_high,0)) + log(max(airtable,0));
    rawdata_proj_high = single(rawdata_proj_high);

    fileID = fopen([corr_table_path,'\','air_table_total.raw']);
    airtable = fread(fileID,nChannelNum*nSliceNum,'uint16');
    fclose(fileID);
    airtable = reshape(airtable,nChannelNum,nSliceNum,[]);
    rawdata_proj_total = -log(max(rawdata_proj_total,0)) + log(max(airtable,0));
    rawdata_proj_total = single(rawdata_proj_total);

fprintf(['AirCorrection',':total running time is %.3f s\n'], toc);
%% --------- Step3:NonUniformityCorr --------------
if recon_para.NonUniformityCorr
    tic
    if strcmp(Energy,'Low')
        fileID = fopen([corr_table_path,'\','STEPC_table_low.data']);
        HL_corr_table = fread(fileID,'float32');
        fclose(fileID);
        HL_corr_table = reshape(HL_corr_table,nChannelNum,nSliceNum,[]);
        rawdata_proj_error = poly_corr_proj(rawdata_proj_low,rawdata_proj_high,HL_corr_table,2);
        rawdata_proj = rawdata_proj_low - rawdata_proj_error;
    elseif strcmp(Energy,'High')
        fileID = fopen([corr_table_path,'\','STEPC_table_high.data']);
        HL_corr_table = fread(fileID,'float32');
        fclose(fileID);
        HL_corr_table = reshape(HL_corr_table,nChannelNum,nSliceNum,[]);
        rawdata_proj_error = poly_corr_proj(rawdata_proj_low,rawdata_proj_high,HL_corr_table,2);
        rawdata_proj = rawdata_proj_high - rawdata_proj_error;
    elseif strcmp(Energy,'Total')
        fileID = fopen([corr_table_path,'\','STEPC_table_total.data']);
        HL_corr_table = fread(fileID,'float32');
        fclose(fileID);
        HL_corr_table = reshape(HL_corr_table,nChannelNum,nSliceNum,[]);
        rawdata_proj_error = poly_corr_proj(rawdata_proj_low,rawdata_proj_high,HL_corr_table,2);
        rawdata_proj = rawdata_proj_total - rawdata_proj_error;
    end
    clear rawdata_proj_low rawdata_proj_high rawdata_proj_total rawdata_proj_error
    fprintf(['NonUniformityCorr',':total running time is %.3f s\n'], toc);
end

%% --------- Step4:BadPixelsCorr --------------
tic
% read bad pixels index table
fileID  = fopen([corr_table_path,'\','badchannelIndexAll.data']);
badchannelIndexTable = fread(fileID,'float32');
fclose(fileID);
badchannelIndexAll = sort(unique([badPixelIndex;badchannelIndexTable]));
rawdata_proj = reshape(rawdata_proj,nChannelNum*nSliceNum,[]);
rawdata_proj(badchannelIndexAll,:) = NaN;
rawdata_proj = reshape(rawdata_proj,nChannelNum,nSliceNum,[]);
for i=1:1:size(rawdata_proj,3)
    % channel bad pixel corr
    for j=1:1:nSliceNum
        temp_proj = double(rawdata_proj(:,j,i));
        validIdx = find(~isnan(temp_proj));
        invalidIdx = find(isnan(temp_proj));
        if ~isempty(invalidIdx) && numel(validIdx) > 1
            rawdata_proj(invalidIdx,j,i) = interp1(validIdx, temp_proj(validIdx), invalidIdx, 'linear', 'extrap');
        end
    end
    % gap slice pixel corr
    gap_index = [252;253;254];
    validIdx = 1:1:nSliceNum;
    validIdx(gap_index) = [];
    invalidIdx = gap_index;
    for j=1:1:nChannelNum
        temp_proj = double(rawdata_proj(j,:,i));
        if ~isempty(invalidIdx) && numel(validIdx) > 1
            rawdata_proj(j,invalidIdx,i) = interp1(validIdx, temp_proj(validIdx), invalidIdx, 'linear', 'extrap');
        end
    end
end
fprintf(['BadPixelsCorr',':total running time is %.3f s\n'], toc);
%% ------------------- Step5: Ring Artifact Correction ---------------------
if recon_para.RingArtifactCorr
    tic;
    rawdata_proj = RingArtifactCorrection(rawdata_proj,AcqPara);
    fprintf(['RingArtifactCorr',':total running time is %.3f s\n'], toc);
end

fprintf(['#ProjDataPrepare',':total running time is %.3f s\n'], toc(tid));
end
