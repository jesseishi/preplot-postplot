function mnyquist(sys, ax, opts)
%MNYQUIST Summary of this function goes here
%   Detailed explanation goes here
arguments
    sys
    ax = gca
    opts.w = []
    opts.lineSpec = '-'
    opts.plotNegativeFrequencies logical = true
    opts.plotMinusOne logical = true
    opts.plotUnitCircle logical = true
    opts.plotXYGrid logical = true
    opts.grid = 'off'
    opts.setAxesLabels logical = true
    opts.verbose logical = false
end

% Set hold to on but return to what it was after plotting.
oldHoldState = ishold(ax);
hold(ax, 'on');

if isempty(opts.w)
    [H, ~] = freqresp(sys);
else
    [H, ~] = freqresp(sys, opts.w);
end

% Form H such that we get the positive and negative frequencies.
H = squeeze(H);
if opts.plotNegativeFrequencies
    Hconj = conj(H);
    % TODO: draw a complete line, but this doesn't work in all cases yet I
    % think.
    Hround = [H; Hconj(end:-1:1)];
    if norm(H(1) - Hconj(1)) < 1e-2
        Hround = [Hround; H(1)];
    end
end
% Don't plot here to get ideal plot order.
% plot(ax, Hround, opts.lineSpec)

% Plot additional helper things.
colorOrderIndex = get(ax, 'ColorOrderIndex');

grid(ax, opts.grid);
if opts.plotXYGrid
    if opts.verbose
        disp('plotting xy grid')
    end
    % x/yline creates a ConstantLine which interferes with the plotting 
    % order so that the red + at (1, 0) don't appear above this line. In 
    % R2024A you can set the 'Layer' property of x/yline which I hope 
    % should solve this.
    release = version('-release');
    year = str2double(release(1:end-1));
    if year >= 2024
        h = xline(0, ':', 'Layer', 'bottom');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        h = yline(0, ':', 'Layer', 'bottom');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    else
        % Crappy pre R2024A solution.
        x = 0;
        y = 0;
        grey = [0.3, 0.3, 0.3];
        xl = plot([x,x], ylim(ax), ':', 'Color', grey);
        xl.Annotation.LegendInformation.IconDisplayStyle = 'off';
        yl = plot(xlim(ax), [y,y], ':', 'Color', grey);
        yl.Annotation.LegendInformation.IconDisplayStyle = 'off';
        ax.XAxis.LimitsChangedFcn = @(ruler,~)set(xl, 'YData', ylim(ancestor(ruler,'axes')));
        ax.YAxis.LimitsChangedFcn = @(ruler,~)set(yl, 'XData', xlim(ancestor(ruler,'axes')));
    end
end
if opts.plotUnitCircle
    if opts.verbose
        disp('plotting unit circle')
    end
    theta = linspace(0, 2*pi, 1e2);
    x = cos(theta);
    y = sin(theta);
    h = plot(x, y, '-.', 'Color', [0.3, 0.3, 0.3]);
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
% This (in my opinion) is the ideal plot order so that the Nyquist line is
% in front of all the grids but below the red +.
set(ax, 'ColorOrderIndex', colorOrderIndex);
plot(ax, Hround, opts.lineSpec)
if opts.verbose
    disp('plotting Hround')
end
if opts.plotMinusOne
    if opts.verbose
        disp('plotting -1')
    end
    h = scatter(-1, 0, 'r+');
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

% Reset the color index so that the helper lines don't cause the color
% order to be off.
set(ax, 'ColorOrderIndex', colorOrderIndex+1);

% Set axes labels.
if opts.setAxesLabels
    xlabel(ax, 'Real axis')
    ylabel(ax, 'Imaginary axis')
end

if oldHoldState
    hold(ax, 'on')
else
    hold(ax, 'off')
end

end

