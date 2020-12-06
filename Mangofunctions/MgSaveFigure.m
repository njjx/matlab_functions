function MgSaveFigure(fig, filename)
% MgSaveAsPdf(fig, filename)
% This function save figure <fig> to a file (e.g. pdf) without white margin.
% fig: figure handle.
% filename: file name to be saved.


% get figure units
u = get(fig, 'units');

% set figure units to [inches]
set(fig, 'units', 'inches');

% get figure position
figPos = get(fig, 'Position');

% set paper size
set(fig, 'PaperUnits','inches',  'PaperPosition',[0, 0, figPos(3), figPos(4)],...
  'PaperSize',[figPos(3), figPos(4)]);

% save figure to file
saveas(fig, filename);

% set figure units back to u
set(fig, 'units', u);


end

