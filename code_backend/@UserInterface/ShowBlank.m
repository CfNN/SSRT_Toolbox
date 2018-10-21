function trials = ShowBlank(obj, duration, runningVals, trials)
% SHOWBLANK shows a blank screen for the specified duration.
%   eg. ShowBlank(2.4) displays fixation cross for 2400 milliseconds. 

obj.DrawPerformanceMetrics(runningVals);
[~, trials(runningVals.currentTrial).BlankOnsetTimestamp, ~, ~, ~] = Screen('Flip',obj.window);

WaitSecs(duration);

[~, trials(runningVals.currentTrial).BlankOffsetTimestamp, ~, ~, ~] = Screen('Flip',obj.window);

end