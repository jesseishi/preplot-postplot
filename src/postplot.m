function postplot(f, fileName, opts)
%POSTPLOT Finalize a figure with certain parameters, use together with
%preplot.
%   Postplot finalizes a figure by adjusting fonts, sharing x or y axes
%   labels and ticks, removing units from plotting with a timetable, and
%   more. It's only to avoid repetitive code and to easily make beautiful
%   plots.
%
%   Inputs:
%     f (matlab.ui.Figure): Current figure
%     fileName (string): Filename to store the figure, can include folders
%       where to store the figure (folders will be made if they don't exist
%       yet).
%     opts.width: Width of the figure.
%     opts.aspectRatio: Aspect ratio of the figure.
%     opts.figSizeUnits: Units for figure size adjustments.
%     opts.fontname: Name of the font to use, see listfonts to see which
%       fonts you have available.
%     opts.fontSize: Fontsize of all text in the figure.
%     opts.legendFontSize: If set, overrides opts.fontSize for legends.
%     opts.titleFontSize: If set, overrides opts.fontSize for titles.
%     opts.fontSizeUnits: Unit used for font size adjustments.
%     opts.removeTimetableUnit: When plotting with Timetables, Matlab will
%       by default put the time unit on the lower right, this removes that.
%     opts.lineWidth: Set the linewidth of all objects (lines, scatter,
%       patch, etc...) in a figure.
%
%   Example:
%     postplot(f, "Results/myPlot.pdf", "width", 10, "aspectRatio", 1.5,
%     "figSizeUnits", "centimeters", "fontname", "Arial", "fontSize", 12,
%     "removeTimetableUnit", true, "lineWidth", 2);
%     % Saves the figure `f` as a pdf in the results folder (will be
%     created if not existing yet) with a width of 10 cm and an aspect
%     ratio of 1.5. The font used is Arial with a font size of 12 points.
%     If a timetable is used, the time unit will be removed. All lines in
%     the figure will have a linewidth of 2.
%
%   See also preplot, linkaxes, fontsize, fontname, exportgraphics.

arguments
    f matlab.ui.Figure = gcf
    fileName string = []
    opts.width double = []
    opts.aspectRatio double = []
    opts.figSizeUnits string = []
    opts.fontname = 'default'
    opts.fontSize = 10
    opts.legendFontSize = []
    opts.titleFontSize = []
    opts.fontSizeUnits = 'points'
    opts.removeTimetableUnit logical = false
    opts.lineWidth = []
end

% Get all the axes.
axsUnordered = findobj(f, 'Type', 'axes');

% Set the size of the figure. Note that this is not 100% exact since any
% whitespace will be trimmed later when calling `exportgraphics` but it's
% quite close to perfect anyway.
if ~isempty(opts.figSizeUnits)
    f.Units = opts.figSizeUnits;
end
if ~isempty(opts.width)
    f.Position(3) =  opts.width;
end
if ~isempty(opts.aspectRatio)
    f.Position(4) = f.Position(3) / opts.aspectRatio;
end

% When doing timetable plots, Matlab automatically adds the time format at
% the end of the x-axis. If you don't like this, you can remove it here.
if opts.removeTimetableUnit
    for i = 1:length(axsUnordered)
        % Interestingly, this operation gets rid of it.
        axsUnordered(i).XAxis.TickLabels = axsUnordered(i).XAxis.TickLabels;
    end
end

% Adjust font size.
fontsize(f, opts.fontSize, opts.fontSizeUnits);
if opts.legendFontSize
    legends = findall(f, "Type", "legend");
    set(legends, "fontSize", opts.legendFontSize)
end
if opts.titleFontSize
    for i = 1:length(axsUnordered)
        fontsize(axsUnordered(i).Title, opts.titleFontSize, "points")
    end
end

% Set the default font for everything. Note that this does not work when
% having set the default interpreter to 'latex' in preplot because latex
% uses its own font.
if ~matches(opts.fontname, 'default')
    assert(ismember(opts.fontname, listfonts), 'Font "%s" not found (install it on your system and restart Matlab).', opts.fontname);
    fontname(f, opts.fontname);
end

% Set the line width.
if opts.lineWidth
    % Set the line width of all objects drawn inside the axes (lines,
    % patches, etc...)
    for i = 1:length(axsUnordered)
        objects = axsUnordered(i).Children;
        set(findall(objects, '-property', 'LineWidth'), 'LineWidth', opts.lineWidth);
    end
end

% Save the figure.
% ContentType="vector" -> the pdf includes embeddable fonts.
% BackGroundColor="None" -> Transparent background.
% Make the output folder if it doesn't exist yet.
if ~isempty(fileName)
    [filepath, ~, ext] = fileparts(fileName);
    if ~isfolder(filepath) && ~matches(filepath, "")
        mkdir(filepath)
    end
    switch ext
        case '.pdf'
            exportgraphics(f, fileName, 'ContentType', 'vector', 'BackGroundColor', 'None');
        case '.svg'
            saveas(f, fileName);
        otherwise
            exportgraphics(f, fileName);
    end
end

end
