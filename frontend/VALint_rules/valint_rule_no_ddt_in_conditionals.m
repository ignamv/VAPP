function valint_rule_no_ddt_in_conditionals(AST, is_recur_called)
% >> Rule
% Having ddts() in conditional statements are not recommended
%
% >> Type
% Warning
%
% >> Bad practice code
%
% Qbd_ddt = ddt(Qbd);
% Qbs_ddt = ddt(Qbs);
% if (V(b_ds) >= 0.0) begin
%     Ibdx_ddt = Qbd_ddt;
%     Ibsx_ddt = Qbs_ddt;
% end else begin
%     Ibdx_ddt = Qbs_ddt;
%     Ibsx_ddt = Qbd_ddt;
% end
% I(b_bd) <+ Ibdx_ddt;
% I(b_bs) <+ Ibsx_ddt;
%
% >> Good practice code
%
% if (V(b_ds) >= 0.0) begin
%     Qbsx = Qbd;
%     Qbsx = Qbs;
% end else begin
%     Qbsx = Qbs;
%     Qbsx = Qbd;
% end
% I(b_bd) <+ ddt(Qbdx);
% I(b_bs) <+ ddt(Qbsx);
%
% >> Comment
% Avoid using variables that depend on ddt() in conditionals, as this
% causes an extra branch equation to be created
%
% >> Reference
% Page 388 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 13


if nargin == 1
    is_recur_called = 0;
end

if strcmp(AST.get_type, 'func')
    if is_recur_called
        % function, and is recursively called
        
        if strcmp(AST.get_attr('name'), 'ddt')
            % check if this function is inside a conditional
            AST.add_valint_result(mfilename, 'warning', 'Use of ddt() inside conditionals is not recommeneded', 13, 1);
        end
    else
        % function, but is not recursively called
        if strcmp(AST.get_attr('name'), 'ddt')
            if is_inside_conditional(AST)
                AST.add_valint_result(mfilename, 'warning', 'Use of ddt() inside conditionals is not recommeneded', 13, 1);
            end
        end
    end
end

if strcmp(AST.get_type, 'var')
    if ~isempty(AST.get_alias)
        for this_alias = AST.get_alias
            valint_rule_no_ddt_in_conditionals(this_alias{1}, 1)
        end
    end
end

end % END of valint_rule_no_ddt_in_conditionals

function result = is_inside_conditional(AST)
result = 0;

this_type = AST.get_type;

if strcmp(this_type, 'if')
    result = 1;
    return;
end

if ~isempty(AST.get_parent)
    result = is_inside_conditional(AST.get_parent);
end

end % END of is_inside_conditional