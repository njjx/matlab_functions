function img_corr=XuThorBadPixelCorr(img)
%img_corr=XuThorDeadPixelCorr(img)

pos=importdata('bad_pixel_coor.txt');

img_corr=img;

for idx=1:size(pos,1)
    Y=pos(idx,1);
    X=pos(idx,2);
    img_corr(X,Y)=1/4*(img_corr(X+1,Y)+img_corr(X,Y+1)+img_corr(X-1,Y)+img_corr(X,Y-1));
end

%% correction  for two 3x3 dead pixel blocks
for col_idx=86:88
    for row_idx=877:879
        img_corr(row_idx,col_idx)=(row_idx-876)*img_corr(880,col_idx)+...
            (880-row_idx)*img_corr(876,col_idx)+(col_idx-85)*img_corr(row_idx,89)+...
            +(89-col_idx)*img_corr(row_idx,85);
        img_corr(row_idx,col_idx)=img_corr(row_idx,col_idx)/8;
    end
end

for col_idx=361:363
    for row_idx=351:353
        img_corr(row_idx,col_idx)=(row_idx-350)*img_corr(354,col_idx)+...
            (354-row_idx)*img_corr(350,col_idx)+(col_idx-360)*img_corr(row_idx,364)+...
            +(364-col_idx)*img_corr(row_idx,360);
        img_corr(row_idx,col_idx)=img_corr(row_idx,col_idx)/8;
    end
end

