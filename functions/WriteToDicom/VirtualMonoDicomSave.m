function VirtualMonoDicomSave(Image, kev, savepath, info)
% % save Mono image as .dcm
% Written by enze.zhou 2024.08.28

namenum = num2str(info.InstanceNumber,'%05d');

path1 = [savepath,'\VirtualMonoImg\',num2str(kev),'Kev'];
StudyID1 = [num2str(kev),'Kev'];
SeriesID1 = [num2str(kev),'Kev'];
RescaleIntercept1 = -9192;
RescaleSlope1 = 1;

if exist(path1,'dir') ~=7
    mkdir(path1);
end

info.StudyID = StudyID1; 
info.SeriesInstanceUID = SeriesID1;
info.RescaleIntercept = RescaleIntercept1;
info.RescaleSlope = RescaleSlope1;
info.SeriesDescription = ['VirtualMono_',num2str(kev),'Kev'];
temp = uint16((Image-info.RescaleIntercept)./info.RescaleSlope);
path = [path1, '\', namenum, '.dcm'];
status = dicomwrite(temp,path,info,'WritePrivate',true,'Dictionary','dicom-dict-2007-New.txt');
% dicomwrite(temp,path,info);

end