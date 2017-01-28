function valint_rule_no_reference_to_ground(AST)
% >> Rule
% Referencing to ground by not specifying the second argument of a
% potential is now allowed, except for a ddx() argument.
%
% >> Type
% Error
%
% >> Bad practice code
% V(a)
%
% >> Good practice code
% branch (a,b) b_cond;
% V(b_cond);
%
% >> Comment
% 
%
% >> Reference
%
% >> Added
% 3/8/2016
%
% >> ID
% 16


if strcmp(AST.get_type, 'V')||strcmp(AST.get_type, 'I')
    if ~isempty(AST.get_attr('ref_to_ground'))
        % not using a branch argument and has only a single argument. Therefore, it is referencing to ground by
        % default.
        
        % However, if it is within a ddx() function, it is okay
        if ~parent_has_ddx(AST,0)
            AST.add_valint_result(mfilename, 'error', 'Reference to ground is not allowed!', 16, 1);
        end
    end
end
end % END of valint_rule_no_reference_to_ground

function has_ddx = parent_has_ddx(AST, has_ddx)
if strcmp(AST.get_type, 'func')
    if strcmp(AST.get_attr('name'), 'ddx')
        has_ddx = 1;
        return;
    end
end

% if children exists, recursively get each child
if ~isempty(AST.get_parent)
    has_ddx = parent_has_ddx(AST.get_parent, has_ddx);
end
end % END of parent_has_ddx
 