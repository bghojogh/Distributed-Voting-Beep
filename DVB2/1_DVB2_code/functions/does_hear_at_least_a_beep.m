function hear_at_least_a_beep = does_hear_at_least_a_beep(node, neighbors_of_nodes, beep)
    
hear_at_least_a_beep = false;
for neighbor_node = neighbors_of_nodes{node}(:)'
    if beep(neighbor_node) == 1
        hear_at_least_a_beep = true;
    end
end
    
end