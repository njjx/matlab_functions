function status = XuZBinningDicom(config_rebinning)

reslice_para = XuReadJsonc(config_rebinning);
reslice_binning = reslice_para.ResliceBinningCount;


D=dir([reslice_para.InputDir '/' reslice_para.InputPrefix '*']);
ImageRoi=zeros(512,512,length(D));

N=length(D);

%dicom images should be sorted based on the UID
UID_record=cell(N,2);

pb = MgCmdLineProgressBar('Reading Dicom file #');

for fidx=1:N
    pb.print(fidx,N);
    info = dicominfo([reslice_para.InputDir '/',D(fidx).name]);
    UID_record(fidx,1)= cellstr(info.MediaStorageSOPInstanceUID);
    UID_record(fidx,2)= cellstr(num2str(fidx));
end

UID_record_sort = natsortrows(UID_record);

for fidx=1:N
    fidx_adj = str2num(char(UID_record_sort(fidx,2)));
    Image=dicomread([reslice_para.InputDir '/',D(fidx_adj).name]);
    Image = double(Image);
    Image=Image-1024;
    ImageRoi(:,:,fidx)=Image';
end

image_rebin=zeros(512,512,size(ImageRoi,3)-reslice_binning+1);
pb = MgCmdLineProgressBar('Reslicing slice #');
for fidx=1:size(image_rebin,3)
    pb.print(fidx, size(image_rebin,3));
    image_rebin(:,:,fidx)=mean(ImageRoi(:,:,fidx:fidx+reslice_binning-1),3);
    
    if reslice_para.Vendor == 1
        image_rebin(:,:,fidx)=image_rebin(:,:,fidx)+3024;
    elseif reslice_para.Vendor == 2
        image_rebin(:,:,fidx)=image_rebin(:,:,fidx)+1000;
    end
    image_rebin(:,:,fidx)=imrotate(image_rebin(:,:,fidx),-reslice_para.Rotation,'bilinear','crop');
    if reslice_para.Vendor == 1
        image_rebin(:,:,fidx)=image_rebin(:,:,fidx)+3024;
    elseif reslice_para.Vendor == 2
        image_rebin(:,:,fidx)=image_rebin(:,:,fidx)-1000;
    end
end

mkdir([reslice_para.InputDir '/z_rebin']);

if isfield(reslice_para,'HUOffset')
    hu_offset = reslice_para.HUOffset;
else
    hu_offset=0;
end

XuWriteRaw([ reslice_para.InputDir '/z_rebin/z_rebin_for_' reslice_para.InputPrefix],image_rebin+hu_offset);

disp(['File saved to ', reslice_para.InputDir '/z_rebin/z_rebin_for_' reslice_para.InputPrefix ,'.raw!']);