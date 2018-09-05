function trials = RunTrial(obj, stopGo, arrowDirection, runningVals, trials)
% RUNTRIAL  Run a 'stop' or 'go' SSRT trial and record the response.
%   C = ADDME(A) adds A to itself.
%
%   C = ADDME(A,B) adds A and B together.
%
%   See also SUM, PLUS.

if strcmpi(arrowDirection, 'Right_Arrow.bmp')
    img = obj.arrow_tex_right;
elseif strcmpi(arrowDirection, 'Left_Arrow.bmp')
    img = obj.arrow_tex_left;
else
    error('Invalid arrow direction - use ''Right_Arrow.bmp'' or ''Left_Arrow.bmp''');
end

Screen('TextSize', obj.window, 12);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 0 is regular (not bold, italicized, etc)

Screen('DrawTexture', obj.window, img, [], [], 0);
DrawFormattedText(obj.window, 'Performance metrics here!', 'center', obj.screenYpixels * 0.96, obj.c_white);
Screen('Flip',obj.window);

if strcmpi(stopGo, 'go')
    WaitSecs(settings.g_TrialDur);
elseif strcmpi(stopGo, 'stop')
    WaitSecs(runningVals.ssd1);
    PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
    WaitSecs(runningVals.postBeepDelay1);
else
    error('Invalid input - use ''stop'' or ''go'' for StopGo argument');
end

KbStrokeWait; % Wait for key press

runningVals.currentTrial = runningVals.currentTrial + 1;

end