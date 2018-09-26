function VisualizeSession(filename)

load(['session_files/' filename], 'trials');

% Plot the go trial reaction times over the course of the experiment
GoRTplot(trials)

% Plot stop-signal delay values for both staircases over the course of the
% experiment
SSDplot(trials);


end

function GoRTplot(trials)

meanGoRT = nanmean([trials(strcmpi({trials.Procedure}, 'StGTrial')).GoRT]);

meanCorrectGoRT = nanmean([trials(strcmpi({trials.Procedure}, 'StGTrial') & [trials.Correct]).GoRT]);

plot([trials(strcmpi({trials.Procedure}, 'StGTrial')).GoRT], 'LineWidth', 3);
title({'Go trial reaction times', ['Mean GoRT = ' num2str(meanGoRT) ' s'], ['Mean GoRT (correct responses only) = ' num2str(meanCorrectGoRT) ' s']});
ylabel('Reaction time (s)');
xlabel('Go trial number');

end

function SSDplot(trials)

figure;

st1markers = zeros(1, nnz(strcmpi({trials.Procedure}, 'StITrial')));
st2markers = zeros(1, nnz(strcmpi({trials.Procedure}, 'StITrial2')));

stopTrialCounter = 1;
for t = 1:numel(trials)
    if strcmpi(trials(t).Procedure, 'StITrial')
        st1markers(find(st1markers == 0, 1)) = stopTrialCounter;
        stopTrialCounter = stopTrialCounter + 1;
    elseif strcmpi(trials(t).Procedure, 'StITrial2')
        st2markers(find(st2markers == 0, 1)) = stopTrialCounter;
        stopTrialCounter = stopTrialCounter + 1;
    end
end

plot(st1markers, [trials(strcmpi({trials.Procedure}, 'StITrial')).StopSignalDelay], 'LineWidth', 3); hold on;
plot(st2markers, [trials(strcmpi({trials.Procedure}, 'StITrial2')).StopSignalDelay], 'LineWidth', 3);
plot([trials(~isnan([trials.StopSignalDelay])).StopSignalDelay]);
title('Stop signal delay (SSD) during experiment session');
ylabel('SSD');
xlabel('Stop trial number');
legend({'Staircase 1 (StITrial)', 'Staircase 2 (StITrial2)', 'Both staircases'});

end

