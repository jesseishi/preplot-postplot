function [f, axs] = preplot(n_rows, n_cols, opts)
%PREPLOT Initializes a figure with certain parameters, use together with
%postplot.
%   Preplot initializes a figure with a certain tiled layout, size,
%   interpreter, colororder/map, and more properties. It's only to avoid
%   repetitive code and to easily make beautiful plots.
%
%   Inputs:
%     n_rows: number of rows in the tiled layout _or_ 'flow' when wanting
%     to use the 'flow' option for TiledLayout.
%     n_cols: number of columns in the tiled layout.
%     opts.fnum: number that is assigned to the figure, handy when you're
%       prototyping a figure and don't want Matlab to create new figures
%       every time you call this function.
%     opts.TileSpacing: see TiledLayout.
%     opts.Padding: see TiledLayout.
%     opts.initializeAxes: initializes all the axes, this allows us to fix
%       some properties of those axes. But also causes other properties to
%       be 'locked in' so can sometimes lead to unexpected behaviour.
%     opts.hold: Initialize the axes with hold().
%     opts.grid: Initializes the axes with grid().
%     opts.XScale: Initializes the axes with a certain XScale.
%     opts.YScale: Initializes the axes with a certain XScale.
%     opts.sharex: Option to share x-axis properties among subplots.
%     opts.sharey: Option to share y-axis properties among subplots.
%     opts.interpreter: Default interpreter for all text objects. This
%       option is in preplot even though the font is in postplot because
%       when using Latex as an interpreter it'll only be applied after it
%       is set as an interpreter.
%     opts.colororder: Color order used for plotting lines.
%     opts.colormap: Colormap used for plotting surfaces (#endrainbow
%     https://www.fabiocrameri.ch/endrainbow/).
%
%   Outputs:
%     f: Figure handle.
%     axs: Array of initialized axes.
%
%   Example:
%     [f, axs] = preplot(2, 2, 'sharex', 'col', 'interpreter', 'latex')
%     -> Would create a 2x2 plot where the columns share the x axis limits
%     and ticks and where the plots in the first row have no x-axis labels.
%     Furthermore, all text objects that will be written in the figure will
%     be using Latex.
%
%   See also postplot, TiledLayout, colororder, colormap.

arguments
    n_rows = 1
    n_cols = 1
    opts.fnum = []  % Better if positional? So you can easily define it and not get a ton of plots when trying stuff out?
    opts.TileSpacing string = 'tight'
    opts.Padding string = 'tight'
    opts.initializeAxes logical = true
    opts.hold string = 'on'
    opts.grid string = 'on'
    opts.XScale string = 'linear'
    opts.YScale string = 'linear'
    opts.sharex string {mustBeMember(opts.sharex, ["none", "all", "row", "col"])} = "none"
    opts.sharey string {mustBeMember(opts.sharey, ["none", "all", "row", "col"])} = "none"
    opts.interpreter string = 'tex'
    opts.colororder = 'default'
    opts.colormap = 'default'  % Recommended: batlow, see https://www.fabiocrameri.ch/colourmaps
end

% Make the figure.
if opts.fnum
    f = figure(opts.fnum);
else
    f = figure;
end

% Set the default interpreter for everything.
set(f,'defaulttextInterpreter',opts.interpreter)
set(f,'defaultAxesTickLabelInterpreter',opts.interpreter);
set(f,'defaultLegendInterpreter',opts.interpreter);

% Use tiledlayout for subplots. Even for single plots this is nice because
% it creates a tight figure.
if strcmp(n_rows, 'flow')
    tiledlayout('flow',"TileSpacing",opts.TileSpacing,"Padding",opts.Padding);
    % InitializeAxes might be true, but is only possible if the amount of
    % axes is specified beforehand.
else
    tiledlayout(n_rows,n_cols,"TileSpacing",opts.TileSpacing,"Padding",opts.Padding);
    
    if opts.initializeAxes
        % Pre-make all the axes.
        axs = gobjects(n_rows, n_cols);
        for i = 1:n_rows
            for j = 1:n_cols
                axs(i,j) = nexttile;
                
                hold(axs(i,j), opts.hold)
                grid(axs(i,j), opts.grid)
                set(axs(i,j), 'XScale', opts.XScale)
                set(axs(i,j), 'YScale', opts.YScale)
                
                % Remove axes labels on all but the last axis when sharing
                % x or y axes.
                if any(strcmp(opts.sharex, ["all", "row", "col"]))
                    if i ~= n_rows
                        axs(i,j).XTickLabel = [];
                    end
                end
                if any(strcmp(opts.sharey, ["all", "row", "col"]))
                    if j ~= n_cols
                        axs(i,j).YTickLabel = [];
                    end
                end
            end
        end
    end
end


% Also link the limits and ticks when sharing axes.
hlink = [];
switch opts.sharex
    case 'all'
        hlink = [hlink, linkprop(axs, {'XLim', 'XTick'})];
    case 'row'
        for i = 1:n_cols
            hlink = [hlink, linkprop(axs(i, :), {'XLim', 'XTick'})];  %#ok
        end
    case 'col'
        for i = 1:n_rows
            hlink = [hlink, linkprop(axs(:, i), {'XLim', 'XTick'})];  %#ok
        end
end
switch opts.sharey
    case 'all'
        hlink = [hlink, linkprop(axs, {'YLim', 'YTick'})];
    case 'row'
        for i = 1:n_cols
            hlink = [hlink, linkprop(axs(i, :), {'YLim', 'YTick'})];  %#ok
        end
    case 'col'
        for i = 1:n_rows
            hlink = [hlink, linkprop(axs(:, i), {'YLim', 'YTick'})];  %#ok
        end
end
% The link objects must be saved, otherwise the links will be broken.
f.UserData = hlink;


% Set the color order and color map.
% #endrainbow (https://www.fabiocrameri.ch/endrainbow/)
colororder(opts.colororder)
colormap(opts.colormap)

end
