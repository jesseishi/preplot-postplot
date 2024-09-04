%% Simple example.
preplot();
plot(1:10)
postplot()


%% With some customization.
colors = [0.1, 0.2, 0.3;
          0.4, 0.5, 0.6];
[f, axs] = preplot(2, 1, 'paperFormat', 'WES', 'column', 2, ...
    'lineFrac', 0.8, 'aspectRatio', 1.2, 'colororder', colors);

t = linspace(0, 10, 1e4);
plot(axs(1), t, sin(t))
plot(axs(1), t, cos(t))
plot(axs(2), t, log10(t))
plot(axs(2), t, log(t))

xlabel(axs(2), 'Time (s)')

postplot(f, 'Results/test.pdf', 'fontname', 'Monospaced', 'fontSize', 10, ...
    'legendFontSize', 8, 'sharex', true, 'lineWidth', 1);


%% Logarithmic plot
% Does not work:
% f = preplot();
% loglog(1:10)
% DO:
f = preplot('YScale', 'log', 'XScale', 'log');
plot(1:10)

% Or:
f = preplot('hold', 'off');
loglog(1:10)


%% Control plots.
[f, axs] = preplot(2, 2, 'interpreter', 'Latex');
axBig = nexttile(2, [2,1]);

sys = tf(4, [1, 0.7, 4]);
mbode(sys, axs(1,1), axs(2,1))
mnyquist(sys, axBig, 'w', logspace(-1, 2, 1e3))

postplot('sharex', true);
