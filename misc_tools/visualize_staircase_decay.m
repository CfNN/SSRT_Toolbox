% Use this script to visualize the exponential decay of delta_t, the
% increment by which the stop signal delay changes in between stop trials.
% Set the initial delta_t, the decay rate, and the number of stop trials
% for each staircase (half the total number of trials with two staircases)
% to your desired values. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_t_initial = 50; % Initial increment by which ssd changes between stop trials
delta_t_decay = 0.9; % Decay rate
n_trials = 16; % Number of stop trials (1 staircase only). Should be half the total number of stop trials in a session.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



ssds = zeros(n_trials, 1);
ssds(1) = delta_t_initial;

for t = 2:n_trials
    ssds(t) = ssds(t-1)*delta_t_decay;
end

disp(['delta_t values for ' num2str(n_trials) ' trials with decay rate of ' num2str(delta_t_decay)]);
disp(ssds)

close all;
figure;
plot(ssds);
title({'Decay of delta\_t (SSD increment)', ['initial delta\_t = ' num2str(delta_t_initial)], ['decay rate = ' num2str(delta_t_decay)]});
xlabel('Stop trial number');
ylabel('delta\_t [seconds]');
xlim([1 n_trials]);

clear 