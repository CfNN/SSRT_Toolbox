try
    disp(['Psychtoolbox install directory: ' PsychtoolboxRoot]);
catch
    warning('Psychtoolbox not installed. Install it using instructions on this page: http://psychtoolbox.org/download');
end

try
    mkdir data_analysis/session_files
catch
    Warning('data_analysis/session_files directory already exists');
end

try
    mkdir eprime_conversion/eprime_input
catch
    Warning('eprime_conversion/eprime_input directory already exists');
end

try
    mkdir eprime_conversion/session_files_output
catch
    Warning('eprime_conversion/session_files_output directory already exists');
end