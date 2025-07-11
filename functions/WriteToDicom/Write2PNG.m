function [SN] = Write2PNG(Image, ImagePath, RecPara, SN)
WindowCenter = 1000; 
WindowWidth = 5000;
range=[WindowCenter-WindowWidth/2,WindowCenter+WindowWidth/2];

path = ImagePath;
if ~exist(path,'dir')
    mkdir(path);
    if ~exist(path,'dir')
        error(['Cannot create directory ' path '!']);
    end
end

for i=1:RecPara.nImgNum
    pic = Image(:,:,i);
    pic = (pic-range(1))/WindowWidth;
    pic = min(max(pic,0),1);
    SN = SN+1;
    imwrite(pic, [path '\'  num2str(SN,'%05d') '.png'],'BitDepth',16);
end
end