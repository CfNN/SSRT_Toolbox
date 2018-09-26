% This script sets the runningVals variables, which are used to keep track
% of the current trial number, changing stop-signal delay values, and live
% performance metrics optionally displayed at the bottom of the screen (to
% disable/enable live performance metrics, see ExperimentSettings). 

% Variable for keeping track of the trial number
runningVals.currentTrial = 1;

% Running stop-signal delay (SSD) values for staircases 1 and 2
runningVals.ssd1 = settings.g_nGoDur_initial;
runningVals.ssd2 = settings.g_nGoDur2_initial;

% delta_t values for staircases 1 and 2, will decrease over the course of
% the experiment if settings.delta_t_decay is set to less than 1
runningVals.delta_t_1 = settings.delta_t_initial;
runningVals.delta_t_2 = settings.delta_t_initial;

% Variables for keeping track of live performance metrics. Go and Stop
% accuracies (GoAcc, StopAcc) are initially displayed as "-1" before any
% data is available. 
runningVals.GoAcc = -1;
runningVals.StopAcc = -1;
runningVals.LastGoRT = -1;
runningVals.GoTrialCount = 0;
runningVals.StopTrialCount = 0;
runningVals.GoCorrect = 0;
runningVals.StopCorrect = 0;