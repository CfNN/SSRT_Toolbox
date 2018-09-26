% Run this script to load all of the .mat files in the data_analysis
% folder, and combine the data into 3D arrays. Separate 3D arrays are 
% produced for each variable in the "trials" struct array, and are further
% separated into 'stop_...' and 'go_...' for stop trials and go trials. For
% example, 

% Get a list of .mat files in data_merge folder
dirs = dir('session_files/*.mat');
filenames = {dirs.name};

% Contains the subject number, session number, handedness, number of go and
% stop trials in each file. Note that ordering depends on the names of the
% files, and not necessarily on subject/session numbers in a logical way. 
mergeSummary(numel(filenames)) = struct('filename', [], 'subjectNumber', [], 'sessionNumber', [], 'subjectHandedness', [], 'goTrialCount', [], 'stopTrialCount', []);

% It is necessary to keep track of how many trials each participant
% completed in each section. Otherwise, it is tricky to make sure that
% missing trials aren't affecting calculations related to the number of
% trials completed (eg. proportion of correct stop trials). Index using
% [subjectNumber, sessionNumber]. 
% Eg. 
go_TrialCounts = []; % Initialize properly after first pass through data file
stop_TrialCounts = [];

% First pass through the files, checking for duplicates, establishing the
% size of the output data arrays
for i = 1:numel(filenames)
    filename = filenames{i};
    mergeSummary(i).filename = filename;
    load(['session_files\' filename]);
    
    mergeSummary(i).subjectNumber = subjectNumber;
    mergeSummary(i).sessionNumber = sessionNumber;
    mergeSummary(i).subjectHandedness = subjectHandedness;
    
    % Check for duplicate files before proceeding
    for j = 1:i-1
        if mergeSummary(i).subjectNumber == mergeSummary(j).subjectNumber && mergeSummary(i).sessionNumber == mergeSummary(j).sessionNumber
            error(['Apparent duplicate files exist for subject ' num2str(subjectNumber) ' and session ' num2str(sessionNumber)]);
        end
    end
    clear j;
    
    % Count the number of go trials
    mergeSummary(i).goTrialCount = nnz(strcmpi({trials.Procedure}, 'StGTrial'));
    % Count the number of stop trials
    mergeSummary(i).stopTrialCount = nnz(strcmpi({trials.Procedure}, 'StITrial')) + nnz(strcmpi({trials.Procedure}, 'StITrial2'));
    
    % Make sure all trials have been counted as either stop or go trials
    assert(mergeSummary(i).goTrialCount + mergeSummary(i).stopTrialCount == numel({trials.Procedure}), 'Check procedure names in ''trials'' struct array and/or code for counting stop/go trials in data merge script');
    
end

goDataSize = [max([mergeSummary.subjectNumber]), max([mergeSummary.sessionNumber]), max([mergeSummary.goTrialCount])];
stopDataSize = [max([mergeSummary.subjectNumber]), max([mergeSummary.sessionNumber]), max([mergeSummary.stopTrialCount])];

% Initialize 3D matrices (of numbers) or cell arrays (of strings) for each measure
go_Stimulus = cell(goDataSize);
go_CorrectAnswer = nan(goDataSize);
go_Answer = nan(goDataSize);
go_Correct = false(goDataSize);
go_GoRT = nan(goDataSize);
go_GoSignalOnsetTimestamp = nan(goDataSize);
go_GoSignalOffsetTimestamp = nan(goDataSize);
go_ResponseTimestamp = nan(goDataSize);

stop_Stimulus = cell(stopDataSize);
stop_CorrectAnswer = nan(stopDataSize);
stop_Answer = nan(stopDataSize);
stop_Correct = false(stopDataSize);
stop_GoRT = nan(stopDataSize);
stop_GoSignalOnsetTimestamp = nan(stopDataSize);
stop_GoSignalOffsetTimestamp = nan(stopDataSize);
stop_ResponseTimestamp = nan(stopDataSize);
% The following are only present for stop_, not go_
stop_StopSignalDelay = nan(stopDataSize);
stop_StopSignalOnsetTimestamp = nan(stopDataSize);
stop_StopSignalOffsetTimestamp = nan(stopDataSize);

% Keep track of whether a trial was actually completed at a given 3D 
% array index. Some sessions/participants might have more trials than 
% others, and there might be participants that drop out of the study - you
% might end up with participant numbers like 1, 2, and 5. These anomalies
% will leave large swathes of NaN's in the data, in which case operations
% like counting trials become less straightforward. 
go_IsTrial = false(goDataSize); 
stop_IsTrial = false(stopDataSize);

go_TrialCounts = zeros(max([mergeSummary.subjectNumber]), max([mergeSummary.sessionNumber]));
stop_TrialCounts = zeros(max([mergeSummary.subjectNumber]), max([mergeSummary.sessionNumber]));

% Second pass - this time, load the data into the arrays
for i = 1:numel(filenames)
    filename = filenames{i};
    load(['session_files/' filename]);
    
    go_TrialCounts(subjectNumber, sessionNumber) = mergeSummary(i).goTrialCount;
    stop_TrialCounts(subjectNumber, sessionNumber) = mergeSummary(i).stopTrialCount;
    
    % Find indexes of all go and stop trials in each session
    goTrialInds = strcmpi({trials.Procedure}, 'StGTrial');
    stopTrialInds = logical(strcmpi({trials.Procedure}, 'StITrial') + strcmpi({trials.Procedure}, 'StITrial2'));
    % Error check
    assert(isequal(goTrialInds, ~stopTrialInds), 'Check Procedure names in "trials" in session files, also check merge script code');
    
    go_Stimulus(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = {trials(goTrialInds).Stimulus};
    go_CorrectAnswer(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).CorrectAnswer];
    go_Answer(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).Answer];
    go_Correct(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).Correct];
    go_GoRT(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).GoRT];
    go_GoSignalOnsetTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).GoSignalOnsetTimestamp];
    go_GoSignalOffsetTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).GoSignalOffsetTimestamp];
    go_ResponseTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).ResponseTimestamp];
    
    stop_Stimulus(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = {trials(stopTrialInds).Stimulus};
    stop_CorrectAnswer(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).CorrectAnswer];
    stop_Answer(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).Answer];
    stop_Correct(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).Correct];
    stop_GoRT(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).GoRT];
    stop_GoSignalOnsetTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).GoSignalOnsetTimestamp];
    stop_GoSignalOffsetTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).GoSignalOffsetTimestamp];
    stop_ResponseTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).ResponseTimestamp];
    % The following are only present for stop_, not go_
    stop_StopSignalDelay(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).StopSignalDelay];
    stop_StopSignalOnsetTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).StopSignalOnsetTimestamp];
    stop_StopSignalOffsetTimestamp(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).StopSignalOffsetTimestamp];
    
    go_IsTrial(subjectNumber, sessionNumber, 1:mergeSummary(i).goTrialCount) = ~isnan([trials(goTrialInds).GoSignalOnsetTimestamp]);
    stop_IsTrial(subjectNumber, sessionNumber, 1:mergeSummary(i).stopTrialCount) = ~isnan([trials(stopTrialInds).GoSignalOnsetTimestamp]);
    
end

clear trials settings subjectNumber sessionNumber subjectHandedness;
clear i dirs filenames filename;
clear goDataSize stopDataSize goTrialInds stopTrialInds;

save(['merged_' num2str(numel(unique([mergeSummary.subjectNumber]))) 'subjects']);