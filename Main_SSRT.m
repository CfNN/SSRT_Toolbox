% Author: Morgan Talbot, morgan_talbot@alumni.brown.edu
% To run an experiment session, enter "Main_SSRT" into the MATLAB console, 
% or press the "Run" betton in the menu above under the "EDITOR" tab. 


% Giant try-catch block enables PsychToolbox to exit gracefully in the
% event of an error (rather than freezing and possibly requiring reboot)
try
    % Clear the workspace and the screen, close all plot windows
    close all;
    clear;
    
    try
        sca;
    catch e
        disp("It looks like PsychToolbox is not installed correctly!")
        rethrow(e)
    end

    % Shuffle random number generator (necessary to avoid getting the same
    % "random" numbers each time
    rng('shuffle');

    % Set the current MATLAB folder to the folder where this script is stored
    disp('Setting the current MATLAB folder to the location of this script');
    cd(fileparts(which(mfilename)));

    % Make sure the code files in /code_backend and other directories are accessible to MATLAB
    disp('Adding code directories to MATLAB search path');
    addpath('./code_backend/');
    addpath('./data_analysis/');
    addpath('./software_tests/');

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
    % Clean up the settings variables (removing any unused variables)
    ExperimentSettingsCleanup;

    % Set up running values that change during the experiment session (live 
    % performance metrics, two changing stop-signal delays associated with the 
    % two staircases) 
    InitRunningVals;
    
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
    quitKeyPressed = ui.ShowInstructions(settings);
    if quitKeyPressed
        cleanup(settings);
        return  % End session
    end

    % Use the ui to show the "ready" screen with a timer, and wait for the MRI
    % trigger (or a key press, depending on what is specified in
    % ExperimentSettings.m)
    % IMPORTANT: sessionStartDateTime is not exactly the same as
    % triggerTimestamp, there is be a (tiny) time difference between when
    % the two are recorded! For this reason, always use triggerTimestamp for 
    % important calculations if possible. 
    [triggerTimestamp, sessionStartDateTime, quitKeyPressed] = ui.ShowReadyTrigger(settings);
    if quitKeyPressed
        cleanup(settings);
        return  % End session
    end

    % Use the ui to show a fixation cross for the specified amount of time in
    % seconds
    [sessionStartFixationOnsetTimestamp, sessionStartFixationOffsetTimestamp, quitKeyPressed] = ui.ShowFixation(settings.SessionStartFixationDur, settings, runningVals);
    if quitKeyPressed
        cleanup(settings);
        return  % End session
    end
    
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
        [trials(runningVals.currentTrial).FixationOnsetTimestamp, trials(runningVals.currentTrial).FixationOffsetTimestamp, quitKeyPressed] = ui.ShowFixation(fixationDur, settings, runningVals); %#ok<SAGROW>
        if quitKeyPressed
            cleanup(settings);
            return  % End session
        end
        
        % Run the go or stop trial (depending on what is in this row of the
        % trial struct)
        [trials, runningVals, quitKeyPressed] = ui.RunNextTrial(trials, settings, runningVals);
        if quitKeyPressed
            cleanup(settings);
            return  % End session
        end

        % Update the live performance metrics that are optionally displayed on
        % the screen (see ExperimentSettings.m to disable/enable)
        runningVals = UpdateLivePerfMetrics(runningVals);

        % Show a blank screen
        [trials(runningVals.currentTrial).BlankOnsetTimestamp, trials(runningVals.currentTrial).BlankOffsetTimestamp, quitKeyPressed] = ui.ShowBlank(settings.BlankDur, settings, runningVals);
        if quitKeyPressed
            cleanup(settings);
            return  % End session
        end

        % Autosave data in case the experiment is interrupted partway through
        save(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '_AUTOSAVE.mat'], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'subjectHandedness', 'triggerTimestamp', 'sessionStartDateTime', 'sessionStartFixationOnsetTimestamp', 'sessionStartFixationOffsetTimestamp');

        % Advance iterator to next trial
        runningVals.currentTrial = runningVals.currentTrial + 1;
    end

    % Use the ui to show a fixation cross for the specified amount of time in
    % seconds
    [sessionEndFixationOnsetTimestamp, sessionEndFixationOffsetTimestamp, quitKeyPressed] = ui.ShowFixation(settings.SessionEndFixationDur, settings, runningVals);
    if quitKeyPressed
        cleanup(settings);
        return  % End session
    end
    
    cleanup(settings);

    % Save the data to a .mat, delete autosaved version
    save(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '.mat'], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'subjectHandedness', 'triggerTimestamp', 'sessionStartDateTime', 'sessionStartFixationOnsetTimestamp', 'sessionStartFixationOffsetTimestamp', 'sessionEndFixationOnsetTimestamp', 'sessionEndFixationOffsetTimestamp');
    delete(['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '_AUTOSAVE.mat']);

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

catch e
    cleanup(settings);
    rethrow(e);
end

function cleanup(settings)
    % Shut down audio if used
    if strcmpi(settings.StopSignalType, 'auditory')
        PsychPortAudio('Close');
    end
    % Clear the screen and unneeded variables
    sca;
    clear ui filename;
end
