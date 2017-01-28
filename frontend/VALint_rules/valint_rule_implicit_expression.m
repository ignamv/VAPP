function valint_rule_implicit_expression(AST)
% >> Rule
% Implicit expression shall be avoided if possible.
%
% >> Type
% Warning
%
% >> Bad practice code
% 
%
% >> Good practice code
% 
%
% >> Comment
% 
%
% >> Reference
% Page 390 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 10


if strcmp(AST.get_type, 'contribution')
    % Contribution shall include two child nodes: (I or V) and (op)
    % check and see if (op) node contains the same (I or V) node
    this_children = AST.get_children;
    left_node = this_children{1};
    op_node = this_children{2};
    
    result = is_implicit(left_node, op_node, 0);
    if result
        AST.add_valint_result(mfilename, 'warning', 'The use of implicit expression shall be avoided if possible.', 10, 1);  
    end
end
end
 
function result = is_implicit(left_node, op_node, result)
% compare this node
if strcmp(left_node.get_type, op_node.get_type) && (left_node.get_num_children == op_node.get_num_children)
    
    left_children = left_node.get_children;
    op_children = op_node.get_children;
    
    result = 1;
    for index = length(left_children)
        if ~strcmp(left_children{index}.get_attr('name'), op_children{index}.get_attr('name'))
            result=0;
            break
        end
    end  
end

if result == 1
    return
end

% compare all its child nodes
for this_child = op_node.get_children
    result = is_implicit(left_node, this_child{1}, result);
    
    if result==1
        break;
    end
end
    
end