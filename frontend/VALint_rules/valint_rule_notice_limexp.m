function valint_rule_notice_limexp(AST)
% >> Rule
% Notice that using limexp() instead of exp() may protect arguments to
% functions from causing numerical overflows
%
% >> Type
% Notice
%
% >> Bad practice code
% exp(a)
%
% >> Good practice code
% limexp(a)
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
% 9


if strcmp(AST.get_type, 'func')
    if strcmp(AST.get_attr('name'), 'exp')
        AST.add_valint_result(mfilename, 'notice', 'Notice that using limexp() instead of exp() may protect arguments to functions from causing numerical overflows.', 9, 0);  
    end
end
end
 