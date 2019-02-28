classdef UserInterface < handle
% USERINTERFACE - Wrapper class that contains PsychToolbox functions for
% displaying graphics and playing sounds. This includes code for running
% trials, showing fixation and blank screens, and showing
% instructions/'ready' screens during the experiment session. The 
% superscript 'Main_SSRT.m' works primarily by calling functions in this class.
    
    properties (GetAccess=private)
        
        % Screen properties
        window;
        windowRect;
        screenXpixels;
        screenYpixels;
        xCenter;
        yCenter;
        
        % Images
        arrow_tex_left;
        arrow_tex_right;
        arrow_tex_up;
        lr_arrow_rect;
        up_arrow_rect;
        
        % Sound parameters
        snd_stopBeep;
        snd_pahandle;
        snd_repetitions;
        snd_startCue;
        snd_waitForDeviceStart;
        snd_latency;
    end
    
    properties(Constant)
        %---COLOR DEFINITIONS---%
        c_black = [0 0 0]; % formerly BlackIndex(screenNumber);
        c_white = [1 1 1]; % formerly WhiteIndex(screenNumber);
        c_yellow = [1 1 0];
    end
    
    methods
        function obj = UserInterface(settings)
            
            % Call some default settings for setting up Psychtoolbox
            PsychDefaultSetup(2);
            
            % Skip screen synchronization checks. There can be < 3ms timing
            % errors on some operating systems (Linux has best timing)
            Screen('Preference', 'SkipSyncTests', 1);
            
            %---KEYBOARD SETUP---%
            
            % Needed for the experiment to run on different operating systems with
            % different key code systems
            KbName('UnifyKeyNames');
            
            % Enable all keyboard keys for key presses
            RestrictKeysForKbCheck([]);

            %---SCREEN SETUP---%

            % Get the screen numbers
            screens = Screen('Screens');

            % Select the external screen if it is present, else revert to the native
            % screen
            screenNumber = max(screens);

            % Open an on screen window and color it grey
            [obj.window, obj.windowRect] = PsychImaging('OpenWindow', screenNumber, obj.c_black);

            % Set the blend function for the screen
            Screen('BlendFunction', obj.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

            % Get the size of the on screen window in pixels
            % For help see: Screen WindowSize?
            [obj.screenXpixels, obj.screenYpixels] = Screen('WindowSize', obj.window);

            % Get the centre coordinate of the window in pixels
            % For help see: help RectCenter
            [obj.xCenter, obj.yCenter] = RectCenter(obj.windowRect);

            %---SOUND SETUP---%

            % Initialize snd driver
            InitializePsychSound(1);

            % Number of channels and Frequency of the sound
            snd_nrchannels = 2;
            snd_playbackFreq = 48000;

            % How many times to we wish to play the sound
            obj.snd_repetitions = 1;

            % Start immediately (0 = immediately)
            obj.snd_startCue = 0;

            % Should we wait for the device to really start (1 = yes)
            % INFO: See help PsychPortAudio
            obj.snd_waitForDeviceStart = 1;
            
            % Adding a small sound latency makes the beginning of the sound
            % cleaner. If this is set to 0, sound card may attempt to
            % start playing the sound before everything is actually ready.
            % Setting this to zero seems to work fine on at least one 
            % machine, otherwise try setting it to 0.015. Always make sure 
            % to look at the actual timing data (ie. compare SSD_intended 
            % with SSD_actual) to see how things are working. 
            % This latency is NOT accounted for when playing the sound in
            % the experiment - although the actual time when the sound 
            % starts playing is used to calculate SSD_actual.
            obj.snd_latency = 0;

            % Open Psych-Audio port, with the follow arguements
            % (1) [] = default snd device
            % (2) 1 = snd playback only
            % (3) [] = default level of latency
            % (4) Requested frequency in samples per second
            % (5) 2 = stereo output
            % (6) Set latency
            obj.snd_pahandle = PsychPortAudio('Open', [], 1, [], snd_playbackFreq, snd_nrchannels, [], obj.snd_latency);

            % Set the volume to full (change 1 to eg. 0.5 for half volume)
            volume = 1;
            PsychPortAudio('Volume', obj.snd_pahandle, volume);

            % Make a beep which we will play back to the user
            obj.snd_stopBeep = MakeBeep(settings.BeepFreq, settings.StopSignalDur, snd_playbackFreq);
            
            % Fill the audio playback buffer with the audio data, doubled for stereo
            % presentation
            PsychPortAudio('FillBuffer', obj.snd_pahandle, [obj.snd_stopBeep; obj.snd_stopBeep]);
            
            if strcmpi(settings.StopSignalType, 'auditory')
                % Play an initial beep to get the sound card started
                % (otherwise, you get high latency on the first stop trial)
                PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
                pause(settings.StopSignalDur + 0.010)
                PsychPortAudio('Stop', obj.snd_pahandle)
            end
            
            %---IMAGE SETUP---%

            arrow_img_left = double(imread('media/Left_Arrow.bmp'));
            arrow_img_right = double(imread('media/Right_Arrow.bmp'));
            arrow_img_up = double(imread('media/Up_Arrow.bmp'));

            obj.arrow_tex_left = Screen('MakeTexture', obj.window, arrow_img_left);
            obj.arrow_tex_right = Screen('MakeTexture', obj.window, arrow_img_right);
            obj.arrow_tex_up = Screen('MakeTexture', obj.window, arrow_img_up);
            
            [arrow_s1, arrow_s2, ~] = size(arrow_img_left); % arrow_img_right is same size, up arrow has aspect ratio reversed
            
            % Get the aspect ratio of the image. We need this to maintain the aspect
            % ratio of the image. Otherwise, if we don't match the aspect 
            % ratio the image will appear warped / stretched
            arrow_aspectRatio = arrow_s2 / arrow_s1;
            
            lr_arrow_height = 0.01*settings.ArrowSize*obj.screenXpixels;
            
            lr_arrow_width = lr_arrow_height * arrow_aspectRatio;
            
            obj.lr_arrow_rect = [0 0 lr_arrow_width lr_arrow_height];
            obj.up_arrow_rect = [0 0 lr_arrow_height lr_arrow_width]; % Width/height reversed due to 90 deg rotation
            
            obj.lr_arrow_rect = CenterRectOnPointd(obj.lr_arrow_rect, obj.screenXpixels / 2, obj.screenYpixels / 2);
            obj.up_arrow_rect = CenterRectOnPointd(obj.up_arrow_rect, obj.screenXpixels / 2, obj.screenYpixels / 2);
        end
        
        
        quitKeyPressed = ShowInstructions(obj, settings);
        
        [triggerTimestamp, sessionStartDateTime, quitKeyPressed] = ShowReadyTrigger(obj, settings);
        
        [onsetTimestamp, offsetTimestamp, quitKeyPressed] = ShowFixation(obj, duration, settings, runningVals);
        
        [onsetTimestamp, offsetTimestamp, quitKeyPressed] = ShowBlank(obj, duration, settings, runningVals);
        
        [trials, runningVals, quitKeyPressed] = RunNextTrial(obj, trials, settings, runningVals);
        
    end
    
    methods (Access = private)
        DrawPerformanceMetrics(obj, settings, runningVals);
        quitKeyPressed = WaitAndCheckQuit(obj, duration, settings);
    end
end