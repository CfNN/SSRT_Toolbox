function GenRandomTrials(n_trials, n_stopTrials, n_enforcedInitialGoTrials, n_maxConsecStopTrials)
% GENRANDOMTRIALS - Generates a pseudo-random block of trials. Trial
% order is random with certain enforced features (see below).
%
% Usage: GenRandomTrials(n_trials, n_stopTrials, n_enforcedInitialGoTrials, n_maxConsecStopTrials); 
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
% See also GENRANDOMTRIALSSIMPLE
% ----------------

% Seed random number generator. Otherwise, same 'random' sequence of
% numbers will be generated each time after opening MATLAB.
rng('shuffle');

% Make sure that the parameters are reasonable
assert(n_stopTrials <= n_trials, 'Choose a number of stop trials less than or equal to the total number of trials');
assert(n_maxConsecStopTrials > 0, 'n_maxConsecStopTrials must be greater than 0');
assert(n_enforcedInitialGoTrials <= n_trials - n_stopTrials, 'Number of enforced initial go trials must be less than or equal to the total number of go trials');
assert(mod(n_stopTrials, 2) == 0, 'Choose an even number of stop trials to balance the two staircases');
% Find (conservatively) the minimum number of go trials needed to separate
% maximum-sized consecutive groups of stop trials - make sure that the 
% actual number of go trials exceeds this. 
assert((n_trials - n_enforcedInitialGoTrials - n_stopTrials) > (n_stopTrials/n_maxConsecStopTrials-1), 'Too many stop trials, or too few consecutive stop trials allowed');

trials(n_trials) = struct();

for i = 1:n_trials
    
    % Initially set every trial to be a "go" trial
    trials(i).Procedure = 'StGTrial';
    
    % Randomly choose a left or right arrow for the go stimulus
    if rand < 0.5
        trials(i).Stimulus = 'Left_Arrow.bmp';
        trials(i).CorrectAnswer = 1;
    else
        trials(i).Stimulus = 'Right_Arrow.bmp';
        trials(i).CorrectAnswer = 2;
    end
    
    % To be set during/after the trial - initially set to NaN (not a number)
    trials(i).Answer = NaN;
    trials(i).Correct = false; %Boolean indicating whether Answer matches CorrectAnswer
    trials(i).GoRT = NaN;
    trials(i).SSD_intended = NaN;
    trials(i).SSD_actual = NaN;
    % Timestamps
    trials(i).GoSignalOnsetTimestamp = NaN;
    trials(i).GoSignalOffsetTimestamp = NaN;
    trials(i).StopSignalOnsetTimestamp = NaN;
    trials(i).StopSignalOffsetTimestamp = NaN;
    trials(i).ResponseTimestamp = NaN;
end

possibleStopTrialPos = n_enforcedInitialGoTrials+1:n_trials;
stopTrialInds = randsample(possibleStopTrialPos, n_stopTrials);

% Boolean vector to keep track of which trials are stop trials
stop_trial = false(n_trials, 1);
stop_trial(stopTrialInds) = true;

% Assume that there might initially be too many consecutive stop trials 
% somewhere in the array
tooManyConsecutiveStopTrials = true; 

while(tooManyConsecutiveStopTrials)
    tooManyConsecutiveStopTrials = false;
    
    nConsecStop = 0;
    for i = 1:n_trials
        if stop_trial(i)
            nConsecStop = nConsecStop + 1;
            if nConsecStop > n_maxConsecStopTrials
                tooManyConsecutiveStopTrials = true;
                stop_trial(i) = false;
                % Choose a random go trial, after the enforced period of 
                % initial go trials, to change to a stop trial
                newStopTrialLoc = randsample(find(not(stop_trial(n_enforcedInitialGoTrials+1:end) )), 1) + n_enforcedInitialGoTrials; %#ok<COLND>
                stop_trial(newStopTrialLoc) = true;
            end
        else
            nConsecStop = 0;
        end

    end
end

% Set a random half of the stop trials to staircase 1, the other half will
% be staircase 2
staircase1 = false(size(stop_trial));
staircase1(randsample(find(stop_trial), n_stopTrials/2)) = true;

for i = 1:n_trials
    if stop_trial(i)
        if staircase1(i)
            trials(i).Procedure = 'StITrial';
        else
            trials(i).Procedure = 'StITrial2';
        end
        trials(i).CorrectAnswer = 0;
    end
end

assignin('base', 'trials', trials);

end