%%
clc
clear
clear all
close all

%% add paths of functions:
addpath('./functions/');

%% Settings:
probability_to_beep = 0.5;
number_of_nodes = 100;
number_of_value_levels = 2;
network_structure_index = 4;
number_of_simulation_runs = 1000;
perform_only_one_phase = false;
global c; c = 20;
global type_of_check_termination; type_of_check_termination = 'distributed';  % 'distributed' or 'simple'
value = zeros(number_of_nodes,1);

%%
if number_of_value_levels == 2
    delta_vector = (0.51:0.04:0.99);
elseif number_of_value_levels == 3
    delta_vector = (0:0.03:0.33);
end
correctness_rate = zeros(length(delta_vector), 1);
draw_rate = zeros(length(delta_vector), 1);
run = 0;
for delta = delta_vector
    run = run + 1;
    str = sprintf('================== run %d out of %d runs', run, length(delta_vector));
    disp(str);
    
    %% Markov chain:
    initial_nodes_in_value1 = floor(number_of_nodes * delta);
    [probability_of_success, probability_of_draw] = Markov_chain(number_of_nodes, initial_nodes_in_value1);
    
    %% result:
    correctness_rate(run) = probability_of_success * 100;
    draw_rate(run) = probability_of_draw * 100;
    disp('The rate for this run was:')
    disp(correctness_rate(run));
end

%% plot result:
f1 = figure;
% stem(delta_vector, correctness_rate,'filled')
xlabel('\delta')
ylabel('Percentage of correct votes')
ylim([0 110])
hold on
plot(delta_vector, correctness_rate, '-o', 'MarkerFaceColor', 'r')
set(gca, 'XTick', round(delta_vector,2));
xlim([min(delta_vector),max(delta_vector)]);
grid on

f2 = figure;
% stem(delta_vector, correctness_rate,'filled')
xlabel('\delta')
ylabel('Percentage of draw votes')
ylim([0 110])
hold on
plot(delta_vector, draw_rate, '-o', 'MarkerFaceColor', 'r')
set(gca, 'XTick', round(delta_vector,2));
xlim([min(delta_vector),max(delta_vector)]);
grid on

PathName = './saved_results/';
dirname = fullfile(PathName,'*.png');
imglist = dir(dirname);
str = 'Correctness_rate.png';
saveas(f1, [PathName, str]);
str = 'Draw_rate.png';
saveas(f2, [PathName, str]);

%% save results:
close all
cd('./saved_results/')
save correctness_rate correctness_rate
save draw_rate draw_rate
save delta_vector delta_vector
save workspace
cd('..')
