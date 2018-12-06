function CalcSSRT2_autotest()
% CALCSSRT2_AUTOTEST - correct SSRTs obtained using QuantileMethodSSRT.m on a 
% small artificial dataset of varying GoRT and ssd values (no NaNs). 

% GoRTs for pt1 are evenly spaced from 0.01 to 1, 25th percentile is 0.250
go_GoRT = zeros(2, 2, 50);
go_GoRT(1, 1, :) = Shuffle(0.01:0.01:0.5);
go_GoRT(1, 2, :) = Shuffle(0.51:0.01:1.0);

% GoRTs for pt2 are evenly spaced from 1.01 to 2, 75th percentile is 1.750
go_GoRT(2, 1, :) = Shuffle(1.01:0.01:1.5);
go_GoRT(2, 2, :) = Shuffle(1.51:0.01:2.0);

% Correct responses on all go and stop trials, no missing trials
go_Correct = true(2, 2, 50);
stop_TrialComplete = true(2, 2, 8);
stop_Correct = true(2, 2, 8);

stop_Correct(1, :, 7:8) = false; % 25% failed inhibition for pt1
stop_Correct(2, :, 1:6) = false; % 75% failed inhibition for pt2

stop_SSD_actual = zeros(2, 2, 8);
% Average SSD for pt1 should be 0.150
stop_SSD_actual(1, 1, :) = 0.100;
stop_SSD_actual(1, 2, :) = 0.200;
% Average SSD for pt2 should be 0.300
stop_SSD_actual(2, 1, 1:4) = 0.100;
stop_SSD_actual(2, 1, 5:8) = 0.200;
stop_SSD_actual(2, 2, 1:4) = 0.400;
stop_SSD_actual(2, 2, 5:8) = 0.500;

subjectSSRTs_final = QuantileMethodSSRT(go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete);
assert(abs(subjectSSRTs_final(1)-0.100) < 1e-10, 'Incorrect SSRT value calculated for pt1 - CalcSSRT2_autotest FAILED');
assert(abs(subjectSSRTs_final(2)-1.450) < 1e-10, 'Incorrect SSRT value calculated for pt1 - CalcSSRT2_autotest FAILED');

disp('[Passed] CalcSSRT2_autotest: correct SSRTs on a small artificial dataset of varying GoRT and ssd values (no NaNs)');

end