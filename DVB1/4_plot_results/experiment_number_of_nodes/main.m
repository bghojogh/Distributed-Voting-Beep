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
load number_of_nodes_vector
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
xlabel('Number of nodes')
ylabel('Percentage of correct votes')
ylim([50 100])
hold on
plot(number_of_nodes_vector, correctness_rate_erdosRenyi, '--', 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 2)
plot(number_of_nodes_vector, correctness_rate_mesh, ':', 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 2)
plot(number_of_nodes_vector, correctness_rate_fully, '-', 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 2)
legend('Erdos Renyi', '2D mesh', 'Fully connected', 'Location', 'NorthWest');
%set(gca, 'XTick', round(number_of_nodes_vector,2));
%xlim([min(delta_vector),max(delta_vector)]);
grid on

PathName = './';
dirname = fullfile(PathName,'*.png');
imglist = dir(dirname);
str = sprintf('plot1.png');   
saveas(f1, [PathName, str]);
%print(f,'-djpeg','-r600',[PathName, str]);
