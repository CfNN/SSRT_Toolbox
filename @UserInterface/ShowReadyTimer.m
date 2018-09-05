function ShowReadyTimer(obj)
% SHOWREADYTIMER - Shows a 'ready' screen, with a timer that allows the
% experimenter to check whether the MRI is starting up within a reasonable
% time frame. 
%
% See also SHOWINSTRUCTIONS

Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 1 makes it bold;

prevTimer = -1;

tStart = GetSecs;

timedout = false;
    while ~timedout

        [ keyIsDown, keyTime, ~ ] = KbCheck; 
        if (keyIsDown)
            break;
        end
        
        timer = round(keyTime - tStart);
        
        if timer ~= prevTimer
            Screen('TextSize', obj.window, 48);
            DrawFormattedText(obj.window, 'Ready to Begin', 'center', 'center', obj.c_yellow);
            Screen('TextSize', obj.window, 36);
            DrawFormattedText(obj.window, ['Counter: ', num2str(timer)], 'center', obj.screenYpixels * 0.95, obj.c_yellow);
            Screen('Flip', obj.window); % Flip to the screen
        end
        
        prevTimer = timer;
        
        if ((keyTime - tStart) > 10)
            timedout = true; 
        end
    end

end
