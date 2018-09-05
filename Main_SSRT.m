% Run this script to run an experiment session. To do this from the MATLAB
% console, enter "Main_SSRT" and press enter. 

% Timestamp for beginning of experiment
sessionStartTime = datevec(now);

% Clear the workspace and the screen
close all;
clearvars;
sca;

% Set user-defined variables to configure experiment. creates a workspace
% struct variable called 'settings'. Settings variables should NEVER change
% during the experiment session. 
ExperimentSettings;

% Set up running values that change during the experiment session (live 
% performance metrics, two changing stop-signal delays associated with the 
% two staircases) 
InitRunningVals;

% Contains the pre-generated "trials" struct array
load CURRENTTRIALS.mat

% Use dialog boxes to get session info from the experimenter
[subjectNumber, sessionNumber, subjectHandedness, cancelled] = GetSessionConfig();
if (cancelled)
    clear cancelled;
    disp('Session cancelled by experimenter');
    return;
else
    clear cancelled;
end

% Initialize the user interface (ui) and PsychToolbox
ui = UserInterface(settings);

% Use the ui to show experiment instructions
ui.ShowInstructions();

% Use the ui to show the "ready" screen with a timer
ui.ShowReadyTimer();

% Use the ui to show a fixation screen for the specified amount of time in
% seconds
ui.ShowFixation(0.5, runningVals);

% Loop through the trials structure (note - runningVals.currentTrial keeps
% track of which trial you are on)
while (runningVals.currentTrial <= length(trials))
    % Show the fixation cross
    ui.ShowFixation(settings.FixationDuration, runningVals);
    
    % Run the go or stop trial (depending on what is in this row of the
    % trial struct)
    [trials, runningVals] = ui.RunNextTrial(trials, runningVals);
    
    % Update the live performance metrics that are optionally displayed on
    % the screen (see ExperimentSettings.m to disable/enable)
    runningVals = UpdateLivePerfMetrics(runningVals);
    
    % Show a blank screen
    ui.ShowBlank(settings.FixationDuration, runningVals);
    
    % Autosave in case the experiment is interrupted
    save(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_AUTOSAVE.mat']);
end

% Clear the screen
sca;

% Save the data to a .mat, delete autosaved version
save(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '.mat']);
delete(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_AUTOSAVE.mat']);

% Clear unneeded variables. Experiment session ends after this line. 
sca;
clear ui filename;