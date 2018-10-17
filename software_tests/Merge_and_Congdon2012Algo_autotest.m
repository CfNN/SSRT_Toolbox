function Merge_and_Congdon2012Algo_autotest()
% MERGE_AND_CONGDON2012ALGO_AUTOTEST: correct SSRTs and data selections
% from an artificially prepared dataset using 12 different methods of SSRT 
% calculation, as described in 'Measurement and Reliability of Response 
% Inhibition' by Congdon et al. (2012) in Frontiers in Psychology

directory = '../software_tests/Merge_and_Congdon2012Algo_session_files';
filename = MergeSessions(directory);
load(filename); %#ok<*LOAD>
delete(filename);

method = 'Last All Full';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Last', 'None', 'All', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(:))) == 0, 'No subjects should have been excluded');
expectedSSRTs = [0.085, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:9
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Last LenNoOuts Full';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Last', 'Lenient', 'All', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(6:9))) == 4, 'Subjects 6-9 should be excluded under lenient criteria');
assert(sum(isnan(subjectSSRTs(1:5))) == 0, 'Subjects 1-5 should not be excluded under lenient criteria');
expectedSSRTs = [0.085, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:5
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Last ConNoOuts Full';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Last', 'Conservative', 'All', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(4:9))) == 6, 'Subjects 4-9 should have been excluded under conservative criteria');
assert(sum(isnan(subjectSSRTs(1:3))) == 0, 'Subjects 1-3 should not have been excluded under conservative criteria');
expectedSSRTs = [0.085, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:3
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Ave All Full';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Average', 'None', 'All', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(:))) == 0, 'No subjects should have been excluded');
expectedSSRTs = [0.080, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:9
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Ave LenNoOuts Full';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Average', 'Lenient', 'All', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(6:9))) == 4, 'Subjects 6-9 should be excluded under lenient criteria');
assert(sum(isnan(subjectSSRTs(1:5))) == 0, 'Subjects 1-5 should not be excluded under lenient criteria');
expectedSSRTs = [0.080, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:5
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Ave ConNoOuts Full';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Average', 'Conservative', 'All', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(4:9))) == 6, 'Subjects 4-9 should have been excluded under conservative criteria');
assert(sum(isnan(subjectSSRTs(1:3))) == 0, 'Subjects 1-3 should not have been excluded under conservative criteria');
expectedSSRTs = [0.080, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:3
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Last All 2nd Half';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Last', 'None', '2nd Half', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(:))) == 0, 'No subjects should have been excluded');
expectedSSRTs = [0.095, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:9
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Last LenNoOuts 2nd Half';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Last', 'Lenient', '2nd Half', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(6:9))) == 4, 'Subjects 6-9 should be excluded under lenient criteria');
assert(sum(isnan(subjectSSRTs(1:5))) == 0, 'Subjects 1-5 should not be excluded under lenient criteria');
expectedSSRTs = [0.095, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:5
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Last ConNoOuts 2nd Half';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Last', 'Conservative', '2nd Half', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(4:9))) == 6, 'Subjects 4-9 should have been excluded under conservative criteria');
assert(sum(isnan(subjectSSRTs(1:3))) == 0, 'Subjects 1-3 should not have been excluded under conservative criteria');
expectedSSRTs = [0.095, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:3
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Ave All 2nd Half';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Average', 'None', '2nd Half', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(:))) == 0, 'No subjects should have been excluded');
expectedSSRTs = [0.0975, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:9
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Ave LenNoOuts 2nd Half';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Average', 'Lenient', '2nd Half', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(6:9))) == 4, 'Subjects 6-9 should be excluded under lenient criteria');
assert(sum(isnan(subjectSSRTs(1:5))) == 0, 'Subjects 1-5 should not be excluded under lenient criteria');
expectedSSRTs = [0.0975, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:5
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

method = 'Ave ConNoOuts 2nd Half';
fprintf(['\n' method ':\n'])
subjectSSRTs = CalcSSRT_Congdon2012('Average', 'Conservative', '2nd Half', go_CorrectAnswer, go_Answer, go_GoRT, go_Correct, stop_SSD_actual, stop_Correct, stop_TrialComplete, go_TrialCounts, stop_TrialCounts);
assert(sum(isnan(subjectSSRTs(4:9))) == 6, 'Subjects 4-9 should have been excluded under conservative criteria');
assert(sum(isnan(subjectSSRTs(1:3))) == 0, 'Subjects 1-3 should not have been excluded under conservative criteria');
expectedSSRTs = [0.0975, 0.0501, 0.0501, 0.1000, 0.1000, 0.1000, 0.1000, 0.1000, 0.0499];
for i = 1:3
    assert(abs(subjectSSRTs(i)-expectedSSRTs(i)) < 1e-10, ['Incorrect SSRT for subject ' num2str(subjectRows(i))]);
end

fprintf('\n[Passed] Merge_and_Congdon2012Algo_autotest: correct SSRTs and data selections on an artificially homogenized dataset using 12 different methods of SSRT calculation, as described in ''Measurement and Reliability of Response Inhibition'' by Congdon et al. (2012)\n');

end

%#ok<*NASGU> <- this comment suppreses "value unused" warnings.