function ShowFixation(obj, duration)
% SHOWFIXATION shows a fixation cross for the specified duration.
%   eg. ShowFixation(2.4) displays fixation cross for 2400 milliseconds. 

Screen('TextSize', obj.window, 80);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 0 is regular (not bold, italicized, etc)

DrawFormattedText(obj.window,'+','center','center',obj.c_white);
Screen('Flip',obj.window);

WaitSecs(duration);

end