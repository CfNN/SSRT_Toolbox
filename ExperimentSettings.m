% Set to "true" to display live performance metrics at the bottom of the 
% "Blank" screen during the experiment. To hide metrics, set to "false"
settings.DisplayPerfMetrics = true;

% Initial stop signal delay (SSD) times for staircases 1 and 2. Naming
% convention from E-Prime experiment used. 
settings.g_nGoDur_initial = 0.200; % seconds
settings.g_nGoDur2_initial = 0.300; % seconds

% The stop signal delay (SSD) changes +/- between trials by this amount of
% time (staircase procedure)
settings.delta_t = 0.050; % seconds

% Duration of stop signal beep. g_nInhDur in E-Prime.
settings.InhDur = 0.250; % seconds

% Frequency of the stop signal beep tone
settings.BeepFreq = 500; %Hz

% Total trial duration. g_TrialDur in E-Prime.
settings.TrialDur = 1.0; % seconds

% Duration of fixation before each trial
settings.FixationDuration = 0.5; % seconds

% Duration of blank screen after each trial
settings.BlankDuration = 1.0; % seconds