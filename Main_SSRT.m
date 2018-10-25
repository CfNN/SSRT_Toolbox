% To run an experiment session, enter "Main_SSRT" into the MATLAB console, 
% or press the "Run" betton in the menu above under the "EDITOR" tab. 

% Clear the workspace and the screen, close all plot windows
close all;
clear;
sca;

% Set the current MATLAB folder to the folder where this script is stored
disp('Setting the current MATLAB folder to the location of this script');
cd(fileparts(which(mfilename)));

% Make sure the code files in /code_backend and other directories are accessible to MATLAB
disp('Adding code directories to MATLAB search path...');
addpath('./code_backend/');
addpath('./data_analysis/');
addpath('./software_tests/');
disp('Finished adding code directories to MATLAB search path');

try
    % Contains the pre-generated "trials" struct array
    load('CURRENTTRIALS.mat', 'trials');
catch
    error('CURRENTTRIALS.mat not found. Generate a trial sequence by running GenRandomTrials.m or GenRandomTrialsSimple.m. Type ''help GenRandomTrials'' or ''help GenRandomTrialsSimple'' in the MATLAB console for information on how to use these functions.');
end

% Set user-defined variables to configure experiment. creates a workspace
% struct variable called 'settings'. Settings variables should NEVER change
% during the experiment session. 
ExperimentSettings;

% Set up running values that change during the experiment session (live 
% performance metrics, two changing stop-signal delays associated with the 
% two staircases) 
InitRunningVals;   

% Timestamps for beginning of experiment
sessionStartDateTime = datevec(now);
runningVals.GetSecsStart = GetSecs;

% Use dialog boxes to get subject number, session number, etc. from the experimenter
[subjectNumber, sessionNumber, subjectHandedness, runningVals, cancelled] = GetSessionConfig(settings, runningVals);
if (cancelled)
    disp('Session cancelled by experimenter');
    return; % Stops this script from running to end the experiment session
end
clear cancelled;

% Initialize the user interface (ui) and PsychToolbox
ui = UserInterface(settings);

% Use the ui to show experiment instructions
ui.ShowInstructions();

% Use the ui to show the "ready" screen with a timer, and wait for the MRI
% trigger (or a key press, depending on what is specified in
% ExperimentSettings.m)
triggerTimestamp = ui.ShowReadyTrigger();

% Use the ui to show a fixation cross for the specified amount of time in
% seconds
ui.ShowFixation(0.5, runningVals);

% Loop through the trials structure (note - runningVals.currentTrial keeps
% track of which trial you are on)
while (runningVals.currentTrial <= length(trials))
    
    if settings.VariableFixationDur
        % Use variable duration fixation cross
        fixationDur = random(truncate(makedist('Exponential',settings.FixDurMean),settings.FixDurMin,settings.FixDurMax));
    else
        % Use fixed duration fixation cross
        fixationDur = settings.FixationDur;
    end
    
    % Show fixation cross (constant or variable duration set above
    % according to ExperimentSettings.m
    trials = ui.ShowFixation(fixationDur, runningVals, trials);
    
    % Run the go or stop trial (depending on what is in this row of the
    % trial struct)
    [trials, runningVals, quitKeyPressed] = ui.RunNextTrial(trials, settings, runningVals);
    
    if quitKeyPressed
        % Clear the screen and unneeded variables
        sca;
        PsychPortAudio('Close');
        clear ui filename;
        % Stop this script from running to end experiment session
        return; 
    end
    
    % Update the live performance metrics that are optionally displayed on
    % the screen (see ExperimentSettings.m to disable/enable)
    runningVals = UpdateLivePerfMetrics(runningVals);
    
    % Show a blank screen
    trials = ui.ShowBlank(settings.BlankDur, runningVals, trials);
    
    % Autosave data in case the experiment is interrupted partway through
    save(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '_AUTOSAVE.mat'], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'subjectHandedness');
    
    % Advance iterator to next trial
    runningVals.currentTrial = runningVals.currentTrial + 1;
end

% Save the data to a .mat, delete autosaved version
save(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '.mat'], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'subjectHandedness');
delete(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '_AUTOSAVE.mat']);

% Clear the screen and unneeded variables.
sca;
PsychPortAudio('Close');
clear ui filename;

% Display SSD values from the end of the session (can be entered into
% ExperimentSettings.m to start the next session with these values):
ssdMsg = {'Stop-signal delays for the two staircases at the end of the session were as follows:',...
       ['SSD 1 = ' num2str(runningVals.ssd1) ' s'],...
       ['SSD 2 = ' num2str(runningVals.ssd2) ' s']};
msgbox(ssdMsg);
for i = 1:length(ssdMsg)
    disp(ssdMsg{i});
end
clear ssdMsg i;
