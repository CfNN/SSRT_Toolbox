function FixTrialsAnswers(filename)
% FIXTRIALSANSWERS - modify the Answer field in a "trials" struct from a
% .mat file in the session_files_output folder (output from
% Main_convert_eprime.m), in case some answers that were recorded were
% non-standard (eg. "LEFT_ARROW" instead of numbers 0, 1, 2 etc). It is 
% your responsibility to convert any non-standard responses in the .mat
% file in advance - otherwise, this script will simply set them to NaNs.
% The overall result is to make the Answers field a regular array of
% numbers only rather than the equivalent of a cell array with 
% heterogeneous data types.  
%
% This script also sets the "Correct" field if the modified "Answer" 
% matches the "CorrectAnswer" for a given trial. 
%
% Example usage: FixTrialsAnswers('SSRT_110_Block1-1-1.mat')

directory = 'session_files_output';

load([directory '/' filename], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'sessionStartDateTime', 'triggerTimestamp');

for t = 1:numel(trials)
    if strcmpi(class(trials(t).Answer), 'string') || ischar(trials(t).Answer)
        trials(t).Answer = str2double(trials(t).Answer); 
    end
    if trials(t).Answer == trials(t).CorrectAnswer
        trials(t).Correct = true;
    end
end

save([directory '/' filename], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'sessionStartDateTime', 'triggerTimestamp');

end

%#ok<*NODEF>
%#ok<*AGROW>