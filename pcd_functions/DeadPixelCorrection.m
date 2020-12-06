function OutputImage=DeadPixelCorrection(InputImage)
%OutputImage=DeadPixelCorrection(InputImage)
%InputImage is 5120 x 64
DeadPixelIndex=importdata('deadpixel.txt');
OutputImage=InputImage;
for idx=1:size(DeadPixelIndex,1)
    RowIdx=DeadPixelIndex(idx,1);
    ColIdx=DeadPixelIndex(idx,2);
    if RowIdx==1286 && RowIdx==3
        OutputImage(RowIdx,ColIdx)=1/2*(InputImage(RowIdx-1,ColIdx)+OutputImage(RowIdx+1,ColIdx));
    elseif        RowIdx==1286 && RowIdx==4
        OutputImage(RowIdx,ColIdx)=1/2*(InputImage(RowIdx-1,ColIdx)+OutputImage(RowIdx+2,ColIdx));
    elseif        RowIdx==1287 && RowIdx==4
        OutputImage(RowIdx,ColIdx)=1/2*(InputImage(RowIdx,ColIdx-1)+OutputImage(RowIdx,ColIdx+1));
    elseif        ColIdx>=4 &&ColIdx<=61
        OutputImage(RowIdx,ColIdx)=mean2(InputImage(RowIdx-1:RowIdx+1,ColIdx-1:ColIdx+1));
    else
        OutputImage(RowIdx,ColIdx)=1/2*(InputImage(RowIdx-1,ColIdx)+OutputImage(RowIdx+1,ColIdx));
    end
end
OutputImage(OutputImage==0)=1;
