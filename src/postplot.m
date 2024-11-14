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
%     opts.fontname: Name of the font to use, see listfonts to see which
%       fonts you have available.
%     opts.fontSize: Fontsize of all text in the figure.
%     opts.legendFontSize: If set, overrides opts.fontSize for legends.
%     opts.titleFontSize: If set, overrides opts.fontSize fot titles.
%     opts.fontSizeUnit: Unit used for font size adjustments.
%     opts.linkaxes: Link limits of all axes, can be 'x', 'y', 'xy'.
%     opts.sharex: Removes the x ticks and labels of upper plots and links
%       x limits.
%     opts.sharey: Removes the y ticks and labelf of right plots and links
%       y limits.
%     opts.removeTimetableUnit: When plotting with Timetables, Matlab will
%       by default put the time unit on the lower right, this removes that.
%     opts.lineWidth: Set the linewidth of all objects (lines, scatter, 
%       patch, etc...) in a figure.
%
%   Example:
%     [f, axs] = preplot(2, 1)
%     plot(axs(1), x1, y1)
%     plot(axs(2), x2, y2)
%     postplot(f, "Results/test.pdf", "fontname", "NimbusRomNo9L",
%     "fontSize", 10, "Sharex", true)
%     -> Initializes a figure with preplot, plots on it, changes the font,
%     fontsize, and removes the xticklabels and xlabel of axs(1) before
%     saving it as 'test.pdf' in the folder 'Results'.
%
%   See also preplot, linkaxes, fontsize, fontname, exportgraphics.

arguments
    f matlab.ui.Figure = gcf
    fileName string = []
    opts.paperFormat string = []
    opts.column int8 = 1
    opts.lineFrac double = 1.0
    opts.aspectRatio double = 4/3
    opts.fontname = 'default'
    opts.fontSize = 10
    opts.legendFontSize = []
    opts.titleFontSize = []
    opts.fontSizeUnit = 'points'
    opts.removeTimetableUnit logical = false
    opts.lineWidth = []
end

% Get all the axes.
axsUnordered = findobj(f, 'Type', 'axes');
gridSize = f.Children.GridSize;  % Assumes that the plot was made with tiledlayout (through e.g. preplot).

% Change the default size of the figure if specified by the user through
% paperFormat, column, lineFrac, and aspectRatio.
if ~isempty(opts.paperFormat)
    switch opts.paperFormat
        case "NAWEA"
            % 6.5 inch line width.
            f.Units = 'inches';
            basewidth = 6.5;
        case "ppt"
            % Widescreen ppt format (16:9)
            f.Units = 'centimeters';
            basewidth = 33.867;
        case "WES"
            % I can't really find what it officially is so I just measured it.
            f.Units = 'inches';
            if opts.column == 1
                basewidth = 3.35;
            elseif opts.column == 2
                basewidth = 7;
            else
                error('Not configures for column = %i', opts.column)
            end
        case 'ACC'
            f.Units = 'inches';
            if opts.column == 1
                basewidth = 3.41;
            elseif opts.column == 2
                basewidth = 7;
            else
                error('Not configured for column = %i', opts.column);
            end
        case "iop"  % Also Torque
            f.Units = 'centimeter';
            basewidth = 16;
            if opts.column == 2
                error('Column == 2 not available for iop or Torque.')
            end
        otherwise
            error('paperFormat %s is unknown to me', opts.paperFormat)
    end
    width = basewidth * opts.lineFrac;
    height = width / opts.aspectRatio;
    f.Position = [1, 1, width, height];
end

% When doing timetable plots (which I like and often do), Matlab
% automatically adds the time format at the end of the x-axis. I don't like
% this because I just want to show the unit of time in the x-label. So
% remove those.
if opts.removeTimetableUnit
    for i = 1:length(axsUnordered)
        % Interestingly, this operation gets rid of it.
        axsUnordered(i).XAxis.TickLabels = axsUnordered(i).XAxis.TickLabels;
    end
end

% Adjust font size
fontsize(f, opts.fontSize, opts.fontSizeUnit);
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
    set(findall(f, 'Type', 'Line'),'LineWidth',opts.lineWidth)
end

% Save the figure.
% ContentType="vector" -> the pdf included embeddable fonts.
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
