function TimingDiscrepancy_manual(filename)
% TIMINGDISCREPANCY_MANUAL - Manually test whether the timing of the
% experiment session is precise, particularly whether the stop signal beep
% started playing on time (ie stop signal delay was no longer or shorter
% than expected). You will need to examine the output of this function on
% the console to determine whether the SSD discrepancies are within
% acceptable limits for your experiment. 
%
% Example usage: TimingDiscrepancy_manual('subj1_sess1_SSRT.mat');

load(filename, 'trials');

fprintf('\nNote - GoRT discrepancies found using the methods in this function will always be exactly zero, because GoRT is calculated based on timestamps\n');

fprintf('\nGo signal presentation length: previous testing found that, if no keys are pressed, the arrow images are presented for 1.015-1.016 s, or 15-16 ms longer than the intended 1000ms. This is due to the screen refresh rate.\nUncomment code below this statement to test it yourself.\n');
% disp('Go signal presentation lengths (only relevant for test session where no keys were pressed):');
% for t = 1:length(trials)
%     
%     if strcmpi(trials(t).Procedure, 'StITrial') || strcmpi(trials(t).Procedure, 'StITrial2')
%         disp(['Image presentation time (trial ' num2str(t) '): ' num2str((trials(t).GoSignalOffsetTimestamp - trials(t).GoSignalOnsetTimestamp)) ' s']);
%     end
%     
% end

fprintf('\nStop signal presentation length: previous testing found that, if no keys are pressed, the stop signal beep is presented for around 240-260 ms, within 10ms of the intended 250 ms.\nUncomment code below this statement to test it yourself.\n\n');
% disp('Stop beep presentation lengths (only relevant for test session where no keys were pressed):');
% for t = 1:length(trials)
%     
%     if strcmpi(trials(t).Procedure, 'StITrial') || strcmpi(trials(t).Procedure, 'StITrial2')
%         disp(['Stop signal beep length (trial ' num2str(t) '): ' num2str((trials(t).StopSignalOffsetTimestamp - trials(t).StopSignalOnsetTimestamp)) ' s']);
%     end
%     
% end

ssdDiscrepancies = nan(1, nnz(strcmpi({trials.Procedure}, 'StITrial')) + nnz(strcmpi({trials.Procedure}, 'StITrial2')));
disp('Stop signal delay (SSD) discrepancies (if positive, actual SSD was longer than intended, if negative, it was shorter than intended):');
stopTrialInd = 1;
for t = 1:length(trials)
    
    if strcmpi(trials(t).Procedure, 'StITrial') || strcmpi(trials(t).Procedure, 'StITrial2')
        discrep = (trials(t).StopSignalOnsetTimestamp - trials(t).GoSignalOnsetTimestamp) - trials(t).SSD_intended;
        disp(['SSD actual-intended (trial ' num2str(t) '): ' num2str(discrep) ' s']);
        ssdDiscrepancies(stopTrialInd) = discrep;
        stopTrialInd = stopTrialInd + 1;
    end
    
end

disp(['Mean discrepancy: ' num2str(nanmean(ssdDiscrepancies))]);
disp(['Standard deviation: ' num2str(nanstd(ssdDiscrepancies))]);

end