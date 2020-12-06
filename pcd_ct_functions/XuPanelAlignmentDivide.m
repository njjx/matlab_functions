function SinogramC=PanelAlignment(Sinogram,viewNum,detectorPanelWidth,panelIdxBegin,panelIdxEnd,bad_width,interpIndex)
%SinogramC=PanelAlignment(Sinogram,viewNum,detectorPanelWidth,panelIdxBegin,panelIdxEnd,bad_width,interpIndex)
SinogramC=Sinogram;
for PanelIdx=[panelIdxBegin:panelIdxEnd]
    BoundaryLeftMost=(PanelIdx-1)*detectorPanelWidth+bad_width+1;
    BoundaryLeft=PanelIdx*detectorPanelWidth-bad_width;
    BoundaryRight=PanelIdx*detectorPanelWidth+bad_width;
    BoundaryRightMost=(PanelIdx+1)*detectorPanelWidth-bad_width-1;
    
    MeanTemp=mean(SinogramC(:,1:viewNum),2);
    TempLeft=MeanTemp(BoundaryLeft-interpIndex:BoundaryLeft-1);
    TempRight=MeanTemp(BoundaryLeft:BoundaryLeft+interpIndex);
    PLeft=polyfit([BoundaryLeft-interpIndex:BoundaryLeft-1],TempLeft',1);
    PRight=polyfit([BoundaryLeft:BoundaryLeft+interpIndex],TempRight',1);
    LeftVal=polyval(PLeft,BoundaryLeft);
    RightVal=polyval(PRight,BoundaryLeft);
    
    if RightVal>2
        SinogramC(BoundaryLeft:BoundaryRight,:)=SinogramC(BoundaryLeft:BoundaryRight,:)*LeftVal/RightVal;
    else
        SinogramC(BoundaryLeft:BoundaryRight,:)=SinogramC(BoundaryLeft:BoundaryRight,:)+LeftVal-RightVal;
    end
    
    
    
    MeanTemp=mean(SinogramC(:,1:viewNum),2);
    TempLeft=MeanTemp(BoundaryRight-interpIndex:BoundaryRight);
    TempRight=MeanTemp(BoundaryRight+1:BoundaryRight+interpIndex);
    PLeft=polyfit([BoundaryRight-interpIndex:BoundaryRight],TempLeft',1);
    PRight=polyfit([BoundaryRight+1:BoundaryRight+interpIndex],TempRight',1);
    LeftVal=polyval(PLeft,BoundaryRight);
    RightVal=polyval(PRight,BoundaryRight);
    
    if RightVal>2
        SinogramC(BoundaryRight+1:BoundaryRightMost,:)=...
            SinogramC(BoundaryRight+1:BoundaryRightMost,:)*LeftVal/RightVal;
    else
        SinogramC(BoundaryRight+1:BoundaryRightMost,:)=...
            SinogramC(BoundaryRight+1:BoundaryRightMost,:)+LeftVal-RightVal;
    end
    
    
    %this is a linear interpolation process in order not to change the
    %rightmost val
%     Correction=((BoundaryRight+1:BoundaryRightMost)-BoundaryRightMost)/(BoundaryRightMost-BoundaryRight-1)*(-1)*(LeftVal-RightVal);
%     SinogramC(BoundaryRight+1:BoundaryRightMost,:)=SinogramC(BoundaryRight+1:BoundaryRightMost,:)+repmat(Correction',[1,size(Sinogram,2)]);
end