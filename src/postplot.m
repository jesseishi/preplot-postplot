function links = postplot(f, fileName, opts)
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
%     opts.lineWidth: Set the linewidth of all lines in a figure.
%
%   Outputs:
%      links: When linking axes properties with sharex or sharey, the links
%        need to remain in the worksapce or they get lost, so we need to
%        return them.
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
    opts.fontname = 'default'
    opts.fontSize = 10
    opts.legendFontSize = []
    opts.titleFontSize = []
    opts.fontSizeUnit = 'points'
    opts.sharex logical = false
    opts.sharey logical = false
    opts.removeTimetableUnit logical = false
    opts.linkaxes = false  % Can be 'x', 'y', 'xy'.
    opts.lineWidth = []
end

% Get all the axes.
axsUnordered = findobj(f, 'Type', 'axes');
gridSize = f.Children.GridSize;  % Assumes that the plot was made with tiledlayout (through e.g. preplot).

% TODO: documentation and maybe refactor with a local function or so? This
% is a little bit of magic.
iLink = 1;
if opts.sharex || opts.sharey
    for i = 1:length(axsUnordered)
        ax = axsUnordered(i);
        [iCol, iRow] = ind2sub(flip(gridSize), ax.Layout.Tile);  % flip the gridsize nm because ind2sub is column-major but tiledlayout row-major by default.

        
        for j = 1:length(axsUnordered)
            ax2 = axsUnordered(j);
            [iCol2, iRow2] = ind2sub(flip(gridSize), ax2.Layout.Tile);  % flip the gridsize nm because ind2sub is column-major but tiledlayout row-major by default.
            
            if opts.sharex
                ax2AboveAx = (iRow2 + ax2.Layout.TileSpan(1) == iRow) && (iCol2 == iCol);
                equalSpanInX = ax2.Layout.TileSpan(2) == ax.Layout.TileSpan(2);
                if ax2AboveAx && equalSpanInX
                    ax2.XTickLabel = [];
                    ax2.XAxis.Label.String = [];

                    % Since we removed the x ticks, we need to make sure
                    % that the x limits of the two plots are now linked.
                    links(iLink) = linkprop([ax, ax2], 'XLim');  %#ok because we cannot predict how many links we'll create.
                    iLink = iLink + 1;
                    lim1 = get(ax, 'XLim');
                    lim2 = get(ax2, 'XLim');
                    xmin = min([lim1, lim2]);
                    xmax = max([lim1, lim2]);
                    xlim(ax, [xmin, xmax])
                    xticks(ax2, xticks(ax));
                end
            end
            if opts.sharey
                ax2LeftOfAx = (iCol2 + ax2.Layout.TileSpan(2) == iCol) && (iRow2 == iRow);
                equalSpanInY = ax2.Layout.TileSpan(1) == ax.Layout.TileSpan(1);
                if ax2LeftOfAx && equalSpanInY
                    ax.YTickLabel = [];
                    ax.YAxis.Label.String = [];

                    % Since we removed the y ticks, we need to make sure
                    % that the x limits of the two plots are now linked.
                    links(iLink) = linkprop([ax, ax2], 'YLim');  %#ok because we cannot predict how many links we'll create.
                    iLink = iLink + 1;
                    lim1 = get(ax, 'yLim');
                    lim2 = get(ax2, 'YLim');
                    ymin = min([lim1, lim2]);
                    ymax = max([lim1, lim2]);
                    ylim(ax, [ymin, ymax])
                    yticks(ax, yticks(ax2));
                end
            end
        end
    end
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

% Linking axes.
% Matlab can only handle a single function call to linkaxes before links
% are broken again. So I'm 'translating' the linkaxes commands to linkprop
% command, of which multiple can exists. However, the resulting links
% should remain in the Workspace of the user and are thus returned by
% postplot.
if opts.linkaxes
    linkaxes(axsUnordered, opts.linkaxes)
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
    if strcmp(ext, '.pdf')
        exportgraphics(f, fileName, 'ContentType', 'vector');
    else
        exportgraphics(f, fileName);
    end
end

end
