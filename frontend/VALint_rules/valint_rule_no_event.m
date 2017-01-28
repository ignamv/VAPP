function valint_rule_no_event(AST)
% >> Rule
% The use of event statement is not allowed
%
% >> Type
% Error
%
% >> Bad practice code
% if (@cross(n1,1.5)) ...
%
% >> Good practice code
% Do not use event statement.
%
% >> Comment
% Event statements are intended for behavioral modeling, not compact
% modeling.
%
% >> Reference
% Page 388 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 11


if strcmp(AST.get_type, 'func')
    this_name = AST.get_attr('name');
    if strcmp(this_name(1), '@')
        AST.add_valint_result(mfilename, 'error', ['Use of event function ' this_name ' is not allowed!'], 11, 1);
    end
end
end
 