function status = XuSaveFigureToPNG(width,height,s_name)
%status = XuSaveFigureToPNG(width,height,s_name)
figuresize(width,height,'centimeters');
saveas(gcf,s_name,'png')