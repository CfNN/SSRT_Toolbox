% Set the current MATLAB folder to the folder where this script is stored
disp('Changing the current MATLAB folder to the location of this script');
cd(fileparts(which(mfilename)));

try
    disp(['Psychtoolbox install directory: ' PsychtoolboxRoot]);
catch
    warning('Psychtoolbox not installed. Install it using instructions on this page: http://psychtoolbox.org/download');
end

if ~exist('data_analysis/session_files', 'dir')
    mkdir data_analysis/session_files
    disp('Created directory data_analysis/session_files');
else
    warning('data_analysis/session_files directory already exists');
end
    
if ~exist('eprime_conversion/eprime_input', 'dir')
    mkdir eprime_conversion/eprime_input
    disp('Created directory eprime_conversion/eprime_input');
else
    warning('eprime_conversion/eprime_input directory already exists');
end

if ~exist('eprime_conversion/session_files_output', 'dir')
    mkdir eprime_conversion/session_files_output
    disp('Created directory eprime_conversion/session_files_output');
else
    warning('eprime_conversion/session_files_output directory already exists');
end
