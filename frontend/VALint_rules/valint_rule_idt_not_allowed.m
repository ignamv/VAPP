function valint_rule_idt_not_allowed(AST)
% >> Rule
% Time integral operator is disallowed
%
% >> Type
% Error
%
% >> Bad practice code
% I(branch) <+ idt(V(branch)/L);
%
% >> Good practice code
% V(branch) <+ ddt(L*I(branch));
%
% >> Comment
% Circuit simulators are primarily DAE solvers, so formulate compact models
% using the time derivative operator ddt() but do NOT use the time integral
% operator idt().
%
% >> Reference
% Page 385 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 2


if strcmp(AST.get_type, 'func')
    if strcmp(AST.get_attr('name'), 'idt')
        % idt found.
        AST.add_valint_result(mfilename, 'error', 'time integral operator (idt) is not allowed!', 2, 1);
    end
end
end
 