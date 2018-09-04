function [goRT, responseCorrect, response] = RunTrial(obj, StopGo, arrowDirection, settings, varargin)
% RUNTRIAL  Run a 'stop' or 'go' SSRT trial and record the response.
%   C = ADDME(A) adds A to itself.
%
%   C = ADDME(A,B) adds A and B together.
%
%   See also SUM, PLUS.

%%%%%%%Function setup and error checking%%%%%%%%%%%%

% Additional arguments for 'stop' trial
SSD = NaN;
soundDuration = NaN;

if ~((length(varargin) == 2 && strcmpi(StopGo,'stop')) || (length(varargin) == 0 && strcmpi(StopGo, 'go')))
    error('Wrong number of inputs. Usage examples: RunTrial(''go'',''left'',trialLength) or RunTrial(''stop'',''left'',trialLength, ''SSD'', stopSigDelay, ''stopSigDuration'', stopSigDuration)');
end

% Load stop-signal arguments, if present:
while ~isempty(varargin)
    switch lower(varargin{1})
        case 'ssd'
            SSD = varargin{2};
        case 'soundduration'
            soundDuration = varargin{2};
        otherwise
            error(['Unexpected function input: ' varargin{1}]);
    end
end

%%%%%%%%%%%%Function start%%%%%%%%%%%%%%%

img = NaN;

if strcmpi(arrowDirection, 'right')
    img = obj.arrow_tex_right;
elseif strcmpi(arrowDirection, 'left')
    img = obj.arrow_tex_left;
else
    error('Invalid arrow direction - use ''right'' or ''left''');
end

Screen('TextSize', obj.window, 16);
Screen('TextFont', obj.window, 'Courier New');
Screen('TextSTyle', obj.window, 0); % 0 is regular (not bold, italicized, etc)

Screen('DrawTexture', obj.window, img, [], [], 0);
DrawFormattedText(obj.window, 'Performance metrics here!', 'center', obj.screenYpixels * 0.96, obj.c_white);
Screen('Flip',obj.window);

if strcmpi(StopGo, 'go')
    WaitSecs(settings.g_TrialDur);
elseif strcmpi(StopGo, 'stop')
    WaitSecs(300);
    PsychPortAudio('Start', obj.snd_pahandle, obj.snd_repetitions, obj.snd_startCue, obj.snd_waitForDeviceStart);
    WaitSecs(700);
else
    error('Invalid input - use ''stop'' or ''go'' for StopGo argument');
end

KbStrokeWait; % Wait for key press

end