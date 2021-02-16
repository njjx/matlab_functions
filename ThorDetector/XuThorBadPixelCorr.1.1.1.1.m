function img=XuThorBadPixelCorr(img)
%img_corr=XuThorDeadPixelCorr(img)

pos=importdata('bad_pixel_coor.txt');

for idx=1:size(pos,1)
    Y=pos(idx,1);
    X=pos(idx,2);
    img(X,Y)=1/4*(img(X+1,Y)+img(X,Y+1)+img(X-1,Y)+img(X,Y-1));
end

%% correction  for two 3x3 dead pixel blocks
for col_idx=86:88
    for row_idx=877:879
        img(row_idx,col_idx)=(row_idx-876)*img(880,col_idx)+...
            (880-row_idx)*img(876,col_idx)+(col_idx-85)*img(row_idx,89)+...
            +(89-col_idx)*img(row_idx,85);
        img(row_idx,col_idx)=img(row_idx,col_idx)/8;
    end
end

for col_idx=361:363
    for row_idx=351:353
        img(row_idx,col_idx)=(row_idx-350)*img(354,col_idx)+...
            (354-row_idx)*img(350,col_idx)+(col_idx-360)*img(row_idx,364)+...
            +(364-col_idx)*img(row_idx,360);
        img(row_idx,col_idx)=img(row_idx,col_idx)/8;
    end
end

