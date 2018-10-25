% Get user preferences regarding which sessions (all or last session only) 
% to include, which outlier criteria to use (none, lenient, or
% conservative), and which trials to use within each session (all trials in
% each session or only the second half of trials in each session).
% Combinations of these three options result in 12 approaches to SSRT
% calculation, as described in "Measurement and Reliability of Response 
% Inhibition" by Congdon et al. (2012), Frontiers in Psychology. 
% Run this script after running MergeSessions.m.

% Set the current MATLAB folder to the folder where this script is stored
disp('Changing the current MATLAB folder to the location of this script');
cd(fileparts(which(mfilename)));

% Check that an appropriate dataset is loaded
if ~exist('go_ResponseTimestamp', 'var') || ~exist('go_TrialCounts', 'var') || ~exist('go_GoRT', 'var')
    error('Please load a dataset created using MergeSessions.m into the MATLAB workspace. You can do this by double-clicking an existing merged dataset file after running MergeSessions.m (it might be called something like ''merged_3subjects.mat'')');
end
    
confirmed = false;
cancelled = false;
while ~confirmed
    
    AverageLast = questdlg('Average data from all runs/sessions (recommended), or only use data from the last run of each participant?', 'Runs', 'Average', 'Last', 'Average');
    OutlierCriteria = questdlg('Which outlier criteria would you like to use for subject selection in the analysis: lenient (recommended), conservative, or none (include data from all subjects)?', 'Outlier Criteria', 'Lenient', 'Conservative', 'None', 'Lenient');
    TrialInclusion = questdlg('Include data from all trials in each session/run (recommended), or only use the second half of each session/run?', 'Trials', 'All', '2nd Half', 'All');

    msg = {['Runs: ' AverageLast], ['Outlier criteria: ' OutlierCriteria], ['Trials: ' TrialInclusion], '', 'Continue with this calculation method?'};

    answer = questdlg(msg, 'Confirmation', 'Yes', 'No', 'Cancel', 'Yes');
    
    if strcmpi(answer, 'Yes')
        confirmed = true;
    elseif strcmpi(answer, 'Cancel')
        confirmed = true;
        cancelled = true;
    end
end

if ~cancelled
    subjectSSRTs = CalcSSRT_Congdon2012(AverageLast, OutlierCriteria, TrialInclusion, go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
end