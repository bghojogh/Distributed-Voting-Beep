%%
clc
clear
clear all
close all

%% load data:
cd('./binary_fully/')
load number_of_phases
number_of_phases_average = [];
for delta_index = 1:length(number_of_phases)
    number_of_phases_average(end+1) = mean(cell2mat(number_of_phases{delta_index}));
end
number_of_phases_fully = number_of_phases_average;
load delta_vector
cd('..')

cd('./binary_erdosRenyi/')
load number_of_phases
number_of_phases_average = [];
for delta_index = 1:length(number_of_phases)
    number_of_phases_average(end+1) = mean(cell2mat(number_of_phases{delta_index}));
end
number_of_phases_erdosRenyi = number_of_phases_average;
cd('..')

cd('./binary_mesh/')
load number_of_phases
number_of_phases_average = [];
for delta_index = 1:length(number_of_phases)
    number_of_phases_average(end+1) = mean(cell2mat(number_of_phases{delta_index}));
end
number_of_phases_mesh = number_of_phases_average;
cd('..')

%% plot result:
f1 = figure;
% stem(delta_vector, correctness_rate,'filled')
xlabel('\delta')
ylabel('Average number of phases')
% ylim([0 110])
hold on
plot(delta_vector, number_of_phases_fully, '-o', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta_vector, number_of_phases_erdosRenyi, '-*', 'MarkerFaceColor', 'k', 'Color', 'k')
plot(delta_vector, number_of_phases_mesh, '-s', 'MarkerFaceColor', 'k', 'Color', 'k')
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
