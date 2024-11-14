%% Setup
% This assumes that the working directory is preplot-postplot (but also
% works if it is src).
close all; clearvars; clc;
addpath('src')


%% Simple example.
preplot();
plot(1:10)
postplot();


%% With some customization.
colors = [0.15, 0.34, 0.43;
    0.42, 0.76, 0.61];
[f, axs] = preplot(2, 1, 'sharex', 'all', 'interpreter', 'latex', ...
    'colororder', colors);

x = linspace(0, 5, 1e5);
plot(axs(1), x, [sin(x); cos(x)])
plot(axs(2), x, [log10(x); log(x)])
ylabel(axs(1), '$\alpha$')
ylabel(axs(2), '$\beta$')
xlabel(axs(2), 'Time (s)')

postplot(f, 'Images/test.pdf', 'width', 5, 'figSizeUnits', 'inches', ...
    'aspectRatio', 1.5, 'fontSize', 16, 'legendFontSize', 14, ...
    'lineWidth', 3);
% We can also save the same plot twice in different sizes, for example when
% you want to use it in a presentation and a paper.
postplot(f, 'Images/test2.pdf', 'width', 10, 'figSizeUnits', 'inches', ...
    'aspectRatio', 1.5, 'fontSize', 20, 'legendFontSize', 16, ...
    'lineWidth', 5);


%% Control plots
% Plots from the control toolbox don't work together with TiledLayout and
% are difficult to customize, so this toolbox also provides custom control
% plotting commands.
[f, axs] = preplot(2, 2, 'sharex', 'all');
axBig = nexttile(2, [2,1]);

sys = tf(4, [1, 0.7, 4]);
mbode(sys, axs(1,1), axs(2,1))

mnyquist(sys, axBig, 'w', logspace(-1, 2, 1e3))
xlim(axBig, [-2, 2])

postplot(f, 'linewidth', 1, 'fontname', 'Times New Roman');


%% Logarithmic plot
% Does not work:
% f = preplot();
% loglog(1:10)
% DO:
preplot('YScale', 'log', 'XScale', 'log', 'interpreter', 'latex');
plot(1:10)

% Or:
preplot('initializeAxes', false, 'interpreter', 'latex');
ax = nexttile;
loglog(ax, 1:10)


%% Example plot for README.
colors = [0.15, 0.34, 0.43;
    0.42, 0.76, 0.61];
[f, axs] = preplot(2, 1, 'colororder', colors, 'interpreter', 'latex', ...
    'sharex', 'all');

sys1 = tf(4, [1, 0.7, 4]);
sys2 = tf([1, 0.1, 4], [1, 1, 4]);
mbode([sys1, sys2], axs(1,1), axs(2,1))
ylim(axs(1), [-40, 20])

postplot(f, 'Images/example.png', 'width', 10, ...
    'figSizeUnits', 'centimeters', 'aspectRatio', 1.2, ...
    'fontname', 'default', 'fontSize', 10, 'legendFontSize', 8, ...
    'lineWidth', 2);
