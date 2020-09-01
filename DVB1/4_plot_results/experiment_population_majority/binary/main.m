%%
clc
clear
clear all
close all

%% load data:
close all
cd('./binary_fully/')
load correctness_rate
correctness_rate_fully = correctness_rate;
load delta_vector
cd('..')
cd('./binary_erdosRenyi/')
load correctness_rate
correctness_rate_erdosRenyi = correctness_rate;
cd('..')
cd('./binary_mesh/')
load correctness_rate
correctness_rate_mesh = correctness_rate;
cd('..')

%% plot result:
f1 = figure;
% stem(delta_vector, correctness_rate,'filled')
xlabel('\delta')
ylabel('Percentage of correct votes')
ylim([0 110])
hold on
plot(delta_vector, correctness_rate_fully, '-o', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta_vector, correctness_rate_erdosRenyi, '-*', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta_vector, correctness_rate_mesh, '-s', 'MarkerFaceColor', 'k', 'Color', 'k')
legend('Fully connected', 'Erdos Renyi', '2D mesh', 'Location', 'NorthWest');
set(gca, 'XTick', round(delta_vector,2));
xlim([min(delta_vector),max(delta_vector)]);
grid on

PathName = './';
dirname = fullfile(PathName,'*.png');
imglist = dir(dirname);
str = sprintf('plot1.png');   
saveas(f1, [PathName, str]);
%print(f,'-djpeg','-r600',[PathName, str]);
