function [trials, runningVals, quitKeyPressed] = RunNextTrial(obj, trials, settings, runningVals)
% RUNNEXTTRIAL - Run the next trial in the session, based on the current
% trial number (runningVals.currentTrial) and the data in the 'trials'
% struct array. Returns updated copies of 'trials' and 'runningVals'. This
% function also takes care of all timestamping and data logging within each
% trial. 
%
% Usage: [trials, runningVals] = RunNextTrial(trials, settings, runningVals);
% -------------------

% If the escape or q key is pressed, this will be set to true and passed as 
% such to the Main_SSRT script, which will then end the experiment session. 
quitKeyPressed = false;

if strcmpi(trials(runningVals.currentTrial).Stimulus, 'Right_Arrow.bmp')
    go_img = obj.arrow_tex_right;
    red_stop_arrow = obj.arrow_tex_right_red;
elseif strcmpi(trials(runningVals.currentTrial).Stimulus, 'Left_Arrow.bmp')
    go_img = obj.arrow_tex_left;
    red_stop_arrow = obj.arrow_tex_left_red;
else
    error('Invalid arrow direction - use ''Right_Arrow.bmp'' or ''Left_Arrow.bmp''');
end

Screen('DrawTexture', obj.window, go_img, [], obj.lr_arrow_rect, 0);
obj.DrawPerformanceMetrics(settings, runningVals);
[~, tGoStimOn, ~, ~, ~]  = Screen('Flip',obj.window); % GetSecs called internally for timestamp
trials(runningVals.currentTrial).GoSignalOnsetTimestamp = tGoStimOn;

% Specify allowable key names, restrict input to these
activeKeys = [settings.RespondLeftKeyCodes, settings.RespondRightKeyCodes, settings.QuitKeyCodes];
RestrictKeysForKbCheck(activeKeys);

keyMap = containers.Map;
for k = 1:numel(settings.RespondLeftKeyNames)
    keyMap(settings.RespondLeftKeyNames{k}) = 1;
end
for k = 1:numel(settings.RespondRightKeyNames)
    keyMap(settings.RespondRightKeyNames{k}) = 2;
end
clear k;

if strcmpi(trials(runningVals.currentTrial).Procedure, 'StGTrial')
    
    % Proceed as go trial
    
    timedout = false;
    while ~timedout
        
        % Check for quit key
        [ keyIsDown, ~, keyCode ] = KbCheck(settings.ControlDeviceIndex);
        if keyIsDown && ismember(find(keyCode), settings.QuitKeyCodes)
            quitKeyPressed = true;
            return
        end
        
        % Check for keyboard responses and get a timestamp (timestamp is
        % recorded in keyTime regardless of whether a key was pressed)
        [ keyIsDown, keyTime, keyCode ] = KbCheck(settings.RespondDeviceIndex); % keyTime is from an internal call to GetSecs
        
        % Record RT and keycode data, and break loop, if key pressed
        if (keyIsDown && ~ismember(find(keyCode), settings.QuitKeyCodes))
            trials(runningVals.currentTrial).ResponseTimestamp = keyTime;
            trials(runningVals.currentTrial).GoRT = keyTime - tGoStimOn;
            runningVals.LastGoRT = keyTime - tGoStimOn; % For live performance metrics
            trials(runningVals.currentTrial).ResponseKeyName = KbName(keyCode);
            trials(runningVals.currentTrial).Answer = keyMap(KbName(keyCode));
            break
        end
        
        % Time out after TrialDur if no key is pressed
        if ((keyTime - tGoStimOn) > settings.TrialDur)
            trials(runningVals.currentTrial).Answer = 0;
            timedout = true;
        end
    end
    
    % End the stimulus and add timestamp
    [~, goSignalEndTime, ~, ~, ~]  = Screen('Flip',obj.window); % GetSecs called internally for timestamp
    trials(runningVals.currentTrial).GoSignalOffsetTimestamp = goSignalEndTime;
    
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
    
    stopSignalStarted = false;
    stopSignalOn = false;
    timedout = false;
    while ~timedout
        
        % Check for quit key
        [ keyIsDown, ~, keyCode ] = KbCheck(settings.ControlDeviceIndex);
        if keyIsDown && ismember(find(keyCode), settings.QuitKeyCodes)
            quitKeyPressed = true;
            return
        end

        % Check for keyboard responses and get a timestamp (timestamp is
        % recorded in keyTime regardless of whether a key was pressed)
        [ keyIsDown, keyTime, keyCode ] = KbCheck(settings.RespondDeviceIndex); % keyTime is from an internal call to GetSecs
        
        % Record RT and keycode data, and break loop, if key pressed
        if (keyIsDown)
            trials(runningVals.currentTrial).ResponseTimestamp = keyTime;
            break
        end
        
        % Start the stop signal if the stop-signal delay (SSD) has elapsed
        if (keyTime - tGoStimOn) >= ssd && stopSignalStarted == false
            
            if strcmpi(settings.StopSignalType, 'auditory')
                stopSignalStartTime = PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
            elseif strcmpi(settings.StopSignalType, 'visual_uparrow')
                % Redraw performance metrics, draw up arrow stop signal
                obj.DrawPerformanceMetrics(settings, runningVals);
                Screen('DrawTexture', obj.window, obj.arrow_tex_up, [], obj.up_arrow_rect, 0);
                [~, stopSignalStartTime, ~, ~, ~]  = Screen('Flip',obj.window);
            elseif strcmpi(settings.StopSignalType, 'visual_turnred')
                obj.DrawPerformanceMetrics(settings, runningVals);
                Screen('DrawTexture', obj.window, red_stop_arrow, [], obj.lr_arrow_rect, 0);
                [~, stopSignalStartTime, ~, ~, ~]  = Screen('Flip',obj.window);
            else
                error('Please set settings.StopSignalType to ''auditory'', ''visual_uparrow'', or ''visual_turnred'' in ExperimentSettings.m');
            end
            trials(runningVals.currentTrial).StopSignalOnsetTimestamp = stopSignalStartTime;
            trials(runningVals.currentTrial).SSD_actual = trials(runningVals.currentTrial).StopSignalOnsetTimestamp - trials(runningVals.currentTrial).GoSignalOnsetTimestamp;
            stopSignalOn = true;
            stopSignalStarted = true;
        end
        
        % Stop the stop signal if it has been presented long enough
        if stopSignalOn
            if (keyTime - stopSignalStartTime) > settings.StopSignalDur
                
                if strcmpi(settings.StopSignalType, 'auditory')
                    [~, ~, ~, stopSignalEndTime] = PsychPortAudio('Stop', obj.snd_pahandle);
                elseif strcmpi(settings.StopSignalType, 'visual_upparow') || strcmpi(settings.StopSignalType, 'visual_turnred')
                    obj.DrawPerformanceMetrics(settings, runningVals);
                    [~, stopSignalEndTime, ~, ~, ~]  = Screen('Flip',obj.window);
                end
                trials(runningVals.currentTrial).StopSignalOffsetTimestamp = stopSignalEndTime;
                stopSignalOn = false;
            end
        end
        
        % Time out after TrialDur if no key presses
        if (keyTime - tGoStimOn) > settings.TrialDur
            trials(runningVals.currentTrial).Answer = 0;
            timedout = true;
        end
    end
    
    % End the stimulus and add timestamp
    [~, goSignalEndTime, ~, ~, ~]  = Screen('Flip',obj.window); % GetSecs called internally for timestamp
    trials(runningVals.currentTrial).GoSignalOffsetTimestamp = goSignalEndTime;
    
    if stopSignalOn % If the stop signal was still on when the trial ended
        if strcmpi(settings.StopSignalType, 'auditory')
            [~, ~, ~, stopSignalEndTime] = PsychPortAudio('Stop', obj.snd_pahandle);
            trials(runningVals.currentTrial).StopSignalOffsetTimestamp = stopSignalEndTime;
        elseif strcmpi(settings.StopSignalType, 'visual_upparow') || strcmpi(settings.StopSignalType, 'visual_turnred')
            trials(runningVals.currentTrial).StopSignalOffsetTimestamp = goSignalEndTime; % Screen('Flip'...) removes both stop and go visual stimuli at same time
        end
    end
    
    if(timedout)
        % Subject stopped successfully if the stop trial timed out
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
            % Make sure SSD never goes negative
            if runningVals.ssd1 < 0
                runningVals.ssd1 = 0;
            end
            runningVals.delta_t_1 = runningVals.delta_t_1*settings.delta_t_decay;
        else
            runningVals.ssd2 = runningVals.ssd2 - runningVals.delta_t_2;
            % Maake sure SSD never goes negative
            if runningVals.ssd2 < 0
                runningVals.ssd2 = 0;
            end
            runningVals.delta_t_2 = runningVals.delta_t_2*settings.delta_t_decay;
        end
        
    end
    
    runningVals.StopTrialCount = runningVals.StopTrialCount + 1;
    
else
    error('Invalid input - use ''StGTrial'', ''StITrial'', or ''StITrial2'' in Procedure field');
end

% Re-enable all keys (restricted during trial)
RestrictKeysForKbCheck([]);

end
