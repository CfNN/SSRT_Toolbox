% INVESTIGATOR: Edit this file to customize the parameters of your SSRT
% experiment. Note that these values should not change during the entire
% experiment session (the running ssd values are stored in runningVals). 

% Set the name of the experiment, which will be added to the name of saved
% data files:
settings.ExperimentName = 'SSRT';

% Set whether the stop signal is 'auditory' (beep) or 'visual' (up arrow)
settings.StopSignalType = 'visual';

% Set whether an MRI trigger will be used to start the experiment session
% (otherwise a key press will be used)
settings.UseMRITrigger = false;

% Set to "true" to display live performance metrics at the bottom of the 
% screen during the experiment session. To hide metrics, set to "false"
settings.DisplayPerfMetrics = false;

% Set to "true" to use a variable fixation cross duration, chosen for each
% trial from a truncated exponential distribution. Set to "false" to use a
% constant fixation duration, specified below as settings.FixationDur
settings.VariableFixationDur = true;
% Parameters for fixation duration distribution (truncated exponential):
% NOT APPLICABLE if settings.VariableFixationDur is set to false
settings.FixDurMean = 1; % seconds
settings.FixDurMin = 0.4; % seconds
settings.FixDurMax = 3.9; % seconds

% Constant duration of fixation before each trial
% NOT APPLICABLE if settings.VariableFixationDur is set to true
settings.FixationDur = 0.5; % seconds

% Duration to display fixation cross before and after running the trials
% (e.g. to collect 'resting' data and avoid truncating HRF in MRI studies)
settings.SessionStartFixationDur = 4; % seconds
settings.SessionEndFixationDur = 4; % seconds

% The stop signal delay (SSD) changes +/- between trials by this amount of
% time (staircase procedure)
settings.delta_t_initial = 0.050; % seconds

% This allows the delta_t values to decay exponentially over the course of
% the experiment. Because two interleaved staircases are used,
% delta_t_decay is actually split into runningVals.delta_t_decay1 and
% runningVals.delta_t_decay2 - one distinct value for each staircase. 
% Set the value to 1 to keep delta_t constant throughout the experiment
% session. For an experiment session with 32 stop trials and 
% delta_t_initial, of 0.050s, a value of 0.9 seems to work well. Try running 
% the "visualize_staircase_decay" script in the misc_tools folder to see 
% what happens to delta_t with different starting values and decay values. 
settings.delta_t_decay = 1;

% Duration of stop signal beep. g_nInhDur in E-Prime version. 
settings.StopSignalDur = 0.250; % seconds

% Frequency of the stop signal beep tone (if using auditory stop signal)
settings.BeepFreq = 500; %Hz

% Total trial duration. g_TrialDur in E-Prime version.
settings.TrialDur = 1.0; % seconds

% Duration of blank screen after each trial
settings.BlankDur = 0.100; % seconds

% Size of arrow graphics (arbitrary units). Make larger/smaller to change
% size of the arrows displayed during trials. 
settings.ArrowSize = 10; % 10 is a good starting point