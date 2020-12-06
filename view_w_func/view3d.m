function view3d(im,isoval,color)
%
% Function: view3d(img,isoval,color=[1,0.75,0.65])
%

if ~exist('color','var')
	color = [1,.75,.65];
end

hiso = patch(isosurface(im,isoval),'FaceColor',color, 'EdgeColor','none');
lighting phong;
lightangle(45,30);
lightangle(135,-40);
view(45,30)
axis tight
daspect([1,1,1])
