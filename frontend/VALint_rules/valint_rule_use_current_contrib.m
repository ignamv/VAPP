function valint_rule_use_current_contrib(AST)
% >> Rule
% Use current contribution if possible.
%
% >> Type
% Warning
%
% >> Bad practice code
% V(b_res) < I(b_res)/s;
%
% >> Good practice code
% I(b_res) <+ V(b_res)*s;
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
% 12

if strcmp(AST.get_type, 'contribution')

    this_children = AST.get_children;
    left_node = this_children{1};
    
    if ~strcmp(left_node.get_type, 'I')
        AST.add_valint_result(mfilename, 'warning', [left_node.get_type ' contribution is used. Use I (current) contribution if possible.'], 12, 1);  
    end
end
end