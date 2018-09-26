% Get user preferences regarding which sessions (all or last session only) 
% to include, which outlier criteria to use (none, lenient, or
% conservative), and which trials to use within each session (all trials in
% each session or only the second half of trials in each session).
% Combinations of these three options result in 12 approaches to SSRT
% calculation, as described in Congdon et al. (2013). 

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
    
    go_ignoreTrials = false(size(go_GoSignalOnsetTimestamp));
    stop_ignoreTrials = false(size(stop_GoSignalOnsetTimestamp));
    
    % Estimate each subject's SSRT using the quantile method
    subjectSSRTs_init = QuantileMethodSSRT(go_GoRT, go_Correct, stop_StopSignalDelay, stop_Correct, stop_IsTrial);
    
    if strcmpi(AverageLast, 'Last')
        % Ignore data from all sessions except the last one from each
        % participant
        for p = 1:size(go_TrialCounts, 1) % For each participant of subjectNumber p
            for s = 1:(size(go_TrialCounts, 2)-1) % For each session of sessionNumber 
                if go_TrialCounts(p, s+1) > 0 || stop_TrialCounts(p, s+1) > 0
                    go_ignoreTrials(p, s, :) = true;
                    stop_ignoreTrials(p, s, :) = true;
                end
                
            end
        end 
    end
    
    if strcmpi(OutlierCriteria, 'Lenient') || strcmpi(OutlierCriteria, 'Conservative')
        for p = 1:size(go_TrialCounts, 1) % For each participant of subjectNumber p
            
            stop_success_rate = nansum( reshape(stop_Correct(p, :, :), 1, []) ) / sum(stop_TrialCounts(p, :));
            go_response_rate = nnz(~isnan(go_ResponseTimestamp(p, :, :))) / sum(go_TrialCounts(p, :));
            go_error_rate = nnz(~go_Correct(p, :, :)) / nnz(~isnan(go_ResponseTimestamp(p, :, :)));
            
            if strcmpi(OutlierCriteria, 'Lenient')
                if stop_success_rate < 0.25 || stop_success_rate > 0.75 || go_response_rate < 0.60 || go_error_rate > 0.10 || subjectSSRTs_init(p) < 0.050
                    go_ignoreTrials(p, :, :) = true;
                    stop_ignoreTrials(p, :, :) = true;
                    fprintf(['Subject ' num2str(p) ' excluded:']);
                    fprintf(['    Percent inhibition on stop trials: ' num2str(stop_success_rate*100) '%']);
                    fprintf(['    Percent go-response: ' num2str(go_response_rate*100) '%']);
                    fprintf(['    Percent go-errors: ' num2str(go_error_rate*100) '%']);
                    fprintf(['    SSRT estimate: ' num2str(subjectSSRTs_init(p)) ' seconds\n']);
                end
            elseif strcmpi(OutlierCriteria, 'Conservative')
                if stop_success_rate < 0.40 || stop_success_rate > 0.60 || go_response_rate < 0.75 || go_error_rate > 0.10 || subjectSSRTs_init(p) < 0.050
                    go_ignoreTrials(p, :, :) = true;
                    stop_ignoreTrials(p, :, :) = true;
                    fprintf(['Subject ' num2str(p) ' excluded:']);
                    fprintf(['    Percent inhibition on stop trials: ' num2str(stop_success_rate*100) '%']);
                    fprintf(['    Percent go-response: ' num2str(go_response_rate*100) '%']);
                    fprintf(['    Percent go-errors: ' num2str(go_error_rate*100) '%']);
                    fprintf(['    SSRT estimate: ' num2str(subjectSSRTs_init(p)) ' seconds\n']);
                end
            end
        end 
    elseif strcmpi(OutlierCriteria, 'Conservative')
        for p = 1:size(go_TrialCounts, 1) % For each participant of subjectNumber p

        end
    end
    
    if strcmpi(TrialInclusion, '2nd Half')
        % Ignore all data from the first half of each session
        
        for p = 1:size(go_TrialCounts, 1) % For each participant of subjectNumber p
            
            for s = 1:size(go_TrialCounts, 2) % For each session of sessionNumber 
                numGoTrialsToRemove = floor(go_TrialCounts(p, s)/2);
                numStopTrialsToRemove = floor(stop_TrialCounts(p, s)/2);
                
                go_ignoreTrials(p, s, 1:numGoTrialsToRemove) = true;
                stop_ignoreTrials(p, s, 1:numStopTrialsToRemove) = true;
                
            end
        end
    end
    
    % Make 'Sparsified' versions of relevant data arrays, with trials
    % removed by one of the 12 SSRT calculation methods set to NaN ('not a
    % number')
    go_GoRT_sparse = go_GoRT;
    go_Correct_sparse = go_Correct;
    stop_StopSignalDelay_sparse = stop_StopSignalDelay;
    stop_Correct_sparse = stop_Correct;
    stop_IsTrial_sparse = stop_IsTrial;
    
    go_GoRT_sparse(go_ignoreTrials) = NaN;
    go_Correct_sparse(go_ignoreTrials) = false;
    stop_StopSignalDelay_sparse(stop_ignoreTrials) = NaN;
    stop_Correct_sparse(stop_ignoreTrials) = false;
    stop_IsTrial_sparse(stop_ignoreTrials) = false;
    
    subjectSSRTs_final = QuantileMethodSSRT(go_GoRT_sparse, go_Correct_sparse, stop_StopSignalDelay_sparse, stop_Correct_sparse, stop_IsTrial_sparse);
    
    fprintf('\nEstimated SSRT values for each subject: \n');
    for p = 1:numel(subjectSSRTs_final)
        if ~isnan(subjectSSRTs_final(p))
            disp(['Subject ' num2str(p) ': ' num2str(subjectSSRTs_final(p)) ' seconds']);
        else
            disp(['Subject ' num2str(p) ': excluded, no SSRT calculated']);
        end
    end
    
end