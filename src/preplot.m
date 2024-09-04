function [f, axs] = preplot(n_rows, n_cols, opts)
%PREPLOT Initializes a figure with certain parameters, use together with
%postplot.
%   Preplot initializes a figure with a certain tiled layout, size,
%   interpreter, colororder/map, and more properties. It's only to avoid
%   repetitive code and to easily make beautiful plots.
%
%   Inputs:
%     n_rows (int): number of rows in the tiled layout _or_ 'flow' when
%       wanting to use the 'flow' option for TiledLayout.
%     n_cols (int): number of columns in the tiled layout.
%     opts.fnum (int): number that is assigned to the figure, handy when you're
%       prototyping a figure and don't want Matlab to create new figures
%       every time you call this function.
%     opts.paperFormat (string): format of the paper (typically a
%       publication outlet) which sets the width available for the figure.
%     opts.column (int): Some publication outlets have the option to
%       specify whether the figure should fit on a single or double-column.
%     opts.lineFrac (double): Fraction of the available width that the
%       figure should occupy.
%     opts.aspectRatio (double): aspect ratio of the figure.
%     opts.TileSpacing: see TiledLayout.
%     opts.Padding: see TiledLayout.
%     opts.initializeAxes (logical): initializes all the axes, this allows
%       us to fix some properties of those axes. But also causes other
%       properties to be 'locked in' so can sometimes lead to unexpected
%       behaviour.
%     opts.hold: Initialize the axes with hold().
%     opts.grid: Initializes the axes with grid().
%     opts.XScale: Initializes the axes with a certain XScale.
%     opts.YScale: Initializes the axes with a certain XScale.
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
%     [f, axs] = preplot(2, 1, 'paperFormat', 'WES', 'column', 2,
%     'lineFrac', 0.8, 'aspectRatio', 1.2)
%     -> Would create a 2x1 plot that would occupy 80% of the double-column
%     width in the Wind Energy Science Journal and have an aspect ratio of
%     1.2.
%
%   See also postplot, TiledLayout, colororder, colormap.

arguments
    n_rows = 1  % Can also be 'flow' to use the flow tiledlayout.
    n_cols = 1
    opts.fnum = []  % Better if positional? So you can easily define it and not get a ton of plots when trying stuff out?
    opts.paperFormat string = []
    opts.column int8 = 1
    opts.lineFrac double = 1.0
    opts.aspectRatio double = 4/3
    opts.TileSpacing string = 'tight'
    opts.Padding string = 'tight'
    opts.initializeAxes logical = true
    opts.hold string = 'on'
    opts.grid string = 'on'
    opts.XScale string = 'linear'
    opts.YScale string = 'linear'
    opts.interpreter string = 'tex'
    opts.colororder = 'default'
    opts.colormap = 'default'    % Recommended: batlow
end

% Make the figure.
if opts.fnum
    f = figure(opts.fnum);
else
    f = figure;
end

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
            end
        end
    end
end

% Set the default interpreter for everything.
set(f,'defaulttextInterpreter',opts.interpreter)
set(f,'defaultAxesTickLabelInterpreter',opts.interpreter);
set(f,'defaultLegendInterpreter',opts.interpreter);

% Set the color order and color map.
% #endrainbow (https://www.fabiocrameri.ch/endrainbow/)
colororder(opts.colororder)
colormap(opts.colormap)

% % Set the outputs.
% varargout = cell(nargout, 1);
% if nargout > 0
%     varargout{1} = f;
%     varargout{2} = tl;
% end
% 
% if nargout == 3
%     if length(axs) == 1
%         varargout{3} = axs(1);
%     else
%         varargout{3} = axs;
%     end
% elseif nargout > 3
%     % Note, only possible when axes are pre-made (so without 'flow' for
%     % tiledlayout).
%     assert(n_rows*n_cols == nargout-2, "I want to return [fig, tl, ax1, ax2, etc...] with %i axes, but only got %i ", n_rows*n_cols, nargout-2);
% 
%     for i = 1:nargout-2
%         varargout{i+2} = axs(i);
%     end
% end


end
