%%
clc
clear
clear all
close all

%% load data:
close all
cd('./results/')
load correctness_rate_onePhase
correctness_rate_onePhase = correctness_rate;
load correctness_rate_markov
correctness_rate_markov = correctness_rate;
load delta
load lower_bound_Max
lower_bound_Max = lower_bound_Max * 100;
load lower_bound_approximate
lower_bound_approximate = lower_bound_approximate * 100;
cd('..')

%% plot result:
f1 = figure;
% stem(delta_vector, correctness_rate,'filled')
xlabel('\delta')
ylabel('Percentage of correct votes')
ylim([0 110])
hold on
plot(delta, correctness_rate_onePhase, '-o', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta, correctness_rate_markov, '-v', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta, lower_bound_Max, '-s', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta, lower_bound_approximate, '-^', 'MarkerFaceColor', 'k', 'Color', 'k')
legend('Simulation (one phase only)', 'Markov chain', 'Lower bound', 'Asymptotic lower bound', 'Location', 'NorthWest');
set(gca, 'XTick', round(delta,2));
xlim([min(delta),max(delta)]);
grid on

PathName = './';
dirname = fullfile(PathName,'*.png');
imglist = dir(dirname);
str = sprintf('plot1.png');   
saveas(f1, [PathName, str]);
%print(f,'-djpeg','-r600',[PathName, str]);
