function [ReconData,RecPara] = ProjDataRecon(rawdata_proj,AcqPara,RecPara)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This matlab script compute reconstruction for PCCT data sets
%
% author: Enze Zhou
% last update: 2025.03.28
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dose_ratio = max(fix(RecPara.dose_ratio),1); %

%% -------------------Set geo data --------------------
% permute data to TIGRE convention
rawdata_proj = permute(rawdata_proj, [2,1,3]);
rawdata_proj = single(rawdata_proj);
% set geo parameters
geo.DSD = AcqPara.SDD;                             % Distance Source Detector      (mm)
geo.DSO = AcqPara.SID;                             % Distance Source Origin        (mm)
% Detector parameters
geo.nDetector=[AcqPara.nChannelNum; AcqPara.nSliceNum];					% number of pixels              (px)
geo.dDetector=[AcqPara.fDetU; AcqPara.fDetV]; 					% size of each pixel            (mm)
geo.sDetector=geo.nDetector.*geo.dDetector; % total size of the detector    (mm)
% Image parameters
geo.nVoxel=RecPara.nVoxel;                   % number of voxels              (vx)
if(RecPara.sVoxel(1)>0&&RecPara.sVoxel(2)>0)
    geo.sVoxel=RecPara.sVoxel;                  % total size of the image   (mm)
else
    geo.sVoxel=[AcqPara.ScanFOV;AcqPara.ScanFOV;RecPara.sVoxel(3)];                  % total size of the image (mm)
end
geo.sVoxel = double(geo.sVoxel);
geo.dVoxel=geo.sVoxel./geo.nVoxel;          % size of each voxel            (mm)
geo.offOrigin =[0;0;0]; % offOrigin,Shift of location of desired center of the volume (mm)
geo.offDetector = [(AcqPara.nChannelNum/2-AcqPara.U0)/10;(AcqPara.nSliceNum/2-AcqPara.V0)/10];   % Offset of Detector     (mm)
geo.COR = 0; % Center of rotation
geo.mode='cone';
geo.accuracy=1;          % Accuracy of FWD proj          (vx/sample)
% detector rotation
InpRot = deg2rad(AcqPara.InpRot);
geo.rotDetector=[InpRot;0;0];
angles = AcqPara.objViewAngle(1:dose_ratio:end)'; %(1,angle_num)
% permute angles to TIGRE convention (init angle: pi to 0)
angles = angles - pi;

%% -----------Reconstruct image using TIGRE Platfrom------------
tid = tic;
switch RecPara.recon_type
    case 1
        % FDK
        filter_type = RecPara.FDK_filter;
        ReconType = ['FDK_Dose_',num2str(dose_ratio),'_',filter_type];
        fprintf('#FDK recon begin ...\n');
        ReconData=FDK(rawdata_proj,geo,angles,'filter',filter_type);
        fprintf(['#FDK recon' ':total running time is %.3f s\n'], toc(tid));
    case 2
        % FDK
        filter_type = RecPara.FDK_filter;
        fprintf('#FDK-TV recon begin ...\n');
        ReconData=FDK(rawdata_proj,geo,angles,'filter',filter_type);
        fprintf(['FDK recon' ':total running time is %.3f s\n'], toc(tid));
        % TV denoising
        tic
        TV_niter = RecPara.TV_niter; %
        TV_lambda = RecPara.TV_lambda; %
        ReconType = ['FDK_Dose_',num2str(dose_ratio),'_',filter_type,'_TV','_',num2str(TV_niter),'_',num2str(TV_lambda)];
        fprintf('TV-denoising begin ...\n');
        ReconData=im3DDenoise(ReconData,'TV',TV_niter,TV_lambda,'gpuids',GpuIds());
        fprintf(['TV-denoising' ':total running time is %.3f s\n'], toc);
        fprintf(['#FDK-TV recon' ':total running time is %.3f s\n'], toc(tid));
end

%% ------------------- updata RecPara ----------------------
RecPara.ReconType = ReconType;
RecPara.Kernel = filter_type;
RecPara.iFirImg = 0;
RecPara.iEndImg = geo.nVoxel(3)-1;
RecPara.nImgNum = geo.nVoxel(3);
RecPara.FOV = geo.sVoxel(1);
RecPara.Matrix = [geo.nVoxel(1),geo.nVoxel(2)];
RecPara.fCenter = geo.offOrigin;
RecPara.fImgThickness = geo.dVoxel(3);
RecPara.fImgIncrement = geo.dVoxel(3);
fCouchPos = AcqPara.objViewCouchPosition(1); %adapt to continuous scan
RecPara.fStartPos = fCouchPos-geo.sVoxel(3)/2;
RecPara.fEndPos  = fCouchPos+geo.sVoxel(3)/2;
RecPara.objViewAngle = angles;        
RecPara.SpectralType = RecPara.Energy;

end
