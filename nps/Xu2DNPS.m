function [NPS2D,frequency]=Xu2DNPS(Roi,DeltaX)

RoiSize=size(Roi,1);
Zdim = size(Roi,3);
NPS2D=zeros(RoiSize,RoiSize);
for fidx=1:Zdim
    NPS2D=NPS2D+fft2(Roi(:,:,fidx)).*conj(fft2(Roi(:,:,fidx)));
end

NPS2D=NPS2D/Zdim*DeltaX^2/RoiSize^2;
frequency = [0:RoiSize-1]*1/(RoiSize+DeltaX);