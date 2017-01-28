function valint_rule_no_analysis(AST)
% >> Rule
% The use of analysis statement is not allowed
%
% >> Type
% Error
%
% >> Bad practice code
% if (analysis("tran")) ...
%
% >> Good practice code
% Do not use analysis.
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
% 4


if strcmp(AST.get_type, 'func')
    if strcmp(AST.get_attr('name'), 'analysis')
        
        AST.add_valint_result(mfilename, 'error', 'Use of "analysis" function is not allowed!', 4, 1);
    end
end
end
 