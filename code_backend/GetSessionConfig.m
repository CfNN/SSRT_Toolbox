function [subjectNumber, sessionNumber, subjectHandedness, runningVals, cancelled] = GetSessionConfig(settings, runningVals) 
% GETSESSIONCONFIG - use dialog boxes to get the subject and session
% number, and whether the subject is right or left handed, from the
% experimenter.
%
% Usage: [subjectNumber, sessionNumber, subjectHandedness, cancelled] = GetSessionConfig();

confirmed = false;
cancelled = false;

while ~confirmed
    
    num_entered = false;
    while (~num_entered)
        answer = inputdlg('Please enter the subject number:', 'Subject Number', [1 40], {'1'});
        if isempty(answer)
            subjectNumber = NaN;
            sessionNumber = NaN;
            subjectHandedness = 'NA_CANCELLED';
            cancelled = true;
            return;
        else
            [num, is_num] = str2num(char(answer)); % Convert string to number, make sure it was actually a number
            num_entered = is_num && mod(num, 1) == 0; % Make sure the number is an integer
            if ~num_entered
                waitfor(msgbox('Please enter an integer for the subject number'));
            else
                subjectNumber = round(num);
            end
        end
    end

    num_entered = false;
    while (~num_entered)
        answer = inputdlg('Please enter the session number:', 'Session Number', [1 40], {'1'});
        if isempty(answer)
            subjectNumber = NaN;
            sessionNumber = NaN;
            subjectHandedness = 'NA_CANCELLED';
            cancelled = true;
            return;
        else
            [num, is_num] = str2num(char(answer)); % Convert string to number, make sure it was actually a number
            num_entered = is_num && mod(num, 1) == 0; % Make sure the number is an integer
            if ~num_entered
                waitfor(msgbox('Please enter an integer for the session number'));
            else
                sessionNumber = round(num);
            end
        end
    end

    answer = questdlg('Please select right-handed or left-handed', 'Handedness', 'Right', 'Left', 'Cancel', 'Right');
    if isempty(answer) || strcmpi(answer, 'Cancel')
        subjectNumber = NaN;
        sessionNumber = NaN;
        subjectHandedness = 'NA_CANCELLED';
        cancelled = true;
        return;
    else
        subjectHandedness = answer;
    end
    
    num_entered = false;
    while (~num_entered)
        answer = inputdlg('Please enter the starting stop-signal delay (SSD) in seconds for staircase 1:', 'SSD', [1 40], {'0.200'});
        if isempty(answer)
            subjectNumber = NaN;
            sessionNumber = NaN;
            subjectHandedness = 'NA_CANCELLED';
            cancelled = true;
            return;
        else
            [num, num_entered] = str2num(char(answer)); % Convert string to number, make sure it was actually a number
            if ~num_entered
                waitfor(msgbox('Please enter a number for the SSD'));
            else
                runningVals.ssd1 = num;
            end
        end
    end
    
    num_entered = false;
    while (~num_entered)
        answer = inputdlg('Please enter the starting stop-signal delay (SSD) in seconds for staircase 2:', 'SSD', [1 40], {'0.300'});
        if isempty(answer)
            subjectNumber = NaN;
            sessionNumber = NaN;
            subjectHandedness = 'NA_CANCELLED';
            cancelled = true;
            return;
        else
            [num, num_entered] = str2num(char(answer)); % Convert string to number, make sure it was actually a number
            if ~num_entered
                waitfor(msgbox('Please enter a number for the SSD'));
            else
                runningVals.ssd2 = num;
            end
        end
    end
    
    msg = {['Subject Number: ' num2str(subjectNumber)], ['Session Number: ' num2str(sessionNumber)], ['Handedness: ' subjectHandedness], ['SSD 1: ' num2str(runningVals.ssd1) ' s'], ['SSD 2: ' num2str(runningVals.ssd2) ' s'], '', 'Continue with the above startup info?'};
    
    answer = questdlg(msg, 'Confirmation', 'Yes', 'No', 'Cancel', 'Yes');
    if strcmpi(answer, 'Yes')
        confirmed = true;
    elseif isempty(answer) || strcmpi(answer, 'Cancel')
        subjectNumber = NaN;
        sessionNumber = NaN;
        subjectHandedness = 'NA_CANCELLED';
        cancelled = true;
        return;
    end
    
    if strcmpi(answer, 'Yes')
        % Check if a .mat file with these participant and subject numbers
        % exists already - if it does, issue a warning that the data will be overwritten
        filename = ['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '.mat'];
        autosave_filename = ['subj' num2str(subjectNumber) '_sess' num2str(sessionNumber) '_' settings.ExperimentName '_AUTOSAVE.mat'];
        if exist(filename, 'file') == 2 || exist(autosave_filename, 'file')
            confirmed = false;
            
            if exist(autosave_filename, 'file') == 2
                filename = autosave_filename;
            end

            msg = {['WARNING: A data file for these subject and session numbers (''' filename ''') already exists.'], '', 'Do you want to overwrite?'};
            answer = questdlg(msg, 'Overwrite warning', 'Yes', 'No', 'Cancel', 'No');

            if strcmpi(answer, 'Yes')
                confirmed = true;
            elseif isempty(answer) || strcmpi(answer, 'Cancel')
                subjectNumber = NaN;
                sessionNumber = NaN;
                subjectHandedness = 'NA_CANCELLED';
                cancelled = true;
                return;
            end
        end  
    end
    
end

end

% The "comment" below suppresses warnings that the str2num is slow - we 
% need it to check if the experimenter enters something other than a number
%#ok<*ST2NM>