function SinogramC=XuPanelAlignmentWithoutSymmetry(Sinogram,viewNum,detectorPanelWidth,panelIdxBegin,panelIdxEnd,bad_width,interpIndex)
%SinogramC=XuPanelAlignmentWithoutSymmetry(Sinogram,viewNum,detectorPanelWidth,panelIdxBegin,panelIdxEnd,bad_width,interpIndex)
SinogramC=Sinogram;
for PanelIdx=[panelIdxBegin:panelIdxEnd]
    BoundaryLeft=PanelIdx*detectorPanelWidth-bad_width;
    BoundaryMiddle=PanelIdx*detectorPanelWidth;
    BoundaryRight=PanelIdx*detectorPanelWidth+bad_width;
    BoundaryRightMost=(PanelIdx+1)*detectorPanelWidth-bad_width-1;
    
    MeanTemp=mean(SinogramC(:,1:viewNum),2);
    TempLeft=MeanTemp(BoundaryLeft-interpIndex:BoundaryLeft-1);
    TempRight=MeanTemp(BoundaryRight+1:BoundaryRight+interpIndex);
    PLeft=polyfit([BoundaryLeft-interpIndex:BoundaryLeft-1],TempLeft',1);
    PRight=polyfit([BoundaryRight+1:BoundaryRight+interpIndex],TempRight',1);
    LeftVal=polyval(PLeft,BoundaryMiddle);
    RightVal=polyval(PRight,BoundaryMiddle);
    
    %this is a linear interpolation process in order not to change the
    %rightmost val
    
    if LeftVal<0.1
        Correction=linspace((RightVal-LeftVal),0,BoundaryRightMost-BoundaryRight);
        SinogramC(BoundaryRight+1:BoundaryRightMost,:)=SinogramC(BoundaryRight+1:BoundaryRightMost,:)-repmat(Correction',[1,size(Sinogram,2)]);
    else
        Correction=linspace(RightVal/LeftVal,1,BoundaryRightMost-BoundaryRight);
        SinogramC(BoundaryRight+1:BoundaryRightMost,:)=SinogramC(BoundaryRight+1:BoundaryRightMost,:)./repmat(Correction',[1,size(Sinogram,2)]);
    end
end