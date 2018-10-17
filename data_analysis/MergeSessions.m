function filename = MergeSessions(directory)
% Run this function to load all of the .mat files in the data_analysis
% folder, and combine the data into 3D arrays. Separate 3D arrays are 
% produced for each variable in the "trials" struct array, and are further
% separated into 'stop_...' and 'go_...' for stop trials and go trials. For
% example, stop_GoRT and go_GoRT contain the reaction time to the go
% stimulus (if the subject responded) for all stop trials and all go trials
% respectively. Each 3D array contains data from all participants and all
% sessions, and is indexed by participant, session, and trial number in 
% that order - e.g. go_GoRT(2, 3, 8) evaluates to the GoRT of the 8th go
% trial in the 3rd session for participant number 2. 

if nargin == 0
    directory = 'session_files';
    if ~isfolder('session_files')
        error('''session_files'' folder not found - make sure you are in the data_analysis directory in MATLAB when you run this function!');
    end
end

% Get a list of .mat files in the chosen directory
dir_results = dir([directory '/*.mat']);
filenames = {dir_results.name};

assert(numel(filenames) > 0, ['No files found in ' directory]);

% Contains the subject number, session number, handedness, number of go and
% stop trials in each file. Note that ordering depends on the names of the
% files, and not necessarily on subject/session numbers in a logical way. 
mergeSummary(numel(filenames)) = struct('filename', [], 'subjectNumber', [], 'sessionNumber', [], 'subjectHandedness', [], 'goTrialCount', [], 'stopTrialCount', []);

% It is necessary to keep track of how many trials each participant
% completed in each section. Otherwise, it is tricky to make sure that
% missing trials aren't affecting calculations related to the number of
% trials completed (eg. proportion of correct stop trials). Index using
% [subjectNumber, sessionNumber]. 
% % Initialize properly after first pass through data file
go_TrialCounts = []; %#ok<NASGU> 
stop_TrialCounts = []; %#ok<NASGU>

% First pass through the files, checking for duplicates, checking how many
% unique subject numbers there are, establishing the size of the output 
% data arrays
for i = 1:numel(filenames)
    filename = filenames{i};
    mergeSummary(i).filename = filename;
    load([directory '/' filename], 'subjectNumber', 'sessionNumber', 'subjectHandedness', 'trials');
    
    mergeSummary(i).subjectNumber = subjectNumber;
    mergeSummary(i).sessionNumber = sessionNumber;
    if exist('subjectHandedness', 'var')
        mergeSummary(i).subjectHandedness = subjectHandedness;
    end
    
    % Check for duplicate files, and find unique subject numbers
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

subjectRows = sort(unique([mergeSummary.subjectNumber]));
sessionColumns = sort(unique([mergeSummary.sessionNumber]));
    
for i = 1:numel(mergeSummary)
    mergeSummary(i).subjectRow = find(subjectRows == mergeSummary(i).subjectNumber);
    mergeSummary(i).sessionColumn = find(sessionColumns == mergeSummary(i).sessionNumber);
end

goDataSize = [numel(subjectRows), numel(sessionColumns), max([mergeSummary.goTrialCount])];
stopDataSize = [numel(subjectRows), numel(sessionColumns), max([mergeSummary.stopTrialCount])];

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
stop_SSD_intended = nan(stopDataSize);
stop_SSD_actual = nan(stopDataSize);
stop_StopSignalOnsetTimestamp = nan(stopDataSize);
stop_StopSignalOffsetTimestamp = nan(stopDataSize);

% Keep track of whether a trial was actually completed at a given 3D 
% array index. Some sessions/participants might have more trials than 
% others, and there might be participants that drop out of the study - you
% might end up with participant numbers like 1, 2, and 5. These anomalies
% will leave large swathes of NaN's in the data, in which case operations
% like counting trials become less straightforward. 
go_TrialComplete = false(goDataSize); 
stop_TrialComplete = false(stopDataSize);

go_TrialCounts = zeros(numel(subjectRows), numel(sessionColumns));
stop_TrialCounts = zeros(numel(subjectRows), numel(sessionColumns));

% Second pass - this time, load the data into the arrays
for i = 1:numel(mergeSummary)
    filename = mergeSummary(i).filename;
    load([directory '/' filename], 'subjectNumber', 'sessionNumber', 'subjectHandedness', 'trials');
    
    subjectRow = mergeSummary(i).subjectRow;
    sessionColumn = mergeSummary(i).sessionColumn;
    
    go_TrialCounts(subjectRow, sessionColumn) = mergeSummary(i).goTrialCount;
    stop_TrialCounts(subjectRow, sessionColumn) = mergeSummary(i).stopTrialCount;
    
    % Find indexes of all go and stop trials in each session
    goTrialInds = strcmpi({trials.Procedure}, 'StGTrial');
    stopTrialInds = logical(strcmpi({trials.Procedure}, 'StITrial') + strcmpi({trials.Procedure}, 'StITrial2'));
    % Error check
    assert(isequal(goTrialInds, ~stopTrialInds), 'Check Procedure names in "trials" in session files, also check merge script code');
    
    go_Stimulus(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = {trials(goTrialInds).Stimulus};
    go_CorrectAnswer(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).CorrectAnswer];
    go_Answer(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).Answer];
    go_Correct(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).Correct];
    go_GoRT(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).GoRT];
    go_GoSignalOnsetTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).GoSignalOnsetTimestamp];
    go_GoSignalOffsetTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).GoSignalOffsetTimestamp];
    go_ResponseTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = [trials(goTrialInds).ResponseTimestamp];
    
    stop_Stimulus(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = {trials(stopTrialInds).Stimulus};
    stop_CorrectAnswer(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).CorrectAnswer];
    stop_Answer(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).Answer];
    stop_Correct(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).Correct];
    stop_GoRT(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).GoRT];
    stop_GoSignalOnsetTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).GoSignalOnsetTimestamp];
    stop_GoSignalOffsetTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).GoSignalOffsetTimestamp];
    stop_ResponseTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).ResponseTimestamp];
    % The following are only present for stop_, not go_
    stop_SSD_intended(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).SSD_intended];
    stop_SSD_actual(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).SSD_actual];
    stop_StopSignalOnsetTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).StopSignalOnsetTimestamp];
    stop_StopSignalOffsetTimestamp(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = [trials(stopTrialInds).StopSignalOffsetTimestamp];
    
    go_TrialComplete(subjectRow, sessionColumn, 1:mergeSummary(i).goTrialCount) = ~isnan([trials(goTrialInds).Answer]);
    stop_TrialComplete(subjectRow, sessionColumn, 1:mergeSummary(i).stopTrialCount) = ~isnan([trials(stopTrialInds).Answer]);
    
end

clear trials settings subjectNumber sessionNumber subjectRow sessionColumn subjectHandedness;
clear i directory dir_results filenames filename testing;
clear goDataSize stopDataSize goTrialInds stopTrialInds;

% Save the results
save(['merged_' num2str(numel(unique([mergeSummary.subjectNumber]))) 'subjects']);
filename = ['merged_' num2str(numel(unique([mergeSummary.subjectNumber]))) 'subjects.mat'];

end