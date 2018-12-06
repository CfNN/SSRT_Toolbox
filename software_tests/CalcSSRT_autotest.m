function CalcSSRT_autotest()
% CALCSSRT_AUTOTEST - correct SSRTs obtained using QuantileMethodSSRT.m on a 
% set of GoRT, SSD-homogeneous datasets with NaNs for some values

for goRT = 0.50:0.10:0.200
    
    for ssd = 0.10:0.10:0.40

        go_GoRT_sparse = goRT*ones([3 3 8]);
        go_GoRT_sparse(:, :, 7) = 30;
        go_GoRT_sparse(1, 2, 8) = NaN;
        go_GoRT_sparse(1, 1, 1) = NaN; % This trial is "true" in stop_IsTrial_sparse
        go_Correct_sparse = true([3 3 8]);
        go_Correct_sparse(:, :, 7) = false;

        stop_SSD_actual_sparse = ssd*ones([3 3 4]);
        stop_Correct_sparse = true([3 3 4]);
        stop_Correct_sparse(:, :, 3:4) = false;

        stop_TrialComplete_sparse = true([3 3 4]);
        stop_TrialComplete_sparse(2, :, :) = false;
        stop_TrialComplete_sparse(:, :, 8) = false;

        subjectSSRTs_final = QuantileMethodSSRT(go_GoRT_sparse, go_Correct_sparse, stop_SSD_actual_sparse, stop_Correct_sparse, stop_TrialComplete_sparse);
        % Expect participants 1 and 3 to have the same values
        assert(subjectSSRTs_final(1) == subjectSSRTs_final(3), 'Participants with same values did not return the same SSRT result (QuantileMethodSSRT.m) - CalcSSRT_autotest FAILED');
        % participant 2 SSRT should be NaN
        assert(isnan(subjectSSRTs_final(2)), 'A non-NaN SSRT value was returned for a participant with all of their data set to NaN - CalcSSRT_autotest FAILED');
        assert(subjectSSRTs_final(1) == goRT - ssd, 'Incorrect SSRT value calculated - CalcSSRT_autotest FAILED');
        
    end

end

disp('[Passed] CalcSSRT_autotest: correct SSRTs on a set of GoRT, SSD-homogeneous datasets with NaNs');

end