function DrawPerformanceMetrics(obj, runningVals)

Screen('TextSize', obj.window, 16);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 0 is regular (not bold, italicized, etc)
DrawFormattedText(obj.window, ['Go acc: ' num2str(runningVals.GoAcc)], 'center', obj.screenYpixels * 0.96, obj.c_white);

end