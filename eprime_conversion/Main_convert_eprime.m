clear;

% Set the current MATLAB folder to the folder where this script is stored
disp('Changing the current MATLAB folder to the location of this script');
cd(fileparts(which(mfilename)));

input_directory = 'eprime_input';
output_directory = 'session_files_output';

dir_results = dir([input_directory '/*.txt']);
filenames = {dir_results.name};
disp(filenames)
assert(numel(filenames) > 0, ['No files found in ' input_directory]);

for i = 1:numel(filenames)
    [T, headervars] = eprimetxt2vars([input_directory '/' filenames{i}]);
    [trials, settings, subjectNumber, sessionNumber, sessionStartDateTime, triggerTimestamp] = convert_eprime(T, headervars); %#ok<*ASGLU>
    [~,filename,~] = fileparts(filenames{i});
    save([output_directory '/' filename], 'trials', 'settings', 'subjectNumber', 'sessionNumber', 'sessionStartDateTime', 'triggerTimestamp');
end

clear