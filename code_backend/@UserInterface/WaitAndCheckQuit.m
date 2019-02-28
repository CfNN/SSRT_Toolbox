function quitKeyPressed = WaitAndCheckQuit(obj, duration, settings) %#ok<INUSL>
% WAITANDCHECKQUIT pauses program execution for {duration} seconds, while 
% checking to see if the quit key was pressed. 
%   Eg. WaitAndCheckQuit(2.4, settings) delays for 2400 milliseconds. 

% Only take input from quit keys during fixation
activeKeys = settings.QuitKeyCodes;
RestrictKeysForKbCheck(activeKeys);

[~, keyCode, ~] = KbWait(settings.ControlDeviceIndex, [], GetSecs + duration);

quitKeyPressed = ismember(find(keyCode), settings.QuitKeyCodes);

% Re-enable all keys (restricted during waiting period)
RestrictKeysForKbCheck([]);
end

