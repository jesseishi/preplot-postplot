function mbode(sys, axMag, axPhase, opts)
%MBODE Summary of this function goes here
%   Detailed explanation goes here

% TODO: could get more customization when using freqresp instead of bode.
arguments
    sys
    axMag
    axPhase = []
    opts.magUnits {mustBeMember(opts.magUnits, {'abs', 'dB'})} = 'dB'
    opts.lineSpec = '-'
    opts.w = []
    opts.wrapTo180 logical = false
    opts.wrapTo360 logical = false
    opts.setAxesLabels logical = true
    opts.adjustPhaseTicks logical = true
    opts.adjustPhaseTicksStep double = 90
end

% If we also got an axes to plot the phase, let's do that, if not, don't
% plot the phase.
plotPhase = isa(axPhase, 'matlab.graphics.axis.Axes');

if ~isa(sys, 'cell')
    sys = {sys};
end
for i = 1:length(sys)
    iSys = sys{i};
    [mag, phase, wout] = bode(iSys, opts.w);
    
    mag = squeeze(mag);
    phase = squeeze(phase);
    
    if matches('dB', opts.magUnits)
        mag = mag2db(mag);
    end
    
    if opts.wrapTo180
        phase = mod(phase+180, 360) - 380;
    elseif opts.wrapTo360
        phase = mod(phase+360, 360) - 360;
    end
    
    set(axMag, 'XScale', 'log')
    if plotPhase
        set(axPhase, 'XScale', 'log')
    end
    
    semilogx(axMag, wout, mag, opts.lineSpec);
    if plotPhase
        semilogx(axPhase, wout, phase, opts.lineSpec);
    end
end

% Just set the labels for all axes, if we then want to share the x/y axes,
% remove them again with postplot('sharex', true, 'sharey', true)
if opts.setAxesLabels
    xlabel(axMag, "Frequency (rad/s)")
    ylabel(axMag, sprintf("Magnitude (%s)", opts.magUnits))
    if plotPhase
        xlabel(axPhase, "Frequency (rad/s)")
        ylabel(axPhase, "Phase (deg)")
    end
end

% It's nice if the phase has yticks that are easy to interpret (e.g. -180).
% This needs a bit of work, doesn't work well when doing multiple mbode
% calls.
if plotPhase
    if opts.adjustPhaseTicks

        lines = findobj(axPhase, 'Type', 'Line');
        ymin = min(lines(1).YData);
        ymax = max(lines(1).YData);
        for i = 2:length(lines)
            ymin = min(min(lines(i).YData), ymin);
            ymax = max(max(lines(i).YData), ymax);
        end

        % Round the ymin and ymax to a multiple of
        % opts.adjustPhaseTickStep. This ensures that the y ticks can be
        % nice like (-180, -90, 0) instead of (-100, -50, 0).
        targets = -opts.adjustPhaseTicksStep*10:opts.adjustPhaseTicksStep:opts.adjustPhaseTicksStep*10;
        ylower = interp1(targets, targets, ymin, 'previous');
        yupper = interp1(targets, targets, ymax, 'next');

        ylim(axPhase, [ylower, yupper])

        axPhase.YTick = ylower:opts.adjustPhaseTicksStep:yupper;
    end
end





end
