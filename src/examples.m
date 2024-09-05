%% Setup
% This assumes that the working directory is preplot-postplot.
close all; clearvars; clc;
addpath('src')

%% Simple example.
preplot();
plot(1:10)
postplot()


%% With some customization.
colors = [0.15, 0.34, 0.43;
          0.42, 0.76, 0.61];
[f, axs] = preplot(2, 1, 'paperFormat', 'WES', 'column', 2, ...
    'lineFrac', 0.9, 'aspectRatio', 1.5, 'colororder', colors, ...
    'interpreter', 'latex');

x = linspace(0, 5, 1e5);
plot(axs(1), x, [sin(x); cos(x)])
plot(axs(2), x, [log10(x); log(x)])
ylabel(axs(1), '$$\alpha$$')
ylabel(axs(2), '$$\beta$$')
xlabel(axs(2), 'Time (s)')

postplot(f, 'Images/test.pdf', 'fontSize', 16, 'legendFontSize', 14, ...
    'sharex', true, 'lineWidth', 3);


%% Control plots.
% Plots from the control toolbox don't work together with TiledLayout and
% are difficult to customize, so this toolbox also provides custom control
% plotting commands.
[f, axs] = preplot(2, 2);
axBig = nexttile(2, [2,1]);

sys = tf(4, [1, 0.7, 4]);
mbode(sys, axs(1,1), axs(2,1))
mnyquist(sys, axBig, 'w', logspace(-1, 2, 1e3))
xlim(axBig, [-2, 2])

postplot(f, 'sharex', true, 'linewidth', 1, 'fontname', 'NimbusRomNo9L');


%% Logarithmic plot
% Does not work:
% f = preplot();
% loglog(1:10)
% DO:
preplot('YScale', 'log', 'XScale', 'log');
plot(1:10)

% Or:
preplot('hold', 'off');
loglog(1:10)


%% Example plot for README.
colors = [0.15, 0.34, 0.43;
          0.42, 0.76, 0.61];
[f, axs] = preplot(2, 1, 'paperFormat', 'WES', 'column', 1, ...
    'aspectRatio', 1.2, 'colororder', colors, 'interpreter', 'latex');

sys1 = tf(4, [1, 0.7, 4]);
sys2 = tf([1, 0.1, 4], [1, 1, 4]);
mbode([sys1, sys2], axs(1,1), axs(2,1))
ylim(axs(1), [-40, 20])

postplot(f, 'Images/example.png', 'fontname', 'NimbusRomNo9L', ...
    'fontSize', 10, 'legendFontSize', 8, 'sharex', true, 'lineWidth', 2);