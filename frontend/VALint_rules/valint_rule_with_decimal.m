function valint_rule_with_decimal(AST)
% >> Rule
% The use of branch in access function is recommended
%
% >> Type
% Warning
%
% >> Bad practice code
% I(a,b) <+g*V(a,b);
%
% >> Good practice code
% branch (a,b) b_cond;
% I(b_cond) <+ g*V(b_cond);
%
% >> Comment
% The "analysis" statement is not defined for all analysis types available
% in all simulators, and can lead to inconsistencies between different
% simulations types (e.g., large-signal and small-signal)
%
% >> Reference
% Page 388 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 6

% if strcmp(AST.get_type, 'contribution')
%     if AST.get_num_children == 2
%         % access function has two children(nodes), meaning a branch is not
%         % used
%         AST.add_valint_result(mfilename, 'warning', 'Use defined branches in access functions is recommended!');        
%     end
% end
end
 