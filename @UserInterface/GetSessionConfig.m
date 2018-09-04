function [participantNumber, sessionNumber, handedness] = GetSessionConfig(obj) 

answer = inputdlg('what is your name');

handedness = questdlg('Please select right-handed or left-handed', 'Handedness', 'Right', 'Left', 'Right');

%Get integer Subject number - 'Please enter the Subject Number
%(0-999999):', default 1

%Please enter the Session Number (0-32767):

%Please enter 1 for Right-handed or 2 for Left-handed

%Boxtitle: Summary of Startup Info
%Subject: 1
%Session: 1
%Group: 1

%Continue with the above startup info? (yes, no, cancel) -> cancel closes
%experiment

end

