function genRandomizedTrials(n_trials, n_stopTrials, n_enforcedInitialGoTrials, n_maxConsecStopTrials)

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
count_leftTrials = n_trials/2;
count_rightTrials = n_trials/2;

trialCountErrorCheck(0, n_trials, count_StITrials, count_StITrial2s, count_GoTrials, count_leftTrials, count_rightTrials)

trials(n_trials) = struct();

% Set up a specified number of enforced "go" trials at the beginning of the
% experiment (may not want a stop trial in the first n trials, as the 
% participant gets used to the task). 
if (n_enforcedInitialGoTrials ~= 0)
    for i = 1:n_enforcedInitialGoTrials
        
        % Choose left or right
        if count_leftTrials > 0 && count_rightTrials > 0
            rnum = rand;
            if rnum < 0.5 && count_leftTrials > 0
                trials = assignTrial(trials, i, 'left', 'go', NaN);
                count_leftTrials = count_leftTrials - 1;
            elseif rnum >= 0.5 && count_rightTrials > 0
                trials = assignTrial(trials, i, 'right', 'go', NaN);
                count_rightTrials = count_rightTrials - 1;
            else
                error('No left or right trials remaining (incorrect code or parameters?)');
            end
        elseif count_leftTrials == 0 && count_rightTrials > 0
            trials = assignTrial(trials, i, 'right', 'go', NaN);
            count_rightTrials = count_rightTrials - 1;
        elseif count_leftTrials > 0 && count_rightTrials == 0
            trials = assignTrial(trials, i, 'left', 'go', NaN);
            count_leftTrials = count_leftTrials - 1;
        else
            error('No left or right trials remaining (incorrect code or parameters?)'); 
        end
        count_GoTrials = count_GoTrials - 1;
        trialCountErrorCheck(i, n_trials, count_StITrials, count_StITrial2s, count_GoTrials, count_leftTrials, count_rightTrials);
    end
        
    j = n_enforcedInitialGoTrials + 1;
else
    j = 1;
end

stopTrialProbability = n_stopTrials / (n_trials - n_enforcedInitialGoTrials);

for i = j:numel(trials)
    
    rnum = rand;
    
    if (count_StITrials == 0 && count_StITrial2s == 0)
        % No remaining stop trials, force go trial
        rnum = 1;
    elseif (count_GoTrials == 0)
        % No remaining go trials, force stop trial
        rnum = 0;
    end
    
    if rnum < stopTrialProbability && (count_StITrials > 0 || count_StITrial2s > 0)
        
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
        
        if staircaseNum == 1
            count_StITrials = count_StITrials-1;
        elseif staircaseNum == 2
            count_StITrial2s = count_StITrial2s-1;
        else
            error('Staircase number should have been set to 1 or 2');
        end
        
        % Staircase number chosen, now choose left or right
        if count_leftTrials > 0 && count_rightTrials > 0
            rnum = rand;
            if rnum < 0.5 && count_leftTrials > 0
                trials = assignTrial(trials, i, 'left', 'stop', staircaseNum);
                count_leftTrials = count_leftTrials - 1;
            elseif rnum >= 0.5 && count_rightTrials > 0
                trials = assignTrial(trials, i, 'right', 'stop', staircaseNum);
                count_rightTrials = count_rightTrials - 1;
            else
                error('No left or right trials remaining (incorrect code or parameters?)');
            end
        elseif count_leftTrials == 0 && count_rightTrials > 0
            trials = assignTrial(trials, i, 'right', 'stop', staircaseNum);
            count_rightTrials = count_rightTrials - 1;
        elseif count_leftTrials > 0 && count_rightTrials == 0
            trials = assignTrial(trials, i, 'left', 'stop', staircaseNum);
            count_leftTrials = count_leftTrials - 1;
        else
            error('No left or right trials remaining (incorrect code or parameters?)'); 
        end
        
    elseif rnum >= stopTrialProbability && (count_GoTrials > 0)
        % Go trial. Now choose left or right
        if count_leftTrials > 0 && count_rightTrials > 0
            rnum = rand;
            if rnum < 0.5 && count_leftTrials > 0
                trials = assignTrial(trials, i, 'left', 'go', NaN);
                count_leftTrials = count_leftTrials - 1;
            elseif rnum >= 0.5 && count_rightTrials > 0
                trials = assignTrial(trials, i, 'right', 'go', NaN);
                count_rightTrials = count_rightTrials - 1;
            else
                error('No left or right trials remaining (incorrect code or parameters?)');
            end
        elseif count_leftTrials == 0 && count_rightTrials > 0
            trials = assignTrial(trials, i, 'right', 'go', NaN);
            count_rightTrials = count_rightTrials - 1;
        elseif count_leftTrials > 0 && count_rightTrials == 0
            trials = assignTrial(trials, i, 'left', 'go', NaN);
            count_leftTrials = count_leftTrials - 1;
        else
            error('No left or right trials remaining (incorrect code or parameters?)'); 
        end
        count_GoTrials = count_GoTrials - 1;
    else 
        error('No stop or go trials remaining (incorrect code or parameters?)');
    end
    
    trialCountErrorCheck(i, n_trials, count_StITrials, count_StITrial2s, count_GoTrials, count_leftTrials, count_rightTrials);
end
clear i;

assignin('base', 'trials', trials);
assignin('base', 'currentTrial', 1);

end

% go_stop is 'go' if it's a go trial, 'stop' if it's a stop trial
% staircaseNum should be 1 or 2;
function trials = assignTrial(trials, i, arrowDirection, go_stop, staircaseNum)
    
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
   
    if strcmpi(arrowDirection, 'left')
        trials(i).Stimulus = 'Left_Arrow.bmp';
        trials(i).CorrectAnswer = 1;
    elseif strcmpi(arrowDirection, 'right')
        trials(i).Stimulus = 'Right_Arrow.bmp';
        trials(i).CorrectAnswer = 2;
    else
        error('Invalid arrow direction, use ''left'' or ''right''');
    end
    
    if strcmpi(go_stop, 'stop')
        trials(i).CorrectAnswer = [];
    end
    
    % To be set during/after the trial - initially set to NaN (not a number)
    trials(i).Answer = NaN;
    trials(i).Correct = NaN; %Boolean indicating whether Answer matches CorrectAnswer
    trials(i).GoRT = NaN;
    trials(i).StopSignalDelay = NaN;
    % Timestamps
    trials(i).GoSignalTimestamp = NaN;
    trials(i).StopSignalTimestamp = NaN;
    trials(i).ReactionTimestamp = NaN;
end

function trialCountErrorCheck(i, n_trials, count_StITrials, count_StITrial2s, count_GoTrials, count_leftTrials, count_rightTrials)
    disp({i, 'count_StITrials', count_StITrials, 'count_StITrial2s', count_StITrial2s, 'count_GoTrials', count_GoTrials, 'count_leftTrials', count_leftTrials, 'count_rightTrials', count_rightTrials});
    assert(count_GoTrials + count_StITrials + count_StITrial2s + i == n_trials, 'Error, check code for counting stop/go trial types');
    assert(count_leftTrials + count_rightTrials + i == n_trials, 'Error, check code for counting left/right trial types');
end