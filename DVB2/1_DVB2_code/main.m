%%
clc
clear
clear all
close all

%% add paths of functions:
addpath('./functions/');
addpath('./network_structure/');

%% Settings:
number_of_nodes = 100;
number_of_value_levels = 3;
network_structure_index = 4;
number_of_simulation_runs = 1000;
value = zeros(number_of_nodes,1);

%% parameters:
global max_degree;
global probability_be_invitor; probability_be_invitor = 0.5;   %--> it can be proved p=0.5 is optimum for fast convergence and least number of collisions (collision = a node be invitor and invited at the same time)
global c; c = 10000;

%% creating structure of graph:
if network_structure_index == 1
    structure = 'fully_structure';
    max_degree = number_of_nodes;
elseif network_structure_index == 2
    structure = 'two_dimensional_mesh';
    max_degree = 4;
elseif network_structure_index == 3
    structure = 'two_dimensional_torus';
    max_degree = 4;
elseif network_structure_index == 4
    structure = 'erdos_renyi';
    max_degree = number_of_nodes;
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
if number_of_value_levels == 2
    delta_vector = (0.51:0.04:0.99);
elseif number_of_value_levels == 3
    delta_vector = (0:0.03:0.33);
end

%%
number_of_phases = cell(length(delta_vector), 1);
initial_values_of_nodes = cell(length(delta_vector), 1);
votes = cell(length(delta_vector), 1);
is_draw = cell(length(delta_vector), 1);
run = 0;
for delta = delta_vector
    run = run + 1;
    str = sprintf('run %d out of %d runs', run, length(delta_vector));
    disp(str);
    
    %% simulation:
    initial_values_of_nodes{run} = cell(number_of_simulation_runs, 1);
    votes{run} = cell(number_of_simulation_runs, 1);
    Correct_votes = zeros(number_of_simulation_runs,1);
    number_of_phases{run} = cell(number_of_simulation_runs, 1);
    is_draw{run} = cell(number_of_simulation_runs, 1);
    
    for simulation = 1:number_of_simulation_runs
        %% report number of simulation:
        str = sprintf('======== simulation %d out of %d simulations', simulation, number_of_simulation_runs);
        disp(str)
        
        %% assign random initial values:
        value = assign_initial_values_to_nodes(number_of_nodes, number_of_value_levels, delta);
        initial_values_of_nodes{run}{simulation} = value;
        
        %% vote:
        [vote, phase, Y, K, is_draw_] = do_voting(neighbors_of_nodes, value);
        votes{run}{simulation} = vote;
        number_of_phases{run}{simulation} = phase;
        is_draw{run}{simulation} = is_draw_;
        if is_draw_ == 1
            str = sprintf('draw occured..., run: %d, simulation: %d', run, simulation);
            disp(str);
        end
        
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
        
    end
    
    %% result:
    correctness_rate(run) = (sum(Correct_votes) / number_of_simulation_runs) * 100;
    disp('The rate for this run was:')
    disp(correctness_rate(run));
    
end

%% save results:
close all
cd('./saved_results/')
save neighbors_of_nodes.mat neighbors_of_nodes
save delta_vector.mat delta_vector
save initial_values_of_nodes.mat initial_values_of_nodes
save votes.mat votes
save number_of_phases.mat number_of_phases
save correctness_rate.mat correctness_rate
save is_draw.mat is_draw

%%%%% save settings:
save number_of_nodes.mat number_of_nodes
save number_of_value_levels.mat number_of_value_levels
save network_structure_index.mat network_structure_index
save number_of_simulation_runs.mat number_of_simulation_runs
save c.mat c
if network_structure_index == 4  % if topology is erdos renyi
    save probability_of_edges_in_erdos_renyi.mat probability_of_edges_in_erdos_renyi
end
save max_degree.mat max_degree
save probability_be_invitor.mat probability_be_invitor

%%%%% save workspace:
save workspace
cd('..')

