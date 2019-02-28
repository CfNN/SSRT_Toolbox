function [triggerTimestamp, sessionStartDateTime, quitKeyPressed] = ShowReadyTrigger(obj, settings)
% SHOWREADYTRIGGER - Shows a 'ready' screen. The experiment can be
% continued with a key press or an MRI trigger. A timer is included, which
% allows the experimenter to check whether the MRI is starting up within a 
% reasonable time frame.
%
% triggerTimestamp: returns the results of a call to the GetSecs function
% at the precise moment when the trigger arrives (MRI trigger or key press)
%
% sessionStartDateTime: returns a vector containing the date and time when
% the trigger arrived (as close as possible to the actual
% triggerTimestamp, but not exactly the same). 
%
% See also SHOWINSTRUCTIONS


% Make sure output vars are set to something even if quit key is pressed
triggerTimestamp = NaN;
sessionStartDateTime = NaN;

% If MRI trigger not used, user can proceed by hitting any key. 
% Change to (eg.) activeKeys = [KbName('space'), KbName('return') settings.QuitKeyCodes] 
% to only respond to the space or enter keys. You must include the
% QuitKeyCodes if you want to be able to quit from this screen.
activeKeys = [];
RestrictKeysForKbCheck(activeKeys);

if settings.UseMRITrigger
    % The trigger device is a keyboard. Loop through keyboards until you find
    %  one with a vendor ID that matches the trigger device. For MRI trigger 
    %  use 'Current Designs, Inc.'
    MRIIndex=-1;
    LoadPsychHID;
    devices = PsychHID('devices');
    for i=1:numel(devices)
        if (strcmp(devices(i).usageName, settings.MRITriggerUsageName) && strcmp(devices(i).manufacturer, settings.MRITriggerManufacturer))
            MRIIndex=devices(i).index;
            break
        end
    end
    if MRIIndex==-1
        fprintf(2,'\nERROR: No trigger device detected on your system\n')
        triggerTimestamp = NaN;
        sessionStartDateTime = NaN;
        quitKeyPressed = true;
        return
    end
end

Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 1 makes it bold;

quitKeyPressed = false;
prevTimer = -1;
tStart = GetSecs;
timedout = false;
    while ~timedout
        
        [ keyIsDown, keyTime, keyCode ] = KbCheck(settings.ControlDeviceIndex);
        if (keyIsDown)
            if ismember(find(keyCode), settings.QuitKeyCodes)
                quitKeyPressed = true;
                break
            else
                if ~settings.UseMRITrigger
                    sessionStartDateTime = datevec(now);
                    triggerTimestamp = keyTime;
                    break
                end
            end
        end
        
        if settings.UseMRITrigger
            [ keyIsDown, keyTime, ~] = KbCheck(MRIIndex);
            if keyIsDown
                sessionStartDateTime = datevec(now);
                triggerTimestamp = keyTime;
                break
            end
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
        
        % Uncomment these lines if you want to experiment to start automatically without
        % the trigger after a certain time (in seconds)
%         if ((keyTime - tStart) > 300)
%             timedout = true; 
%         end
    end

end