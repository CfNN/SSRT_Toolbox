function triggerTimestamp = ShowReadyTrigger(obj)
% SHOWREADYTRIGGER - Shows a 'ready' screen. The experiment can be
% continued with a key press or an MRI trigger. A timer is included, which
% allows the experimenter to check whether the MRI is starting up within a 
% reasonable time frame.
%
% TriggerTimestamp: returns the results of a call to the GetSecs function
% at the precise moment when the trigger arrives (MRI trigger or key press)
%
% See also SHOWINSTRUCTIONS

if obj.settings.UseMRITrigger
    % The trigger device is a keyboard. Loop through keyboards until you find
    %  one with a vendor ID that matches the trigger device. For MRI trigger 
    %  use 'Current Designs, Inc.'
    trigger=-1;
    Devices = PsychHID('Devices');
    for i=1:size(Devices,2)
        if (strcmp(Devices(i).usageName,'Keyboard') && strcmp(Devices(i).manufacturer,'Current Designs, Inc.'))
            trigger=i;
            break;
        end
    end
    if trigger==-1
        error('No trigger device detected on your system')
    end
    
    activeKeys = trigger; % Only allow the trigger to start the experiment
else
    % If MRI trigger not used, user can proceed by hitting any key. 
    % Change to (eg.) activeKeys = [KbName('space'), KbName('return')] to 
    % only respond to the space or enter keys. 
    activeKeys = [];
end

RestrictKeysForKbCheck(activeKeys);

Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 1 makes it bold;

prevTimer = -1;

tStart = GetSecs;

timedout = false;
    while ~timedout

        [ keyIsDown, keyTime, ~ ] = KbCheck(activeKeys); 
        if (keyIsDown)
            triggerTimestamp = keyTime;
            assignin('base', 'TriggerTimestamp', keyTime); % Just in case
            break;
        end
        
        timer = round(keyTime - tStart);
        
        if timer ~= prevTimer
            Screen('TextSize', obj.window, 48);
            DrawFormattedText(obj.window, 'Ready to Begin', 'center', 'center', obj.c_yellow);
            Screen('TextSize', obj.window, 36);
            DrawFormattedText(obj.window, ['Counter: ', num2str(timer)], 'center', obj.screenYpixels * 0.95, obj.c_yellow);
            Screen('Flip', obj.window); % Flip to the updated screen
        end
        
        prevTimer = timer;
        
        % Uncomment these lines if you want to experiment to start without
        % the trigger after a certain time (in seconds)
%         if ((keyTime - tStart) > 300)
%             timedout = true; 
%         end
    end

end
