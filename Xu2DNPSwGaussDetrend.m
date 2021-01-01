function [NPS2D,frequency]=Xu2DNPSwGaussDetrend(Roi,DeltaX,gaussian_radius,offset)

if nargin==3
    offset =0;
else
end
Roi = Roi+offset;
RoiSize=size(Roi,1);
Zdim = size(Roi,3);
roi_mean = mean(mean(mean(Roi)));

Roi = Roi./mean(Roi,3)*roi_mean;
if gaussian_radius<=0
else
    for idx = 1:size(Roi,3)
        temp = Roi(:,:,idx);
        temp = imgaussfilt(temp,gaussian_radius);
        Roi(:,:,idx) = Roi(:,:,idx)./temp*XuMean2(temp);
    end
end
XuWriteRawWithDim('roi',Roi);


NPS2D=zeros(RoiSize,RoiSize);
for fidx=1:Zdim
    NPS2D=NPS2D+fft2(Roi(:,:,fidx)-roi_mean).*conj(fft2(Roi(:,:,fidx)-roi_mean));
end

NPS2D=NPS2D/(Zdim-1)*DeltaX^2/RoiSize^2;
frequency = [0:RoiSize-1]*1/(RoiSize+DeltaX);