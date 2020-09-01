function [vote, phase, Y, K, is_draw] = do_voting(neighbors_of_nodes, value)

%% parameters:
global max_degree
global probability_be_invitor
global c

%% assigning IDs:
range_IDs = ceil(c * max_degree * log2(max_degree));
Y = range_IDs;
K = length(unique(value));
n_nodes = length(neighbors_of_nodes);
% ID = zeros(n_nodes,1);
% for node_index = 1:n_nodes
%     ID(node_index) = randperm(range_IDs, 1); %randi([1 range_IDs],1);
% end
ID = randperm(range_IDs, n_nodes);
%ID = unidrnd(range_IDs,n_nodes,1);  %--> matlab uniform discrete random

%% DMVR initializations:
value_set = cell(n_nodes,1);
memory = cell(n_nodes,1);
for node_index = 1:n_nodes
    value_set{node_index} = value(node_index);
end

%% part 1: c*delta*log(delta) time slots --> find out the IDs of neighbors
%% then decide on whether be invitor or invitee
%% part 2: (c*delta*log(delta))^2 time slots --> 
%%% if invitor, choose a neighbor randomly (its ID) (rarely happens: if two neighbors with same ID, don't choose it), beep at your ID and neighbor's ID, 
%%% if invitee, listen, and find out your invitors, choose one of them (rarely happens: if two neighbors with same ID, don't choose it)
%% part 3: c*delta*log(delta) time slots --> 
%%% if invitee, beep at only neighbor's ID that you have chosen to accept its invitation
%%% if invitor, listen, and find out whether your invitation was accepted or rejected
%% part 4: (c*delta*log(delta)) * K time slots --> 
%%% if invitor, send your value set to the invitor
%%% if invitee, recieve the sent value set and apply the DMVR rules
%% part 5: (c*delta*log(delta)) * K time slots --> 
%%% if invitee, send the updated value set of the invitor
%%% if invitor, recieve the updated value set of yours
%% all of them form one phase. At the end of every phase, we have terminationDetection

%% part 1: find out neighbors' IDs:
IDs_of_neighbors = cell(n_nodes, 1);
for node = 1:n_nodes
    for node_invitor = neighbors_of_nodes{node}
        IDs_of_neighbors{node}(end+1) = ID(node_invitor);
    end
end

%% iterations (phases):
phase = 0;
is_draw = 0;
vote = nan;
while isnan(vote)
    phase = phase + 1;
    if phase > (100 * log2(n_nodes))
        %--> it must be draw
        is_draw = 1;
        vote = mode(value);
        break
    end
    
    %% decide to be invitor or invitee:
    invitor = zeros(n_nodes,1);
    for node = 1:n_nodes
        if rand < probability_be_invitor
            invitor(node) = 1;
        else
            invitor(node) = 0;
        end
    end

    %% part 2: the invitor chooses a neighbor and invites it:
    invitation_list = zeros(n_nodes,2) * NaN; %--> first column: ID of invitors, second column: ID of invitees by invitors
                                              %--> third column: index of invitors, second column: index of invitees by invitors
    for node = 1:n_nodes
        if invitor(node) == 1
            %%% choose a neighbor (hoping that: 1- it is invitee, 2- it accepts the invitation)
            i = randperm(length(IDs_of_neighbors{node}),1);
            neighbor_ID_to_invite_it = IDs_of_neighbors{node}(i);
            own_ID_Invitor = ID(node);

            invitation_list(node,1) = own_ID_Invitor;
            invitation_list(node,2) = neighbor_ID_to_invite_it;
            invitation_list(node,3) = find(ID == own_ID_Invitor);
            invitation_list(node,4) = find(ID == neighbor_ID_to_invite_it);
        end
    end

    %% part 3: the invitee chooses one of the invitors:
    accepted_invitation_list = zeros(n_nodes,4) * NaN; %--> first column: ID of selected invitors, second column: ID of invitees, 
                                                       %--> third column: index of selected invitors by invitees, forth column: index of invitees 
    for node = 1:n_nodes
        ID_of_node = ID(node);
        if invitor(node) == 0  %--> if is invitee --> we could also check using isempty(invitation_list(invitation_list(:,1)==ID_of_node, 1))
            IDs_of_its_invitors = invitation_list(invitation_list(:,2)==ID_of_node, 1);
            if ~isempty(IDs_of_its_invitors)  %--> if it is invited by at least an invitor
                %%% choose one of the invitors:
                i = randperm(length(IDs_of_its_invitors),1);
                neighbor_ID_ChosenInvitor = IDs_of_its_invitors(i);
                own_ID_Invitee = ID(node);

                accepted_invitation_list(node,1) = neighbor_ID_ChosenInvitor;
                accepted_invitation_list(node,2) = own_ID_Invitee;
                accepted_invitation_list(node,3) = find(ID == neighbor_ID_ChosenInvitor);
                accepted_invitation_list(node,4) = find(ID == own_ID_Invitee);
            end
        end
    end
    %%%%% remove the nan rows:
    accepted_invitation_list = accepted_invitation_list(~isnan(accepted_invitation_list(:,1)), :);

    %% part 4: apply DMVR rules:
    for interaction_index = 1:size(accepted_invitation_list, 1)
        node_invitor = accepted_invitation_list(interaction_index, 3);
        node_invitee = accepted_invitation_list(interaction_index, 4);
        %%% Concolidation function:
        union_of_value_sets = union(value_set{node_invitee}, value_set{node_invitor});
        intersect_of_value_sets = intersect(value_set{node_invitee}, value_set{node_invitor});
        if length(value_set{node_invitee}) <= length(value_set{node_invitor})
            value_set{node_invitee} = union_of_value_sets;
            value_set{node_invitor} = intersect_of_value_sets;
        else
            value_set{node_invitee} = intersect_of_value_sets;
            value_set{node_invitor} = union_of_value_sets;
        end
        %%% Dissemination function:
        memory_backup = memory;
        if length(value_set{node_invitee}) == 1
            memory{node_invitee} = value_set{node_invitee};
        end
        if length(value_set{node_invitor}) == 1
            memory{node_invitor} = value_set{node_invitor};
        end
        %%% speeding up the DMVR for voting:
        if length(value_set{node_invitee}) > 1 && length(value_set{node_invitor}) > 1
            if rand < 0.5
                memory{node_invitee} = memory_backup{node_invitor};
            else
                memory{node_invitor} = memory_backup{node_invitee};
            end
        end   
    end
    
    %% check termination:
    memory_vector = cell2mat(memory);
    if length(memory_vector) == n_nodes  %--> means that all nodes have a vote
        if var(memory_vector) == 0  %--> means that all nodes have the same vote
            vote = unique(memory_vector);
        end
    end    
end

end