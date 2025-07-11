function MaterialPairDicomSave(MaterialPair, MaterialNames, savepath, info)
% % save dual basis material pair image as .dcm
% 
% Written by enze.zhou 2025.3.11

M1 = MaterialPair.M1;
M2 = MaterialPair.M2;
namenum = num2str(info.InstanceNumber,'%05d');

path1 = [savepath,'\MD_',char(MaterialNames(1)),'_',char(MaterialNames(2)),'\',char(MaterialNames(1))];
path2 = [savepath,'\MD_',char(MaterialNames(1)),'_',char(MaterialNames(2)),'\',char(MaterialNames(2))];
StudyID1 = [char(MaterialNames(1)),'_',char(MaterialNames(2)),'_M1'];
SeriesID1 = [char(MaterialNames(1)),'_',char(MaterialNames(2)),'_M1'];
StudyID2 = [char(MaterialNames(1)),'_',char(MaterialNames(2)),'_M2'];
SeriesID2 = [char(MaterialNames(1)),'_',char(MaterialNames(2)),'_M2'];
RescaleIntercept1 = -2500;
RescaleSlope1 = 0.2;
RescaleIntercept2 = -2500;
RescaleSlope2 = 0.2;

if exist(path1,'dir') ~=7
    mkdir(path1);
end
if exist(path2,'dir') ~=7
    mkdir(path2);
end
info.WindowCenter = 1000;
info.WindowWidth = 5000;

info.StudyID = StudyID1; 
info.SeriesInstanceUID = SeriesID1;
info.RescaleIntercept = RescaleIntercept1;
info.RescaleSlope = RescaleSlope1;
info.SeriesDescription = StudyID1;
temp = uint16((M1-info.RescaleIntercept)./info.RescaleSlope);
path = [path1, '\', namenum, '.dcm'];
status = dicomwrite(temp,path,info,'WritePrivate',true,'Dictionary','dicom-dict-2007-New.txt');
% status = dicomwrite(temp,path,info);

info.StudyID = StudyID2; 
info.SeriesInstanceUID = SeriesID2;
info.RescaleIntercept = RescaleIntercept2;
info.RescaleSlope = RescaleSlope2;
info.SeriesDescription = StudyID2;
temp = uint16((M2-info.RescaleIntercept)./info.RescaleSlope);
path = [path2, '\', namenum, '.dcm'];
status = dicomwrite(temp,path,info,'WritePrivate',true,'Dictionary','dicom-dict-2007-New.txt');
% status = dicomwrite(temp,path,info);
end