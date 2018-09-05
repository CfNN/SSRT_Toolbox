function runningVals = UpdateLivePerfMetrics(runningVals)
% UPDATELIVEPERFMETRICS - Updates variables needed to display live 
% performance metrics. 
%
% Usage: runningVals = UpdateLivePerfMetrics(runningVals)
% -------------

% Calc go trial accuracy
if runningVals.GoTrialCount > 0
    runningVals.GoAcc = round((runningVals.GoCorrect*100)/runningVals.GoTrialCount);
end

% Calc stop trial accuracy
if runningVals.StopTrialCount > 0
    runningVals.StopAcc = round((runningVals.StopCorrect*100)/runningVals.StopTrialCount);
end

end