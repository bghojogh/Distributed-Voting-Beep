%% Markov Chain (for binary voting):

%% MATLAB initializations:
clc
clear
clear all
close all

%% Settings:
number_of_levels = 2;  % binary voting
number_of_nodes = 5;
probability_of_beeping = 0.5;
initial_nodes_in_value1 = 3;
initial_nodes_in_value2 = number_of_nodes - initial_nodes_in_value1;
number_of_iterations_for_convergence_of_Markov = 100;

%% Creating transition matrix:
index_of_states_with_zeroAlive_value1 = [];
index_of_states_with_zeroAlive_value2 = [];
%%%%% we have "number_of_levels" number of loops in ROW:
for value_level_1_ROW = 0:number_of_nodes
    for value_level_2_ROW = 0:number_of_nodes
        %%%%% we have "number_of_levels" number of loops in COLUMN:
        for value_level_1_COLUMN = 0:number_of_nodes
            for value_level_2_COLUMN = 0:number_of_nodes
                %%%%% find row and column indexes in transition matrix:
                row = ((value_level_2_ROW) * (number_of_nodes+1)) + value_level_1_ROW + 1;  % number_of_nodes+1 because we are considering 0 nodes too, in iterations.
                column = ((value_level_2_COLUMN) * (number_of_nodes+1)) + value_level_1_COLUMN + 1;
                %%%%% find the expected converging indexes in final state vector:
                if value_level_1_COLUMN == 0 && isempty(index_of_states_with_zeroAlive_value1(index_of_states_with_zeroAlive_value1 == column))  % second term is because we want not to repeat the pattern, and find the indexes only once
                    index_of_states_with_zeroAlive_value1 = [index_of_states_with_zeroAlive_value1, column];
                end
                if value_level_2_COLUMN == 0 && isempty(index_of_states_with_zeroAlive_value2(index_of_states_with_zeroAlive_value2 == column))
                    index_of_states_with_zeroAlive_value2 = [index_of_states_with_zeroAlive_value2, column];
                end
                if value_level_1_ROW == value_level_1_COLUMN && value_level_1_COLUMN == initial_nodes_in_value1 ...
                   && value_level_2_ROW == value_level_2_COLUMN && value_level_2_COLUMN == initial_nodes_in_value2
                    initial_state_row_and_column = [row; column];
                end
                %%%%% set the probabilities in transition matrix:
                if value_level_1_COLUMN <= value_level_1_ROW && value_level_2_COLUMN <= value_level_2_ROW
                    p1=1;
                    p2=1;
                    for k = 1:number_of_levels
                            if k == 1 
                               if value_level_1_ROW>0 
                                    a = value_level_1_ROW;
                                    b = value_level_1_ROW - value_level_1_COLUMN;
                                    number_of_nodes_in_the_value_which_become_dead = b;
                                    number_of_remaining_alive_nodes_in_the_value = value_level_1_COLUMN;
                                    p1 = choose_b_from_a(a,b) * (1 - probability_of_beeping)^number_of_nodes_in_the_value_which_become_dead * probability_of_beeping^number_of_remaining_alive_nodes_in_the_value;
                               else
                                   if  value_level_2_ROW>0
                                       p1=0;
                                   end
                               end
                               if value_level_1_ROW>=2 && value_level_2_ROW<=1
                                   p1=0;
                               end
                            else
                                if value_level_2_ROW>0 
                                    a = value_level_2_ROW;
                                    b = value_level_2_ROW - value_level_2_COLUMN;
                                    number_of_nodes_in_the_value_which_become_dead = b;
                                    number_of_remaining_alive_nodes_in_the_value = value_level_2_COLUMN;
                                    p2 = choose_b_from_a(a,b) * (1 - probability_of_beeping)^number_of_nodes_in_the_value_which_become_dead * probability_of_beeping^number_of_remaining_alive_nodes_in_the_value;
                                else
                                   if  value_level_1_ROW>0
                                       p2=0;
                                   end
                                end
                               if value_level_2_ROW>=2 && value_level_1_ROW<=1
                                   p2=0;
                               end
                                
                            end
                    end
                    probability_transition_matrix(row, column) = p1 * p2;
                else
                    probability_transition_matrix(row, column) = 0;  %% isolated state (never happens)
                end
            end
        end
    end
end

%% translating stop states to one of three states (draw, or V1:winner, or V2: winner)
%%%% note: --> stop state: if all probablities in a row of transition matrix are 0. because it is stuck in that state forever.
%%%% we define:
%%%% probability_transition_matrix(:,1) except cases extracted below: draw (because all nodes become zero) --> only cases where all value levels are or become equal and suddenly become zero (all dead): other cases are excluded in below code (the for loop)
%%%% probability_transition_matrix(:,p+1): winning value1
%%%% probability_transition_matrix(:,q+1): winning value2
[p,q] = size(probability_transition_matrix);
temp = zeros(p+2,q+2);
temp(1:p,1:q) = probability_transition_matrix;
probability_transition_matrix = temp;
probability_transition_matrix(p+1,q+1)=1;
probability_transition_matrix(p+2,q+2)=1;

%%%%% setting probabilities of winnings of value levels:
for i = 2:p      % not consider i=1 because all nodes are beeping in the first round, and i=1 refers to the first round (initial state)
    if isequal(probability_transition_matrix(i,:),zeros(1,q+2))  % stop state: if all probablities in a row of transition matrix are 0. because it is stuck in that state forever.
        value_level_1 = mod(mod(i,number_of_nodes+1)-1,number_of_nodes+1);     % find value_level_1 in row of probability_transition_matrix
        value_level_2 = floor((i-1)/(number_of_nodes+1));   % find value_level_2 in row of probability_transition_matrix
        if value_level_1 > value_level_2
            probability_transition_matrix(i,1)=0;   % probability of draw (excluding the case where all value levels are dead except one level, and suddenly that one becomes dead too.
            probability_transition_matrix(i,q+1)=1;   % probability of winning value1
        else
            probability_transition_matrix(i,1)=0;   % probability of draw (excluding the case where all value levels are dead except one level, and suddenly that one becomes dead too.
            probability_transition_matrix(i,q+2)=1;   % probability of winning value2
        end
        
    end
end

%% iterations:
V_initial = zeros((number_of_nodes+1)^number_of_levels+2, 1);
V_initial(initial_state_row_and_column(1)) = 1;
V = V_initial;
for r = 1:number_of_iterations_for_convergence_of_Markov
    V = probability_transition_matrix' * V;  %%% updating state vector
end

%% find the success probability:
probability_of_draw = V(1);
probability_of_value_levels(1) = V(end-1);
probability_of_value_levels(2) = V(end);
disp('probability of draw:')
disp(probability_of_draw)
disp('probability of winning value1:')
disp(probability_of_value_levels(1))
disp('probability of winning value2:')
disp(probability_of_value_levels(2))

if initial_nodes_in_value1 > initial_nodes_in_value2
    probability_of_success = probability_of_value_levels(1);
elseif initial_nodes_in_value1 < initial_nodes_in_value2
    probability_of_success = probability_of_value_levels(2);
else
    probability_of_success = Nan;
end
disp('probability of success:')
disp(probability_of_success)


