%%
clc
clear
clear all
close all

%% add paths of functions:
addpath('./functions/');
addpath('./network_structure/');

%% Settings:
probability_to_beep = 0.5;
number_of_nodes = 100;
number_of_value_levels = 2;
network_structure_index = 2;
number_of_simulation_runs = 1000;
perform_only_one_phase = false;
global c; c = 20;
global type_of_check_termination; type_of_check_termination = 'distributed';  % 'distributed' or 'simple'
value = zeros(number_of_nodes,1);

%% creating structure of graph:
if network_structure_index == 1
    structure = 'fully_structure';
elseif network_structure_index == 2
    structure = 'two_dimensional_mesh';
elseif network_structure_index == 3
    structure = 'two_dimensional_torus';
elseif network_structure_index == 4
    structure = 'erdos_renyi';
end
if strcmp(structure, 'fully_structure') == true
    neighbors_of_nodes = fully_connected(number_of_nodes);
elseif strcmp(structure, 'two_dimensional_mesh') == true
    neighbors_of_nodes = two_dimensional_mesh(number_of_nodes);
elseif strcmp(structure, 'two_dimensional_torus') == true
    neighbors_of_nodes = two_dimensional_torus(number_of_nodes);
elseif strcmp(structure, 'erdos_renyi') == true
    probability_of_edges_in_erdos_renyi = 2 * (log2(number_of_nodes)/number_of_nodes);
    neighbors_of_nodes = erdos_renyi(number_of_nodes, probability_of_edges_in_erdos_renyi);
end

%%
counter = 1;
number_of_runs = ceil(number_of_nodes/number_of_value_levels);
if number_of_value_levels == 2
    delta_vector = (0.51:0.04:0.99);
elseif number_of_value_levels == 3
    delta_vector = (0:0.03:0.33);
end
Correct_votes_of_runs = cell(length(delta_vector), 1);
Draw_votes_of_runs = cell(length(delta_vector), 1);
Correct_votes_std_of_runs = cell(length(delta_vector), 1);
initial_values_of_nodes = cell(length(delta_vector), 1);
number_of_phases = cell(length(delta_vector), 1);
number_of_rounds = cell(length(delta_vector), 1);
number_of_time_slots_in_corrosion = cell(length(delta_vector), 1);
number_of_periods = cell(length(delta_vector), 1);
number_of_time_slots_in_checkTermination = cell(length(delta_vector), 1);
number_of_time_slots_in_phase = cell(length(delta_vector), 1);
total_number_of_time_slots = cell(length(delta_vector), 1);
total_number_of_time_slots_average = cell(length(delta_vector), 1);
votes = cell(length(delta_vector), 1);
run = 0;
for delta = delta_vector
    run = run + 1;
    str = sprintf('run %d out of %d runs', run, length(delta_vector));
    disp(str);
    
    %% simulation:
    initial_values_of_nodes{run} = cell(number_of_simulation_runs, 1);
    votes{run} = cell(number_of_simulation_runs, 1);
    Correct_votes = zeros(number_of_simulation_runs,1);
    Draw_votes = zeros(number_of_simulation_runs,1);
    number_of_phases{run} = cell(number_of_simulation_runs, 1);
    number_of_rounds{run} = cell(number_of_simulation_runs, 1);
    number_of_time_slots_in_corrosion{run} = cell(number_of_simulation_runs, 1);
    number_of_periods{run} = cell(number_of_simulation_runs, 1);
    number_of_time_slots_in_checkTermination{run} = cell(number_of_simulation_runs, 1);
    number_of_time_slots_in_phase{run} = cell(number_of_simulation_runs, 1);
    total_number_of_time_slots{run} = cell(number_of_simulation_runs, 1);
    for simulation = 1:number_of_simulation_runs
        %% report number of simulation:
        str = sprintf('======== simulation %d out of %d simulations', simulation, number_of_simulation_runs);
            disp(str)
        if mod(simulation, 500) == 0
            str = sprintf('======== simulation %d out of %d simulations', simulation, number_of_simulation_runs);
            disp(str)
        end
        
        %% assign random initial values:
        value = assign_initial_values_to_nodes(number_of_nodes, number_of_value_levels, delta);
        initial_values_of_nodes{run}{simulation} = value;
        
        %% vote:
        [vote, number_of_phases_, number_of_rounds_, number_of_time_slots_in_corrosion_, number_of_periods_, number_of_time_slots_in_checkTermination_, number_of_time_slots_in_phase_, total_number_of_time_slots_] = do_voting(neighbors_of_nodes, value, perform_only_one_phase, probability_to_beep, number_of_value_levels);
        votes{run}{simulation} = vote;
        number_of_phases{run}{simulation} = number_of_phases_;
        number_of_rounds{run}{simulation} = number_of_rounds_;
        number_of_time_slots_in_corrosion{run}{simulation} = number_of_time_slots_in_corrosion_;
        number_of_periods{run}{simulation} = number_of_periods_;
        number_of_time_slots_in_checkTermination{run}{simulation} = number_of_time_slots_in_checkTermination_;
        number_of_time_slots_in_phase{run}{simulation} = number_of_time_slots_in_phase_;
        total_number_of_time_slots{run}{simulation} = total_number_of_time_slots_;
        
        %% counting correct votes:
        [most_frequent_value, frequency_of_most_frequent_value] = mode(value);
        %%%%% note: if we simply say: mode(value) == vote, we have not covered cases where there are several most frequent values with equal frequency
        frequency_of_values = histc(value, 1:number_of_value_levels);
        for value_level = 1:number_of_value_levels
            if frequency_of_values(value_level) == frequency_of_most_frequent_value
                if value_level == vote
                    Correct_votes(simulation) = 1;
                end
            end
        end
        %% counting draw votes:
        if isnan(vote) %% if vote is draw
            Draw_votes(simulation) = 1;
        end    
    end
    
    %% result:
    correctness_rate(run) = (sum(Correct_votes) / number_of_simulation_runs) * 100;
    draw_rate(run) = (sum(Draw_votes) / number_of_simulation_runs) * 100;
    Correct_votes_std(run) = std(Correct_votes);
    disp('The rate for this run was:')
    disp(correctness_rate(run));
    
    %% save results:
    Correct_votes_of_runs{run} = Correct_votes;
    Draw_votes_of_runs{run} = Draw_votes;
    Correct_votes_std_of_runs{run} = std(Correct_votes);
    total_number_of_time_slots_average{run} = mean(cell2mat(total_number_of_time_slots{run}));
end

%% report standard deviation of Correct_votes:
mean_of_Correct_votes_std = mean(Correct_votes_std);
disp('standard deviation of Correct_votes:')
disp(sqrt(mean_of_Correct_votes_std))

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
% stem(delta_vector, draw_rate,'filled')
xlabel('\delta')
ylabel('Percentage of draw votes')
ylim([0 110])
hold on
plot(delta_vector, draw_rate, '-o', 'MarkerFaceColor', 'r')
set(gca, 'XTick', round(delta_vector,2));
xlim([min(delta_vector),max(delta_vector)]);

PathName = './saved_results/';
dirname = fullfile(PathName,'*.png');
imglist = dir(dirname);
str = sprintf('%.0f_CorrectVote.png', (length(imglist)/2)+1);   % We try not to overwrite the previous ROC curves
saveas(f1, [PathName, str]);
str = sprintf('%.0f_DrawVote.png', (length(imglist)/2)+1);   % We try not to overwrite the previous ROC curves
saveas(f2, [PathName, str]);

%% save results:
close all
cd('./saved_results/')
save neighbors_of_nodes.mat neighbors_of_nodes
save delta_vector.mat delta_vector
save initial_values_of_nodes.mat initial_values_of_nodes
save votes.mat votes
save correctness_rate.mat correctness_rate
save draw_rate.mat draw_rate
save Correct_votes_std_of_runs.mat Correct_votes_std_of_runs
save mean_of_Correct_votes_std.mat mean_of_Correct_votes_std
save number_of_phases.mat number_of_phases
save number_of_rounds.mat number_of_rounds
save number_of_time_slots_in_corrosion.mat number_of_time_slots_in_corrosion
save number_of_periods.mat number_of_periods
save number_of_time_slots_in_checkTermination.mat number_of_time_slots_in_checkTermination
save number_of_time_slots_in_phase.mat number_of_time_slots_in_phase
save total_number_of_time_slots.mat total_number_of_time_slots
save total_number_of_time_slots_average.mat total_number_of_time_slots_average
%%%%% save settings:
save probability_to_beep.mat probability_to_beep
save number_of_nodes.mat number_of_nodes
save number_of_value_levels.mat number_of_value_levels
save network_structure_index.mat network_structure_index
save number_of_simulation_runs.mat number_of_simulation_runs
save perform_only_one_phase.mat perform_only_one_phase
save c.mat c
save type_of_check_termination.mat type_of_check_termination
if network_structure_index == 4  % if topology is erdos renyi
    save probability_of_edges_in_erdos_renyi.mat probability_of_edges_in_erdos_renyi
end
%%%%% save workspace:
save workspace
cd('..')
