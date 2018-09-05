function [subjectNumber, sessionNumber, subjectHandedness, cancelled] = GetSessionConfig() 
% GETSESSIONCONFIG - use dialog boxes to get the subject and session
% number, and whether the subject is right or left handed, from the
% experimenter.
%
% Usage: [subjectNumber, sessionNumber, subjectHandedness, cancelled] = GetSessionConfig();

confirmed = false;
cancelled = false;

while ~confirmed
    
    answer = inputdlg('Please enter the subject number:', 'Subject Number', [1 40], {'1'});
    subjectNumber = round(str2double(answer));

    answer = inputdlg('Please enter the session number:', 'Session Number', [1 40], {'1'});
    sessionNumber = round(str2double(answer));

    subjectHandedness = questdlg('Please select right-handed or left-handed', 'Handedness', 'Right', 'Left', 'Right');
    
    msg = {['Subject Number: ' num2str(subjectNumber)], ['Session Number: ' num2str(sessionNumber)], ['Handedness: ' subjectHandedness], '', 'Continue with the above startup info?'};
    
    answer = questdlg(msg, 'Confirmation', 'Yes', 'No', 'Cancel', 'Yes');
    
    if strcmpi(answer, 'Yes')
        confirmed = true;
    elseif strcmpi(answer, 'Cancel')
        confirmed = true;
        cancelled = true;
    end
    
    
    % Check if a .mat file with these participant and subject numbers
    % exists already - if it does, issue a warning that the data will be overwritten
    filename = ['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '.mat'];
    if exist(filename, 'file') == 2
        
        msg = {['WARNING: A data file for these subject and session numbers (''' filename ''') already exists.'], '', 'Do you want to overwrite?'};
        answer = questdlg(msg, 'Overwrite warning', 'Yes', 'No', 'No');

        if strcmpi(answer, 'Yes')
            confirmed = true;
        elseif strcmpi(answer, 'No')
            confirmed = true;
            cancelled = true;
        end
        
    end
    
end

end

