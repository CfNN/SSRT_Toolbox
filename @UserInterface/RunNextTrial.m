function [trials, runningVals] = RunNextTrial(obj, trials, runningVals)

if strcmpi(trials(runningVals.currentTrial).Stimulus, 'Right_Arrow.bmp')
    img = obj.arrow_tex_right;
elseif strcmpi(trials(runningVals.currentTrial).Stimulus, 'Left_Arrow.bmp')
    img = obj.arrow_tex_left;
else
    error('Invalid arrow direction - use ''Right_Arrow.bmp'' or ''Left_Arrow.bmp''');
end

Screen('DrawTexture', obj.window, img, [], [], 0);
obj.DrawPerformanceMetrics(runningVals);
Screen('Flip',obj.window);

if strcmpi(trials(runningVals.currentTrial).Procedure, 'StGTrial')
    WaitSecs(obj.settings.TrialDur);
elseif strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial') || strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial')
    WaitSecs(runningVals.ssd1);
    PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
    WaitSecs(runningVals.postBeepDelay1);
else
    error('Invalid input - use ''stop'' or ''go'' for StopGo argument');
end

KbStrokeWait; % Wait for key press

runningVals.currentTrial = runningVals.currentTrial + 1;

end