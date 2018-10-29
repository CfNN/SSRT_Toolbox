% Set the current MATLAB folder to the folder where this script is stored
disp('Setting the current MATLAB folder to the location of this script');
cd(fileparts(which(mfilename)));

% Make sure the code files in /code_backend and /data_analysis are accessible to MATLAB
disp('Adding code directories to MATLAB search path');
addpath('./../code_backend/');
addpath('./../data_analysis/');

% Run all automated tests
Merge_and_Congdon2012Algo_autotest();
CalcSSRT_autotest();
CalcSSRT2_autotest();
