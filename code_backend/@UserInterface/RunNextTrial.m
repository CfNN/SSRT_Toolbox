function [trials, runningVals] = RunNextTrial(obj, trials, settings, runningVals)
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

Screen('DrawTexture', obj.window, img, [], obj.arrow_rect, 0);
obj.DrawPerformanceMetrics(runningVals);
[~, tGoStimOn, ~, ~, ~]  = Screen('Flip',obj.window); % GetSecs called internally for timestamp
trials(runningVals.currentTrial).GoSignalOnsetTimestamp = tGoStimOn;

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
        [ keyIsDown, keyTime, keyCode ] = KbCheck; % keyTime is from an internal call to GetSecs
        
        if (keyIsDown)
            trials(runningVals.currentTrial).ResponseTimestamp = keyTime;
            break;
        end
        
        % Time out after TrialDur if no key is pressed
        if ((keyTime - tGoStimOn) > obj.settings.TrialDur)
            trials(runningVals.currentTrial).Answer = 0;
            timedout = true;
        end
    end
    
    % End the stimulus and add timestamp
    [~, tGoStimOff, ~, ~, ~]  = Screen('Flip',obj.window); % GetSecs called internally for timestamp
    trials(runningVals.currentTrial).GoSignalOffsetTimestamp = tGoStimOff;
    
    % If the subject responded with a key press, record which key they 
    % pressed and their Go reaction time
    if(~timedout)
        trials(runningVals.currentTrial).GoRT = keyTime - tGoStimOn;
        runningVals.LastGoRT = keyTime - tGoStimOn; % For live performance metrics
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
    trials(runningVals.currentTrial).SSD_intended = ssd;
    
    soundStarted = false;
    soundPlaying = false;
    timedout = false;
    while ~timedout
        
        % Check for keyboard presses while also getting a timestamp
        % (timestamp is recorded in keyTime regardless of whether a key was
        % pressed)
        [ keyIsDown, keyTime, keyCode ] = KbCheck; % keyTime is from an internal call to GetSecs
        
        if keyIsDown
            trials(runningVals.currentTrial).ResponseTimestamp = keyTime;
            if soundStarted
                [~, ~, ~, estStopTime] = PsychPortAudio('Stop', obj.snd_pahandle);
                trials(runningVals.currentTrial).StopSignalOffsetTimestamp = estStopTime;
            end
            break;
        end
        
        % Start the stop signal beep if the stop-signal delay (SSD) has elapsed
        % Subtract sound latency from ssd - issue the sound play command
        % slightly before when it needs to start, so it begins physically 
        % playing on time. 
        if (keyTime - tGoStimOn) >= ssd - obj.snd_latency && soundStarted == false
            soundStartTime = PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
            trials(runningVals.currentTrial).StopSignalOnsetTimestamp = soundStartTime;
            trials(runningVals.currentTrial).SSD_actual = trials(runningVals.currentTrial).StopSignalOnsetTimestamp - trials(runningVals.currentTrial).GoSignalOnsetTimestamp;
            soundPlaying = true;
            soundStarted = true;
        end
        
        %Stop sound from playing if it has been playing long enough
        if soundPlaying
            if (keyTime - soundStartTime) > obj.settings.StopSignalDur
                [~, ~, ~, estStopTime] = PsychPortAudio('Stop', obj.snd_pahandle);
                trials(runningVals.currentTrial).StopSignalOffsetTimestamp = estStopTime;
                soundPlaying = false;
            end
        end
        
        % Time out after TrialDur if no key presses
        if (keyTime - tGoStimOn) > obj.settings.TrialDur
            [~, ~, ~, estStopTime] = PsychPortAudio('Stop', obj.snd_pahandle);
            trials(runningVals.currentTrial).StopSignalOffsetTimestamp = estStopTime;
            trials(runningVals.currentTrial).Answer = 0;
            timedout = true;
        end
    end
    
    % End the stimulus and add timestamp
    [~, tGoStimOff, ~, ~, ~]  = Screen('Flip',obj.window); % GetSecs called internally for timestamp
    trials(runningVals.currentTrial).GoSignalOffsetTimestamp = tGoStimOff;
    
    if(timedout)
        % Subject stopped successfully
        trials(runningVals.currentTrial).Correct = true;
        runningVals.StopCorrect = runningVals.StopCorrect + 1;
        
        % Increase ssd for the appropriate staircase (make task harder).
        % Also update delta_t by the decay rate (won't change if decay
        % rate is set to 1)
        if strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial')
            runningVals.ssd1 = runningVals.ssd1 + runningVals.delta_t_1;
            runningVals.delta_t_1 = runningVals.delta_t_1*settings.delta_t_decay;
        else
            runningVals.ssd2 = runningVals.ssd2 + runningVals.delta_t_2;
            runningVals.delta_t_2 = runningVals.delta_t_2*settings.delta_t_decay;
        end
        
    else
        % Subject did not stop successfully
        trials(runningVals.currentTrial).Correct = false;
        trials(runningVals.currentTrial).Answer = keyMap(KbName(keyCode));
        trials(runningVals.currentTrial).GoRT = keyTime - tGoStimOn;
        
        % Decrease ssd for the appropriate staircase (make task easier)
        % Also update delta_t by the decay rate (won't change if decay
        % rate is set to 1)
        if strcmpi(trials(runningVals.currentTrial).Procedure, 'StITrial')
            runningVals.ssd1 = runningVals.ssd1 - runningVals.delta_t_1;
            runningVals.delta_t_1 = runningVals.delta_t_1*settings.delta_t_decay;
        else
            runningVals.ssd2 = runningVals.ssd2 - runningVals.delta_t_2;
            runningVals.delta_t_2 = runningVals.delta_t_2*settings.delta_t_decay;
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