% Set the current MATLAB folder to the folder where this script is stored
disp('Setting the current MATLAB folder to the location of this script');
cd(fileparts(which(mfilename)));

% Run all automated tests
Merge_and_Congdon2012Algo_autotest();
CalcSSRT_autotest();
CalcSSRT2_autotest();
