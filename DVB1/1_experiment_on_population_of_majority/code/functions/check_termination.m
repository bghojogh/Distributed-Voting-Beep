function [terminated, number_of_periods, number_of_time_slots_in_checkTermination] = check_termination(value, type_of_check, number_of_nodes, number_of_value_levels, neighbors_of_nodes)

if strcmp(type_of_check, 'simple')
    terminated = false;
    if var(value) == 0
        terminated = true;
    end
    number_of_periods = nan;
    number_of_time_slots_in_checkTermination = nan; 
elseif strcmp(type_of_check, 'distributed')
    
    if var(value) == 0
        terminated = true;
    end
    
    terminated = ones(number_of_nodes, 1) * true;
    diameter_of_network = number_of_nodes; % worst case
    for value_level = 1:number_of_value_levels-1
        beep = zeros(number_of_nodes,1);
        for node = 1:number_of_nodes
            if value(node) == value_level
                beep(node) = 1;
            end
        end
        hearBeep = ones(number_of_nodes, 1) * false;
        for node = 1:number_of_nodes
            hear_at_least_a_beep = does_hear_at_least_a_beep(node, neighbors_of_nodes, beep);
            if hear_at_least_a_beep == true
                hearBeep(node) = true;
            end
        end
        for node = 1:number_of_nodes
            if (hearBeep(node) == true) && (value(node) ~= value_level)
                terminated(node) = false;
            end
        end
        hearBeep = ones(number_of_nodes, 1) * false;
        for d = 1:diameter_of_network
            beep = zeros(number_of_nodes,1);
            for node = 1:number_of_nodes
                if (terminated(node) == false) || (hearBeep(node) == true)
                    beep(node) = 1;
                    terminated(node) = false;
                end
            end
            hearBeep = ones(number_of_nodes, 1) * false;
            for node = 1:number_of_nodes
                hear_at_least_a_beep = does_hear_at_least_a_beep(node, neighbors_of_nodes, beep);
                if hear_at_least_a_beep == true
                    hearBeep(node) = true;
                end
            end
        end
        if terminated(1) == false  % note: if terminated(1) == false, terminated variable of all nodes are false
            break
        end
    end
    number_of_periods = value_level;
    number_of_time_slots_in_checkTermination = number_of_periods * (diameter_of_network + 2);
end

end