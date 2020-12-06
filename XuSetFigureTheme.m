function r = MgSetFigureTheme(theme)
% Set the theme of figure, such as "dark"
% theme: string, the name of theme, i.e. "dark"

if theme == "dark"
    colors = [255, 233, 0;
        127, 237, 54;
        255, 0, 59;
        0, 208, 255;
        161, 0, 255;
        255, 153, 0;
        0, 255, 237;
        0, 255, 161;
        238, 0, 255;
        
        240, 196, 25;
        78, 186, 111;
        241, 90, 90;
        45, 149, 191;
        149, 91, 165]/255;
    
    %Change default axes fonts.
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 16)
    
    %Change default text fonts.
    set(0,'DefaultTextFontname', 'Arial')
    set(0,'DefaultTextFontSize', 16)
    set(groot, 'DefaultFigureColor', 'black');
    set(groot, 'DefaultFigureInvertHardcopy', 'off');
    set(groot, 'DefaultAxesColor', 'black');
    set(groot, 'DefaultTextColor', 'white');
    
    set(groot, 'DefaultAxesColorOrder', colors);
    set(groot, 'DefaultLineLineWidth', 2);
    
    %     set(groot, 'DefaultTextInterpreter', 'LaTeX');
    %     set(groot, 'DefaultAxesTickLabelInterpreter', 'LaTeX');
    %     set(groot, 'DefaultAxesFontName', 'LaTeX');
    %     set(groot, 'DefaultLegendInterpreter', 'LaTeX');
    
    set(groot, 'DefaultAxesXColor', 'white');
    set(groot, 'DefaultAxesYColor', 'white');
    set(groot, 'DefaultAxesZColor', 'white');
    %set(gca,'GridColor','white');
    
    
elseif theme == "default"
    
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 20)
    
    %Change default text fonts.
    set(0,'DefaultTextFontname', 'Arial')
    set(0,'DefaultTextFontSize', 20)
    
    set(groot, 'DefaultAxesColor', 'remove');
    set(groot, 'DefaultFigureColor', 'remove');
    set(groot, 'DefaultFigureInvertHardcopy', 'remove');
    
    set(groot, 'DefaultAxesColorOrder', 'remove');
    set(groot, 'DefaultLineLineWidth', 'remove');
    
    set(groot, 'DefaultAxesXColor', 'remove');
    set(groot, 'DefaultAxesYColor', 'remove');
    set(groot, 'DefaultAxesZColor', 'remove');
    
    set(groot, 'DefaultTextColor', 'remove');
elseif  theme == "defaultrm"
    
    set(0,'DefaultAxesFontName', 'times new roman')
    set(0,'DefaultAxesFontSize', 20)
    
    %Change default text fonts.
    set(0,'DefaultTextFontname', 'times new roman')
    set(0,'DefaultTextFontSize', 20)
    
    set(groot, 'DefaultAxesColor', 'remove');
    set(groot, 'DefaultFigureColor', 'remove');
    set(groot, 'DefaultFigureInvertHardcopy', 'remove');
    
    set(groot, 'DefaultAxesColorOrder', 'remove');
    set(groot, 'DefaultLineLineWidth', 'remove');
    
    set(groot, 'DefaultAxesXColor', 'remove');
    set(groot, 'DefaultAxesYColor', 'remove');
    set(groot, 'DefaultAxesZColor', 'remove');
    
    set(groot, 'DefaultTextColor', 'remove');
else
    fprintf("Do not have theme '%s', only have 'dark' and 'default' and 'defaultrm'.\n");
end

r = groot;
end

