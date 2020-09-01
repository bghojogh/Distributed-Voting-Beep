%%
clc
clear
clear all
close all

%% load data:
close all
cd('./binary_fully/')
load total_number_of_time_slots_average
total_time_fully = cell2mat(total_number_of_time_slots_average);
load delta_vector
cd('..')
cd('./binary_erdosRenyi/')
load total_number_of_time_slots_average
total_time_erdosRenyi = cell2mat(total_number_of_time_slots_average);
cd('..')
cd('./binary_mesh/')
load total_number_of_time_slots_average
total_time_mesh = cell2mat(total_number_of_time_slots_average);
cd('..')

%% plot result:
f1 = figure;
% stem(delta_vector, correctness_rate,'filled')
xlabel('\delta')
ylabel('Average time slots')
% ylim([0 110])
hold on
plot(delta_vector, total_time_fully, '-o', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta_vector, total_time_erdosRenyi, '-*', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta_vector, total_time_mesh, '-s', 'MarkerFaceColor', 'k', 'Color', 'k')
legend('Fully connected', 'Erdos Renyi', '2D mesh', 'Location', 'NorthEast');
set(gca, 'XTick', round(delta_vector,2));
xlim([min(delta_vector),max(delta_vector)]);
grid on

PathName = './';
dirname = fullfile(PathName,'*.png');
imglist = dir(dirname);
str = sprintf('plot1.png');   
saveas(f1, [PathName, str]);
%print(f,'-djpeg','-r600',[PathName, str]);
