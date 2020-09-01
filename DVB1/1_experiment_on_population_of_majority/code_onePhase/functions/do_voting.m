function [vote, number_of_phases, number_of_rounds, number_of_time_slots_in_corrosion, number_of_periods, number_of_time_slots_in_checkTermination, number_of_time_slots_in_phase, total_number_of_time_slots] = do_voting(neighbors_of_nodes, value, perform_only_one_phase, probability_to_beep, number_of_value_levels)

global type_of_check_termination;
number_of_nodes = length(value);

%% a phase:
number_of_rounds = [];
number_of_time_slots_in_corrosion = [];
number_of_periods = [];
number_of_time_slots_in_checkTermination = [];
terminated = false;
phase = 0;
while terminated == false
    %% increamenting phase:
    phase = phase + 1;
    
    %% Corrosion:
    [value, number_of_rounds(end+1), number_of_time_slots_in_corrosion(end+1)] = corrosion(number_of_nodes, number_of_value_levels, neighbors_of_nodes, value, probability_to_beep);
    
    %% check termination:
    if perform_only_one_phase == true
        terminated = true;
        number_of_time_slots_in_checkTermination = 0;
    else
        type_of_check = type_of_check_termination;
        [terminated_vector, number_of_periods(end+1), number_of_time_slots_in_checkTermination(end+1)] = check_termination(value, type_of_check, number_of_nodes, number_of_value_levels, neighbors_of_nodes);
        if strcmp(type_of_check, 'simple')
            terminated = terminated_vector;
        elseif strcmp(type_of_check, 'distributed')
            terminated = (sum(terminated_vector) == length(terminated_vector));  % if all the nodes are saying it is terminated
        end
    end 
    if terminated == true
        if var(value) == 0  % if values of all nodes are similar:
            vote = value(1);
        else
            vote = nan; % draw
        end
    end
end
number_of_phases = phase;
number_of_time_slots_in_phase = zeros(number_of_phases, 1);
for phase = 1:number_of_phases
    number_of_time_slots_in_phase(phase) = number_of_time_slots_in_corrosion(phase) + number_of_time_slots_in_checkTermination(phase);
end
total_number_of_time_slots = sum(number_of_time_slots_in_phase);

end