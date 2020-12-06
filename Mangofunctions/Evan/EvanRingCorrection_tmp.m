function  EvanRingCorrection_tmp(filename_input, filename_output)
fid=fopen(filename_input);
fimg = fread(fid,'float32');
fclose(fid);
imlength=512;
volsize=3;
fimg=reshape(fimg,[imlength, imlength, volsize ]);

%for alpha=1:size(fimg,3), %Starting on a slice
iterations=2;
for iter=1:iterations
    for alpha=1:volsize%Starting on a slice
        img=fimg(:,:,alpha);
        %%%Bilinear interpolation transformation from cartesian to polar coordinates
        rsize=round(imlength/2);
        dtheta= 0.02; %degrees 0.02 is good
        % anglesamples=round(360/dtheta)+round(45/dtheta);
        anglesamples=round(360/dtheta);
        
        
        %"important", it is here the isocenter of rotation is assumed to be
        %exact middle of image, in theory if it was shifted from center
        %one could change below coordinates and everything would work smoothly
        %except radius size of transformation would have to be decreased
        xcenter=256.5;
        ycenter=256.5;
        %img=img'; %so if 2x2, [1,2] actually calls bottom left
        radimg=zeros(anglesamples,rsize);
        c=0;
        %debug=zeros(1,512*512);
        for rr=1:rsize
            for theta=1:anglesamples
                c=c+1;
                %         x=(rr-0.5)*cosd(dtheta*(theta-1)-22.5);
                %         y=(rr-0.5)*sind(dtheta*(theta-1)-22.5);
                x=(rr-0.5)*cosd(dtheta*(theta-1));
                y=(rr-0.5)*sind(dtheta*(theta-1));
                x1=floor(x+0.5)-0.5;
                x1ind=floor(x+0.5)+xcenter-0.5;
                x2=ceil(x+0.5)-0.5;
                x2ind=ceil(x+0.5)+xcenter-0.5;
                
                y1=floor(y+0.5)-0.5;
                y1ind=ycenter-(floor(y+0.5)-0.5);
                y2=ceil(y+0.5)-0.5;
                y2ind=ycenter-(ceil(y+0.5)-0.5);
                
                if (y1ind>imlength || y1ind <1 || y2ind>imlength || y2ind <1)
                    continue;
                end
                
                if (x1ind>imlength || x1ind <1 || x2ind>imlength || x2ind <1)
                    continue;
                end
                
                
                topmid=(img(x2ind,y2ind)-img(x1ind,y2ind))*(abs(x-x1))+img(x1ind,y2ind);
                
                lowmid=(img(x2ind,y1ind)-img(x1ind,y1ind))*(abs(x-x1))+img(x1ind,y1ind);
                radimg(theta,rr)=(topmid-lowmid)*(abs(y-y1))+lowmid;
                
                
            end
            %rr
        end
        
        %radimg(radimg>0.04)=0;
        %radimg(radimg<0.01)=0;
        
        %THE SEQUENCE
        % PASS 1: TURN OFF BELOW, TURN OFF 1:3=0
        %1:40
        
        %pass 2; turn on below, 1:140
        
        % for oc=1:rsize
        %     temp=radimg(:,oc);
        %     temp(temp<0.018)=mean(temp); %0.018 for mid
        %     temp(temp>0.023)=mean(temp);
        %     radimg(:,oc)=temp;
        %     s=1;
        % end
        
        %Creating image rings (right now strips in polar coordinate domain)
        %that contain just spike error
        smoothrad=zeros(anglesamples,rsize);
        for z=1:anglesamples
            temp=radimg(z,:);
            
            smoothrad(z,:)=medfilt1(temp,15);
        end
        
        
        
        
        newimg=zeros(imlength,imlength);
        %eradimg(:,1:22)=-0.0005;
        
        eradimg=radimg-smoothrad;
        % eradimg(:,160:256)=0;
        temp=zeros(anglesamples,rsize);
        %first cycle
        %YOU'VE GOT DARK STREAKS NOW ON PERIPHEREAL CORRECT THIS NEXT 9/18/18
        lr=140; %lr=135 for pass 2, 40 for pass 1
        
        %eradimg(eradimg>0.002)=0; %excellent for mid range
        
        % um=eradimg<0.024;
        % um2=eradimg>-0.024;
        % right=um.*um2;
        % eradimg=right.*eradimg;
        
        %eradimg=eradimg+temp;
        %eradimg(:,1:5)=0; %SHOULD DEFINITELY NOT HAVE TO DO THIS!
        %eradimg(:,40:rsize)=0; %for 1st pass
        %eradimg(:,1:40)=0; %removing first pass region
        %eradimg(:,1:135)=0; %removing second pass region %with some overlap
        %eradimg(:,lr:rsize)=0; %FOR MIDDLE
        %second cycle
        
        
        %2275 good for  small/mid... not outter tho
        aws=2275; %azumithal window size
        tempy=zeros(anglesamples+aws*2,1);
        for k=1:rsize
            tempy(aws+1:anglesamples+aws)=eradimg(:,k);
            tempy(1:aws)=eradimg(18000-aws+1:18000,k);
            tempy(anglesamples+aws+1:anglesamples+aws*2)=eradimg(1:aws,k);
            tempy=smooth(tempy,aws);
            eradimg(:,k)=tempy(aws+1:anglesamples+aws);
        end
        %Bilinear transformation from polar coordinates back to cartersian
        %here the error spike strips (in polar) are converte to the rings
        %that will be subtracted
        
        c=0;
        debug=zeros(1,imlength*imlength);
        for i=1:imlength
            for j=1:imlength
                c=c+1;
                x=i-xcenter;
                y=ycenter-j;
                r=sqrt(x*x+y*y);
                theta=atan2d(y,x);
                
                if (theta<0)
                    
                    theta=theta+360;
                end
                if (r>(rsize-0.5))
                    continue
                    
                end
                
                
                
                rind1=floor(r+0.5);
                rind2=ceil(r+0.5);
                %this part gets tricky
                
                
                
                thetaind1=floor((theta)/dtheta)+1;
                
                thetaind2=thetaind1+1;
                
                
                %          debug(c)=thetaind2-thetaind1;
                
                
                
                
                topthetamid=(eradimg(thetaind2,rind2)-eradimg(thetaind2,rind1))*(r-(rind1-0.5))+eradimg(thetaind2,rind1);
                lowthetamid=(eradimg(thetaind1,rind2)-eradimg(thetaind1,rind1))*(r-(rind1-0.5))+eradimg(thetaind1,rind1);
                newimg(i,j)=(topthetamid-lowthetamid)*(theta-((thetaind1-1)*dtheta))/dtheta+lowthetamid;
                
            end
        end
        
        %alpha
        
        %Emperical final window width calibration, error terms larger than
        %given range are from aggressive median filtering
        %it is here that this emperical intensity width window acts as an "edge
        %perserver"
        
        %newimg(newimg>0.001)=0;
        %newimg(newimg<0)=0;
        fimg(:,:,alpha)=img-newimg;
        
    end
%     iter
end
%TESTING THRESHOLD

%imshow(fimg(:,:,60),[-100 500])
fid=fopen(filename_output, 'w');
fwrite(fid, fimg, 'float32');  %for debugging
fclose(fid);

end
