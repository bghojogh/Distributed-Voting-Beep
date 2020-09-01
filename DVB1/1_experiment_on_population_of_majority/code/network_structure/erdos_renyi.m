function neighbors_of_nodes = erdos_renyi(number_of_nodes, p)

neighbors_of_nodes = cell(number_of_nodes, 1);
for node = 1:number_of_nodes
    for node2 = node+1:number_of_nodes
        probability_of_having_edge_between_these_two_nodes = p;
        if rand <= probability_of_having_edge_between_these_two_nodes
            neighbors_of_nodes{node}(end+1) = node2;
            neighbors_of_nodes{node2}(end+1) = node;
        end
    end
end

end