function quitKeyPressed = ShowInstructions(obj, settings)
% SHOWINSTRUCTIONS - Show a series of introductory/instruction screens
%   Usage: ShowInstructions();
% See also SHOWREADYTRIGGER
% -------------------


quitKeyPressed = false; % Default value

% User can proceed by hitting any key. 
% Change to (eg.) activeKeys = [KbName('space'), KbName('return')] to only 
% respond to the space or enter keys. 
activeKeys = [];
RestrictKeysForKbCheck(activeKeys);

% FIRST SCREEN (title)
Screen('TextSize', obj.window, 80);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 1); % 1 makes it bold;

DrawFormattedText(obj.window, 'SSRT', 'center', 'center', obj.c_yellow);

Screen('Flip', obj.window); % Flip to the screen

% Wait for key press
[~, keyCode, ~] = KbStrokeWait(settings.ControlDeviceIndex);

% quit if quit key was pressed
if ismember(find(keyCode), settings.QuitKeyCodes)
    quitKeyPressed = true;
    return
end

% SECOND SCREEN (instructions)
Screen('TextSize', obj.window, 24);
Screen('TextSTyle', obj.window, 0);

instructions = [ % Use \n to start a new line. Just one \n doesn't give enough space - best to use two or three
    'Now we''re ready to start!\n\n\n',...
    'When you see the LEFT arrow, press the LEFT arrow key.\n\n',...
    'When you see the RIGHT arrow, press the RIGHT arrow key.\n\n\n',...
    'Press the correct key as FAST as you can.\n\n\n',...
    'But if you hear a beep or see an UP arrow, try very hard \n\nto STOP yourself from pressing the button.\n\n\n',...
    'Stopping and Going are equally important!\n\n\n',...
    'Place your hand on the table with your fingers extended \n\n and resting comfortably on the left and right arrow keys.\n\n\n',...
    'Please press the spacebar when you are ready to start.'
    ];

DrawFormattedText(obj.window, instructions, 'center', 'center', obj.c_yellow);

Screen('Flip', obj.window); % Flip to the screen

% Wait for key press
[~, keyCode, ~] = KbStrokeWait(settings.ControlDeviceIndex);

% quit if quit key was pressed
if ismember(find(keyCode), settings.QuitKeyCodes)
        quitKeyPressed = true;
        return
end

end
