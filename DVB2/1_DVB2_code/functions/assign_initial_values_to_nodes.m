function value = assign_initial_values_to_nodes(number_of_nodes, number_of_value_levels, delta)

value = zeros(number_of_nodes,1);
permuted_nodes = randperm(number_of_nodes);

if number_of_value_levels == 2
    number_of_value_level_1 = floor(number_of_nodes * delta);
    for index = 1 : number_of_value_level_1
        node_index = permuted_nodes(index);
        value(node_index) = 1;
    end
    for index = number_of_value_level_1+1 : number_of_nodes
        node_index = permuted_nodes(index);
        value(node_index) = 2;
    end
elseif number_of_value_levels == 3
    number_of_value_level_1 = floor(number_of_nodes * delta);
    number_of_value_level_2 = floor(number_of_nodes * (1/3));
    %number_of_value_level_3 = number_of_nodes - number_of_value_level_1 - number_of_value_level_2;
    for index = 1 : number_of_value_level_1
        node_index = permuted_nodes(index);
        value(node_index) = 1;
    end
    for index = number_of_value_level_1+1 : number_of_value_level_1+number_of_value_level_2
        node_index = permuted_nodes(index);
        value(node_index) = 2;
    end
    for index = number_of_value_level_1+number_of_value_level_2+1 : number_of_nodes
        node_index = permuted_nodes(index);
        value(node_index) = 3;
    end
end

end