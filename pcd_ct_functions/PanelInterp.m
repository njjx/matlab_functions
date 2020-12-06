function SinogramC=PanelInterp(Sinogram,viewNum, Width,detectorPanelWidth,panelIdxBegin,panelIdxEnd,bad_width)
%SinogramC=PanelInterp(Sinogram,viewNum, Width,detectorPanelWidth,panelIdxBegin,panelIdxEnd,bad_width)
%Width:total detector pixel in a row of a detector (5120 for hydra)
SinogramC=Sinogram;
%define bad pixel width in the panel connection area
bad_points=[];
for idx=[panelIdxBegin:panelIdxEnd]
    bad_points=[bad_points detectorPanelWidth*(idx)-bad_width:detectorPanelWidth*(idx)+bad_width];
end
good_points=1:Width;
good_points(bad_points)=[];

for frameidx=1:viewNum
    temp=SinogramC(:,frameidx);
    temp(bad_points)=interp1(good_points,SinogramC(good_points,frameidx),bad_points,'linear');
    temp=smooth(temp,5,'moving');
    SinogramC(bad_points,frameidx)=interp1(good_points,temp(good_points),bad_points,'linear');
end