function neighbors_of_nodes = fully_connected(number_of_nodes)

neighbors_of_nodes = cell(number_of_nodes, 1);
for node = 1:number_of_nodes
    for node2 = 1:number_of_nodes
        if node2 ~= node
            neighbors_of_nodes{node}(end+1) = node2;
        end
    end
end

end