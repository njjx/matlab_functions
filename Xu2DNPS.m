function [NPS2D,frequency]=Xu2DNPS(Roi,DeltaX,offset)

if nargin==2
    offset =0;
else
end
Roi = Roi+offset;
RoiSize=size(Roi,1);
Zdim = size(Roi,3);
roi_mean = mean(mean(mean(Roi)));

Roi = Roi./mean(Roi,3)*roi_mean;

%XuWriteRawWithDim('roi',Roi);

NPS2D=zeros(RoiSize,RoiSize);
for fidx=1:Zdim
    NPS2D=NPS2D+fft2(Roi(:,:,fidx)-roi_mean).*conj(fft2(Roi(:,:,fidx)-roi_mean));
end

NPS2D=NPS2D/(Zdim-1)*DeltaX^2/RoiSize^2;
frequency = [0:RoiSize-1]*1/(RoiSize+DeltaX);