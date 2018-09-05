% Variable for keeping track of the trial number
runningVals.currentTrial = 1;

% Running stop-signal delay (SSD) values for staircases 1 and 2
runningVals.ssd1 = settings.g_nGoDur_initial;
runningVals.ssd2 = settings.g_nGoDur2_initial;

% Running times to display the visual stimulus after the stop beep ends,
% dependent on ssd1 and ssd2:
runningVals.postBeepDelay1 = settings.TrialDur - runningVals.ssd1 - settings.InhDur;
runningVals.postBeepDelay2 = settings.TrialDur - runningVals.ssd2 - settings.InhDur;

% Variables for keeping track of live performance metrics. Go and Stop
% accuracies (GoAcc, StopAcc) are initially displayed as "-1" before any
% data is available. 
runningVals.GoAcc = -1;
runningVals.StopAcc = -1;
runningVals.GoTrialCount = 0;
runningVals.StopTrialCount = 0;
runningVals.GoCorrect = 0;
runningVals.StopCorrect = 0;