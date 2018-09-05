function ShowFixation(obj, duration, runningVals)
% SHOWFIXATION shows a fixation cross for the specified duration.
%   Eg. ShowFixation(2.4) displays fixation cross for 2400 milliseconds. 

Screen('TextSize', obj.window, 80);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 0 is regular (not bold, italicized, etc)

DrawFormattedText(obj.window,'+','center','center',obj.c_white);

obj.DrawPerformanceMetrics(runningVals);

Screen('Flip',obj.window);

WaitSecs(duration);

end