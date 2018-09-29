function GenRandomTrialsSimple(n_trials, n_stopTrials)
% GENRANDOMTRIALSSIMPLE - Generates a random block of trials, and saves
% it as a 'trials' struct array to CURRENTTRIALS.mat.
%
% Usage: GenRandomTrialsSimple(n_trials, n_stopTrials);
% 
% Eg. GenRandomTrialsSimple(32, 8) generates a block of 32 trials with 8
% stop trials (and 24 go trials).
%
% n_trials: Total number of trials in the session
%
% n_stopTrials: Number of stop trials in session - the rest are go trials
%
% See also GENRANDOMTRIALS
% ----------------------------------

GenRandomTrials(n_trials, n_stopTrials, 0, n_trials);

end