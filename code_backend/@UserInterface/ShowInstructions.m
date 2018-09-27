function ShowInstructions(obj)
% SHOWINSTRUCTIONS - Show a series of introductory/instruction screens
%   Usage: ShowInstructions();
% See also SHOWREADYTIMER
% -------------------

% Can proceed by hitting any key. 
% Use (eg.) activeKeys = [KbName('space'), KbName('return')] to only 
% respond to the space or enter keys. 
activeKeys = [];
RestrictKeysForKbCheck(activeKeys);

instructions = [
    'Now we''re ready to start!\n\n\n',...
    'When you see the LEFT arrow, press the LEFT arrow key.\n\n',...
    'When you see the RIGHT arrow, press the RIGHT arrow key.\n\n\n',...
    'Press the correct key as FAST as you can.\n\n\n',...
    'But if you hear a beep or see an UP arrow, try very hard \n\nto STOP yourself from pressing the button.\n\n\n',...
    'Stopping and Going are equally important!\n\n\n',...
    'Place your hand on the table with your fingers extended \n\n and resting comfortably on the left and right arrow keys.\n\n\n',...
    'Please tell the Experimenter when you are ready to start.'
    ];

Screen('TextSize', obj.window, 80);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 1); % 1 makes it bold;

DrawFormattedText(obj.window, 'SSRT', 'center', 'center', obj.c_yellow);

Screen('Flip', obj.window); % Flip to the screen
KbStrokeWait; % Wait for key press

Screen('TextSize', obj.window, 24);
Screen('TextSTyle', obj.window, 0);

DrawFormattedText(obj.window, instructions, 'center', 'center', obj.c_yellow);

Screen('Flip', obj.window); % Flip to the screen
KbStrokeWait; % Wait for key press

end
