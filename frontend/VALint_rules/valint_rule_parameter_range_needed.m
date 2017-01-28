function valint_rule_parameter_range_needed(AST)
% >> Rule
% Check if the parameter has a range specified
%
% >> Bad practice code
% parameter real r=0;
%
% >> Good practice code
% parameter real r=0 from [0:inf);
%
% >> Comment
% All parameters need to have a range. This applies even to version number.
% A model's version number shall have a range that is positive.
%
% >> Reference
% Page 387 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 2/14/2016
%
% >> ID
% 1


if strcmp(AST.get_type, 'parm')
    % check if it has a children with type 'parms_range'
    for this_child = AST.get_children
        if strcmp(this_child{1}.get_type, 'parm_range')
            return
        end
    end
    
    % No range is found. Print warning message
    AST.add_valint_result(mfilename, 'warning', 'Parameter has no range!', 1, 1);
end
end
