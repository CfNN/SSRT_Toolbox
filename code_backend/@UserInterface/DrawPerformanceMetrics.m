function DrawPerformanceMetrics(obj, runningVals)
% Draws performance metrics at the bottom of the the screen, without 
% flipping the screen yet (flipping must be done AFTER calling this 
% function). 
%
% TO DISABLE PERFORMANCE METRICS: Edit ExperimentSettings.m, set 
% settings.DisplayPerfMetrics = false;
% 
% Usage: DrawPerformanceMetrics(runningVals);

if obj.settings.DisplayPerfMetrics == true
    
    perfMetrics = [
        'Go Acc: ' num2str(runningVals.GoAcc) '%    Last go trial RT: ' num2str(round(runningVals.LastGoRT*1000)) 'ms' '\n\n',...
        'Stop success %: ' num2str(runningVals.StopAcc) '%    SSD1: ' num2str(round(runningVals.ssd1*1000)) 'ms    SSD2: ' num2str(round(runningVals.ssd2*1000)) 'ms'
        ];
    
    Screen('TextSize', obj.window, 18);
    Screen('TextFont', obj.window, 'Courier New');
    Screen('TextSTyle', obj.window, 0); % 0 is regular (not bold, italicized, etc)
    % Change the value in "obj.screenYpixels - 50" to modify the vertical
    % position of the performance metrics.     q
    DrawFormattedText(obj.window, perfMetrics, 'center', obj.screenYpixels - 50, obj.c_white);
end

end