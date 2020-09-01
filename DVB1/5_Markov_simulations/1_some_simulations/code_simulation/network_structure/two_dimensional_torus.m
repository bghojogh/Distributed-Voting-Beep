function neighbors_of_nodes = two_dimensional_torus(number_of_nodes)

%%%% order of indexing nodes: row1 --> go in row1 to the right --> after finishing row1, go to row2 --> go in row2 to the right --> ...
neighbors_of_nodes = cell(number_of_nodes, 1);
number_of_columns = round(sqrt(number_of_nodes));
number_of_rows = ceil(number_of_nodes / number_of_columns);
for node = 1:number_of_nodes
    row = floor((node-1)/number_of_columns) + 1;
    column = mod((node-1), number_of_columns) + 1;
    for node2 = 1:number_of_nodes
        if node2 ~= node
            row2 = floor((node2-1)/number_of_columns) + 1;
            column2 = mod((node2-1), number_of_columns) + 1;
            if row2 == row
                if (column2 == column - 1 || column2 == column + 1)
                    neighbors_of_nodes{node}(end+1) = node2;
                elseif column == 1 && column2 == number_of_columns
                    neighbors_of_nodes{node}(end+1) = node2;
                elseif column == number_of_columns && column2 == 1
                    neighbors_of_nodes{node}(end+1) = node2;
                end
            elseif column2 == column
                if (row2 == row - 1 || row2 == row + 1)
                    neighbors_of_nodes{node}(end+1) = node2;
                elseif row == 1 && row2 == number_of_rows
                    neighbors_of_nodes{node}(end+1) = node2;
                elseif row == number_of_rows && row2 == 1
                    neighbors_of_nodes{node}(end+1) = node2;
                end
            end
        end
    end
end

end