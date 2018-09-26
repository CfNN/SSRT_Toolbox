delta_t_initial = 100;
delta_t_decay = 0.8; % decay rate
n_trials = 16; % number of trials
%%%%%%%%%%%%%%%%%%%%%%
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