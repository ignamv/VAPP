function valint_rule_no_both_potential_and_flow(AST)
% >> Rule
% Type of contribution changes is not recommended.
%
% >> Type
% Warning
%
% >> Bad practice code
%
% I(b_1) <+ a*b+c;
% ....
% V(b_1) <+ d+e*f;
%
% >> Good practice code
%
% V(b_1) <+ d+e*f;
%
% >> Comment
% In Verilog-A, both potential and flow contributions can be defined for a
% particular branch, and the contributions are additive. However, if the
% type of contribution changes, then any accumulated value from the
% opposite contribution type is discarded.
%
% >> Reference
% Page 389 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 14


this_note = AST.get_note('contrib_type_change');

if ~isempty(this_note)
    % The change of contribution type should be indicated in the advanced
    % AST tree. Simply find it and rise the warning.
    AST.add_valint_result(mfilename, 'warning', 'Contribution type has been redefined!', 14, 1);
    
end

end