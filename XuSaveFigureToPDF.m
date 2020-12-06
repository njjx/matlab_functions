function status = XuSaveFigureToPDF(width,height,s_name)
%status = XuSaveFigureToPDF(width,height,s_name)
figuresize(width,height,'centimeters');
saveas(gcf,s_name,'pdf')