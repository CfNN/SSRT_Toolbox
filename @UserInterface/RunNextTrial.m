function [trials, runningVals] = RunNextTrial(obj, trials, runningVals)
% RUNNEXTTRIAL - Run the next trial in the session, based on the current
% trial number (runningVals.currentTrial) and the data in the 'trials'
% struct array. Returns updated copies of 'trials' and 'runningVals'. This
% function also takes care of all timestamping and data logging within each
% trial. 
%
% Usage: [trials, runningVals] = RunNextTrial(trials, runningVals);
% -------------------


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
tStart = GetSecs; % Internal timer to time stimulus onsets/offsets.
trials(runningVals.currentTrial).GoSignalOnsetTimestamp = now;

% Specify allowable key names, restrict input to these
activeKeys = [KbName('LeftArrow') KbName('RightArrow')];
RestrictKeysForKbCheck(activeKeys);

keyMap = containers.Map;
keyMap('LeftArrow') = 1;
keyMap('RightArrow') = 2;

if strcmpi(trials(runningVals.currentTrial).Procedure, 'StGTrial')
    
    % Proceed as go trial
    
    timedout = false;
    while ~timedout

        % Check for keyboard presses while also getting a timestamp
        % (timestamp is recorded in keyTime regardless of whether a key was
        % pressed)
        [ keyIsDown, keyTime, keyCode ] = KbCheck; 
        if (keyIsDown)
            trials(runningVals.currentTrial).ResponseTimestamp = now;
            break;
        end
        
        % Time out after TrialDur if no key is pressed
        if ((keyTime - tStart) > obj.settings.TrialDur)
            trials(runningVals.currentTrial).Answer = [];
            timedout = true; 
        end
    end
    
    % End the stimulus and add timestamp
    Screen('Flip',obj.window);
    trials(runningVals.currentTrial).GoSignalOffsetTimestamp = now;
    
    % If the subject responded with a key press, record which key they 
    % pressed and their Go reaction time
    if(~timedout)
        trials(runningVals.currentTrial).GoRT = keyTime - tStart;
        runningVals.LastGoRT = keyTime - tStart; % For live performance metrics
        trials(runningVals.currentTrial).Answer = keyMap(KbName(keyCode));
    end
    
    % Check if answer is correct
    if trials(runningVals.currentTrial).Answer == trials(runningVals.currentTrial).CorrectAnswer
        trials(runningVals.currentTrial).Correct = true;
        runningVals.GoCorrect = runningVals.GoCorrect + 1;
    else
        trials(runningVals.currentTrial).Correct = false;
    end
    
    runningVals.GoTrialCount = runningVals.GoTrialCount + 1;
    
elseif strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial') || strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial2')
    
    % Proceed as stop trial
    
    %Choose which ssd staircase to use
    if strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial')
        ssd = runningVals.ssd1;
    else
        ssd = runningVals.ssd2;
    end
    trials(runningVals.currentTrial).StopSignalDelay = ssd;
    
    soundStarted = false;
    soundPlaying = false;
    timedout = false;
    while ~timedout
        
        % Check for keyboard presses while also getting a timestamp
        % (timestamp is recorded in keyTime regardless of whether a key was
        % pressed)
        [ keyIsDown, keyTime, keyCode ] = KbCheck; 
        if keyIsDown
            trials(runningVals.currentTrial).ResponseTimestamp = now;
            PsychPortAudio('Stop', obj.snd_pahandle);
            break;
        end
        
        % Start the stop signal beep if the stop-signal delay (SSD) has elapsed
        if (keyTime - tStart) >= ssd && soundStarted == false
            soundStartTime = PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
            trials(runningVals.currentTrial).StopSignalOnsetTimestamp = datevec(soundStartTime);
            soundPlaying = true;
            soundStarted = true;
        end
        
        %Stop sound from playing if it has been playing long enough
        if soundPlaying
            if (keyTime - soundStartTime) > obj.settings.InhDur
                PsychPortAudio('Stop', obj.snd_pahandle);
                soundPlaying = false;
            end
        end
        
        % Time out after TrialDur if no key presses
        if (keyTime - tStart) > obj.settings.TrialDur
            PsychPortAudio('Stop', obj.snd_pahandle);
            trials(runningVals.currentTrial).Answer = [];
            timedout = true;
        end
    end
    
    % End the stimulus and add timestamp
    Screen('Flip',obj.window);
    trials(runningVals.currentTrial).GoSignalOffsetTimestamp = now;
    
    if(timedout)
        % Subject stopped successfully
        trials(runningVals.currentTrial).Correct = true;
        runningVals.StopCorrect = runningVals.StopCorrect + 1;
        
        % Increase ssd for the appropriate staircase (make task harder)
        if strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial')
            runningVals.ssd1 = runningVals.ssd1 + obj.settings.delta_t;
        else
            runningVals.ssd2 = runningVals.ssd2 + obj.settings.delta_t;
        end
        
    else
        % Subject did not stop successfully
        trials(runningVals.currentTrial).Correct = false;
        trials(runningVals.currentTrial).Answer = keyMap(KbName(keyCode));
        trials(runningVals.currentTrial).GoRT = keyTime - tStart;
        
        % Decrease ssd for the appropriate staircase (make task easier)
        if strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial')
            runningVals.ssd1 = runningVals.ssd1 - obj.settings.delta_t;
        else
            runningVals.ssd2 = runningVals.ssd2 - obj.settings.delta_t;
        end
        
    end
    
    runningVals.StopTrialCount = runningVals.StopTrialCount + 1;
    
else
    error('Invalid input - use ''StGTrial'', ''StITrial'', or ''StITrial2'' in Procedure field');
end

% Re-enable all keys (restricted during trial)
RestrictKeysForKbCheck([]);

% Advance iterator to next trial
runningVals.currentTrial = runningVals.currentTrial + 1;

end