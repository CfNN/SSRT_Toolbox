function ShowInstructions(obj)

instructions = [
    'Now we''re ready to start!\n\n',...
    'When you see the left arrow, press the LEFT key.\n',...
    'When you see the right arrow, press the RIGHT key.\n\n',...
    'Press the correct key as FAST as you can.\n\n',...
    'But if you hear a beep, try very hard to STOP yourself from pressing the button.\n\n',...
    'Stopping and Going are equally important!\n\n',...
    'Place your hand on the table with your fingers extended and resting comfortably on the LEFT and RIGHT keys.\n\n',...
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

Screen('TextSize', obj.window, 48);
DrawFormattedText(obj.window, 'Ready to Begin', 'center', 'center', obj.c_yellow);

Screen('Flip', obj.window); % Flip to the screen
KbStrokeWait; % Wait for key press

end
