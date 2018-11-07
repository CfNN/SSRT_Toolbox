function [onsetTimestamp, offsetTimestamp] = ShowBlank(obj, duration, runningVals)
% SHOWBLANK shows a blank screen for the specified duration.
%   eg. ShowBlank(2.4, runningVals) displays a blank screen for 2400 milliseconds. 

obj.DrawPerformanceMetrics(runningVals);
[~, onsetTimestamp, ~, ~, ~] = Screen('Flip',obj.window);

WaitSecs(duration);

[~, offsetTimestamp, ~, ~, ~] = Screen('Flip',obj.window);

end