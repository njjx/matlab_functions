function r = MgSetFigureTheme(theme)
% Set the theme of figure, such as "dark"
% theme: string, the name of theme, includes:
% dark: black background, for presentation,
% white: white background, for journal paper,
% default: default setup.

if theme == "dark"
    colors = [255, 255, 255;        % white
        255, 192, 0;                % orange
        0, 191, 191;                % dark teal
        191, 0, 191;                % purple
        0, 191, 0;                  % Green
        
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
   
    set(groot, 'DefaultTextFontSize', 16);
    set(groot, 'DefaultAxesFontSize', 16);
    
elseif theme == "white"
    set(groot, 'DefaultAxesColor', 'remove');
    set(groot, 'DefaultFigureColor', 'remove');
    set(groot, 'DefaultFigureInvertHardcopy', 'remove');
    
    set(groot, 'DefaultAxesColorOrder', 'remove');
    set(groot, 'DefaultLineLineWidth', 1.2);
    
    set(groot, 'DefaultTextInterpreter', 'remove');
    set(groot, 'DefaultAxesTickLabelInterpreter', 'remove');
    set(groot, 'DefaultAxesFontName', 'remove');
    set(groot, 'DefaultLegendInterpreter', 'remove');
    
    set(groot, 'DefaultAxesXColor', 'remove');
    set(groot, 'DefaultAxesYColor', 'remove');
    set(groot, 'DefaultAxesZColor', 'remove');
    
    set(groot, 'DefaultTextColor', 'remove');
    
    set(groot, 'DefaultTextFontSize', 13);
    set(groot, 'DefaultAxesFontSize', 13);
    
    set(groot, 'DefaultTextFontName', 'Times New Roman');
    set(groot, 'DefaultAxesFontName', 'Times New Roman');
    
    
elseif theme == "default"
    set(groot, 'DefaultAxesColor', 'remove');
    set(groot, 'DefaultFigureColor', 'remove');
    set(groot, 'DefaultFigureInvertHardcopy', 'remove');
    
    set(groot, 'DefaultAxesColorOrder', 'remove');
    set(groot, 'DefaultLineLineWidth', 'remove');
    
    set(groot, 'DefaultTextInterpreter', 'remove');
    set(groot, 'DefaultAxesTickLabelInterpreter', 'remove');
    set(groot, 'DefaultAxesFontName', 'remove');
    set(groot, 'DefaultLegendInterpreter', 'remove');
    
    set(groot, 'DefaultAxesXColor', 'remove');
    set(groot, 'DefaultAxesYColor', 'remove');
    set(groot, 'DefaultAxesZColor', 'remove');
    
    set(groot, 'DefaultTextColor', 'remove');
    
    set(groot, 'DefaultTextFontSize', 'remove');
    set(groot, 'DefaultAxesFontSize', 'remove');
else
    fprintf("Do not have theme '%s', only have 'dark' and 'default'.\n", theme);    
end

r = groot;
end

