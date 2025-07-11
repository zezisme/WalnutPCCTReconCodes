function rawdata_proj = RingArtifactCorrection(rawdata_proj,AcqPara)
Method_type = 1; %1（default） or 2
switch Method_type
    case 1 % Smoothing in multiple subsets to reduce low-frequency ringing artifacts introduced by object edges
        proj_view = size(rawdata_proj,3);
        nChannelNum = AcqPara.nChannelNum;
        nSliceNum = AcqPara.nSliceNum;
  
        medfilter_w_x = 10;
        medfilter_w_y = 10;
        sub_view_num = 10;
        gauss_alpha = 2;
        WindowWidthHalf = 250;
        WindowIndex = fix(AcqPara.U0)-WindowWidthHalf:1:fix(AcqPara.U0)+WindowWidthHalf-1;
        sub_views = proj_view/sub_view_num;
        
        rawdata_proj_coeff = zeros(nChannelNum,nSliceNum,sub_view_num);
        n = 1;
        for v=1:sub_views:proj_view
            rawdata_proj_smooth = medfilt2(mean(rawdata_proj(:,:,v:v+sub_views-1),3),[medfilter_w_x medfilter_w_y]);
            rawdata_proj_coeff(:,:,n) = mean(rawdata_proj(:,:,v:v+sub_views-1),3) - rawdata_proj_smooth;
            n = n + 1;
        end
        rawdata_proj_coeff = median(rawdata_proj_coeff,3);
        rawdata_proj_coeff_smooth = imgaussfilt(rawdata_proj_coeff,gauss_alpha);
        rawdata_proj_coeff = rawdata_proj_coeff - rawdata_proj_coeff_smooth;
        corr_coeff = zeros(nChannelNum,nSliceNum);
        corr_coeff(WindowIndex,:) = rawdata_proj_coeff(WindowIndex,:);
        rawdata_proj = rawdata_proj - corr_coeff;
    case 2 % May create new low-frequency ring artifacts
        
        gauss_alpha = 10;
        WindowWidthHalf = 250;
        WindowIndex = fix(AcqPara.U0)-WindowWidthHalf:1:fix(AcqPara.U0)+WindowWidthHalf-1;
        rawdata_proj_mean = mean(rawdata_proj,3);
        rawdata_proj_smooth = imgaussfilt(rawdata_proj_mean,gauss_alpha);
        rawdata_proj_coeff = ones(AcqPara.nChannelNum,AcqPara.nSliceNum);
        temp_coeff = rawdata_proj_smooth./rawdata_proj_mean; %
        rawdata_proj_coeff(WindowIndex,:) = temp_coeff(WindowIndex,:);
        rawdata_proj = rawdata_proj.*rawdata_proj_coeff;
       
end

