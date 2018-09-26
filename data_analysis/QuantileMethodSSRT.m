function subjectSSRTs = QuantileMethodSSRT(go_GoRT, go_Correct, stop_StopSignalDelay, stop_Correct, stop_IsTrial)
    
    numSubjectSlots = size(stop_StopSignalDelay, 1);
    subjectSSRTs = nan(numSubjectSlots, 1); % Initialize empty vector of NaN (not a number)
    
    for p = 1:numSubjectSlots % For each participant of subjectNumber p
        
        if nnz((stop_IsTrial(p, :, :))) > 0 % If there is any data for this subject
        
            % Compute average stop signal delay for this subject. Nanmean is
            % like mean, but it ignores NaN values. 
            averageSSD = nanmean(reshape(stop_StopSignalDelay(p, :, :), 1, []));

            % Get all go reaction times where the response was correct, and
            % use data only from this participant
            correctGoRT = go_GoRT(go_Correct);
            correctGoRT = reshape(correctGoRT(p, :, :), 1, []);

            % Sort selected GoRTs in ascending order
            correctGoRT = sort(correctGoRT);

            % Get proportion of failed inhibition (proportion of stop trials
            % where the participant failed to stop).
            propStopFail = 1 - ( nnz(stop_Correct(p, :, :)) / nnz(stop_IsTrial(p, :, :)) );

            % Get the index of the correct GoRT corresponding to the proportion
            % of failed stop trials
            quantileInd = round(propStopFail*numel(correctGoRT));
            
            if quantileInd < 1
                fprintf(['Warning - index of correct GoRT corresponding to proportion of failed stop trials is zero, setting to 1 for subject # ' num2str(p) '\n']);
                quantileInd = 1;
            end
            
            if numel(correctGoRT) == 0
                fprintf(['No correct go trials for subject #' num2str(p) '. No SSRT calculated for this subject \n']);
            else
                
                % Choose the quantileRT, the go RT at the percentile
                % (quantile) corresponding to the proportion of failed stop
                % trials
                quantileRT = correctGoRT(quantileInd);
                
                % Estimate this subject's SSRT
                subjectSSRTs(p) = quantileRT - averageSSD;
            end
        
        end
        
    end
end