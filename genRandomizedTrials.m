function genRandomizedTrials(n_trials, n_stopTrials, n_enforcedInitialGoTrials, n_maxConsecStopTrials)
% GENRANDOMIZEDTRIALS - Generates a pseudo-random block of trials. Trial
% order is random with certain enforced features (see below).
%
% Usage: genRandomizedTrials(n_trials, n_stopTrials, n_enforcedInitialGoTrials, n_maxConsecStopTrials); 
%
% n_trials: Total number of trials in the session
%
% n_stopTrials: Number of stop trials in session - the rest are go trials
%
% n_enforcedInitialGoTrials: The number of go trials at the beginning of
% the session before any stop trials should be allowed. Set to zero if it's
% alright for there to be stop trials right at the beginning.
% 
% n_maxConsecStopTrials: The maximum number of consecutive stop trials that
% should be allowed. Set equal to n_trials if it doesn't matter if there
% are several consecutive stop trials by chance. 
%
% See also GENRANDOMIZEDTRIALSSIMPLE
% ----------------



% Seed random number generator. Otherwise, same 'random' sequence of
% numbers will be generated each time after opening MATLAB.
rng('shuffle');

% Make sure the parameters are reasonable and will not cause weird errors 
% in the trial generation algorithm 
assert(mod(n_trials, 2) == 0, 'Choose an even number of trials');
assert(mod(n_stopTrials, 2) == 0, 'Choose an even number of stop trials');
assert(n_stopTrials <= n_trials, 'Choose a number of stop trials less than or equal to the total number of trials');
assert(n_maxConsecStopTrials > 0, 'n_maxConsecStopTrials must be greater than 0');
assert(n_enforcedInitialGoTrials <= n_trials - n_stopTrials, 'Number of enforced initial go trials greater than the total number of go trials');

% Variables for counting how many trials for each type are remaining
count_StITrials = n_stopTrials/2;
count_StITrial2s = n_stopTrials/2;
count_GoTrials = n_trials - n_stopTrials;
consecStopTrials = 0;

trialCountErrorCheck(0, n_trials, count_StITrials, count_StITrial2s, count_GoTrials)

trials(n_trials) = struct();

% Set up a specified number of enforced "go" trials at the beginning of the
% experiment (may not want a stop trial in the first n trials, as the 
% participant gets used to the task). 
if (n_enforcedInitialGoTrials ~= 0)
    for i = 1:n_enforcedInitialGoTrials
        trials = assignTrial(trials, i, 'go', NaN);
        count_GoTrials = count_GoTrials - 1;
        trialCountErrorCheck(i, n_trials, count_StITrials, count_StITrial2s, count_GoTrials);
    end
        
    j = n_enforcedInitialGoTrials + 1;
else
    j = 1;
end

stopTrialProbability = n_stopTrials / (n_trials - n_enforcedInitialGoTrials);

for i = j:numel(trials)
    
    stopTrial = rand < stopTrialProbability;
    
    if (count_StITrials == 0 && count_StITrial2s == 0)
        % No remaining stop trials, force go trial
        stopTrial = false;
    elseif (count_GoTrials == 0)
        % No remaining go trials, force stop trial
        stopTrial = true;
    end
    
    if consecStopTrials >= n_maxConsecStopTrials && count_GoTrials > 0
        % Reached maximum number of consecutive stop trials, force go trial
        stopTrial = false;
    end
    
    if stopTrial && (count_StITrials > 0 || count_StITrial2s > 0)
        
        % Stop trial. Choose staircase number 1 or 2:
        if (count_StITrials > 0 && count_StITrial2s > 0)
            staircaseNum = round(rand)+1;
        elseif (count_StITrials > 0 && count_StITrial2s == 0)
            staircaseNum = 1;
        elseif (count_StITrials == 0 && count_StITrial2s > 0)
            staircaseNum = 2;
        else
            error('No more stop trials - check code for trial type counting');
        end
        
        trials = assignTrial(trials, i, 'stop', staircaseNum);
        
        if staircaseNum == 1
            count_StITrials = count_StITrials-1;
        elseif staircaseNum == 2
            count_StITrial2s = count_StITrial2s-1;
        else
            error('Staircase number should have been set to 1 or 2');
        end
        
        consecStopTrials = consecStopTrials + 1;
        
    elseif ~stopTrial && (count_GoTrials > 0)
        % Go trial.
        trials = assignTrial(trials, i, 'go', NaN);
        count_GoTrials = count_GoTrials - 1;
        consecStopTrials = 0;
    else 
        error('No stop or go trials remaining (incorrect code or parameters?)');
    end
    
    trialCountErrorCheck(i, n_trials, count_StITrials, count_StITrial2s, count_GoTrials);
end

% Assign random left/right arrow stimuli
dirs = {};
[dirs{1:n_trials/2}] = deal('Left_Arrow.bmp');
[dirs{n_trials/2+1:n_trials}] = deal('Right_Arrow.bmp');
dirs = dirs(randperm(n_trials));

for i = 1:numel(dirs)
    trials(i).Stimulus = dirs{i};
    if strcmpi(trials(i).Stimulus, 'Left_Arrow.bmp')
        trials(i).CorrectAnswer = 1;
    elseif strcmpi(trials(i).Stimulus, 'Right_Arrow.bmp')
        trials(i).CorrectAnswer = 2;
    end
    
    if strcmpi(trials(i).Procedure, 'StITrial') || strcmpi(trials(i).Procedure, 'StITrial2')
        trials(i).CorrectAnswer = 0;
    end
end
clear i;

assignin('base', 'trials', trials);
save('CURRENTTRIALS.mat');

end

% go_stop is 'go' if it's a go trial, 'stop' if it's a stop trial
% staircaseNum should be 1 or 2;
function trials = assignTrial(trials, i, go_stop, staircaseNum)
    
    % Preset trial attributes
    if strcmpi(go_stop, 'go')
        trials(i).Procedure = 'StGTrial';
    elseif strcmpi(go_stop, 'stop') && staircaseNum == 1
        trials(i).Procedure = 'StITrial';
    elseif strcmpi(go_stop, 'stop') && staircaseNum == 2
        trials(i).Procedure = 'StITrial2';
    else 
        error('Invalid trial type or staircase number. Use ''go'' or ''stop'' for go_stop, 1 or 2 for staircaseNum');
    end 
    
    %Set to NaN for now, will be set properly later in the function
    trials(i).Stimulus = NaN;
    trials(i).CorrectAnswer = NaN;
    
    % To be set during/after the trial - initially set to NaN (not a number)
    trials(i).Answer = NaN;
    trials(i).Correct = false; %Boolean indicating whether Answer matches CorrectAnswer
    trials(i).GoRT = NaN;
    trials(i).StopSignalDelay = NaN;
    % Timestamps
    trials(i).GoSignalOnsetTimestamp = NaN;
    trials(i).GoSignalOffsetTimestamp = NaN;
    trials(i).StopSignalOnsetTimestamp = NaN;
    trials(i).StopSignalOffsetTimestamp = NaN;
    trials(i).ResponseTimestamp = NaN;
end

function trialCountErrorCheck(i, n_trials, count_StITrials, count_StITrial2s, count_GoTrials)
    disp({i, 'count_StITrials', count_StITrials, 'count_StITrial2s', count_StITrial2s, 'count_GoTrials', count_GoTrials});
    assert(count_GoTrials + count_StITrials + count_StITrial2s + i == n_trials, 'Error, check code for counting stop/go trial types');
end