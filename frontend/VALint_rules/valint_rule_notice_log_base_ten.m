function valint_rule_notice_log_base_ten(AST)
% >> Rule
% Notice that log() is logarithm to the base 10
%
% >> Type
% Notice
%
% >> Bad practice code
% log(1e-3);
%
% >> Good practice code
% ln(1e-3);
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
% 8


if strcmp(AST.get_type, 'func')
    if strcmp(AST.get_attr('name'), 'log')
        AST.add_valint_result(mfilename, 'notice', 'Notice that log() is logarithm to the base 10; Use ln() for natural logarithm.', 8, 0);  
    end
end
end
 