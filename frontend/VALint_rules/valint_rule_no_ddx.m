function valint_rule_no_ddx(AST)
% >> Rule
% Use ddx() for calculation of (small-signal) quantifies for operating
% point information printing, but not for actual model calculations.
%
% >> Type
% Error
%
% >> Bad practice code
% 
%
% >> Good practice code
%
%
% >> Comment
%
% >> Reference
% Page 388 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 17

if strcmp(AST.get_type, 'func')
    if strcmp(AST.get_attr('name'), 'ddx')
        % check if this function is inside a conditional
        AST.add_valint_result(mfilename, 'error', 'Use of ddx() outside of non-noise calculations is not allowed', 17, 1);
    end
end

end % END of valint_rule_no_ddx