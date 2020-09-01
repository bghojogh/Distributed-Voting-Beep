function [value, number_of_rounds, number_of_time_slots_in_corrosion] = corrosion(number_of_nodes, number_of_value_levels, neighbors_of_nodes, value, probability_to_beep)

is_allowed_to_beep_again = ones(number_of_nodes,1) * true;
round = 1;
global c;
number_of_rounds = ceil(c * log2(number_of_nodes));
number_of_time_slots_in_corrosion = number_of_rounds * number_of_value_levels;

while round <= number_of_rounds
    hearBeep = ones(number_of_nodes, number_of_value_levels) * false;
    for value_level = 1:number_of_value_levels
        %%%% initializing beeps:
        beep = zeros(number_of_nodes,1);
        %%%% beep if ....:
        for node = 1:number_of_nodes
            if value(node) == value_level && is_allowed_to_beep_again(node) == true
                if rand <= probability_to_beep
                    beep(node) = 1;
                else
                    is_allowed_to_beep_again(node) = false;
                end
            end
        end
        %%%% creating history of hearing beeps:
        for node = 1:number_of_nodes
            hear_at_least_a_beep = does_hear_at_least_a_beep(node, neighbors_of_nodes, beep);
            if hear_at_least_a_beep == true
                hearBeep(node, value_level) = true;
            end
        end
    end
    %%%% changing value of nodes if necessary:
    for value_level = 1:number_of_value_levels
        for node = 1:number_of_nodes
            if hearBeep(node, value_level) == true && sum(hearBeep(node, :)) == 1   % sum(hearBeep(node, :))==1 means the node has heard in just one value level
                value(node) = value_level;
            end
        end
    end
    %%%% increamenting round:
    round = round + 1;
end

end