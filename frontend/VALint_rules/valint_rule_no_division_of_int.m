function valint_rule_no_division_of_int(AST)
% >> Rule
% Division of integer types is not recommended. Divison of double type can
% be converted to mulitplication istead of speed.
%
% >> Type
% Warning
%
% >> Bad practice code
%
% c=1/2;
%
% >> Good practice code
%
% c=1.0/2.0;
%
% >> Comment
% 
%
% >> Reference
% Page 389 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 15



if strcmp(AST.get_type, 'op')
    if strcmp(AST.get_attr('op'), '/')
        left_node = AST.get_children{1};
        right_node = AST.get_children{2};
        
        if strcmp(left_node.get_attr('dtype'), 'int') || strcmp(right_node.get_attr('dtype'), 'int')
            AST.add_valint_result(mfilename, 'warning', 'Division of integer type found!', 15.1, 1);
        end
        if strcmp(right_node.get_attr('dtype'), 'float')
            AST.add_valint_result(mfilename, 'notice', 'Division of double type can be converted to mulitplication instead for speed!', 15, 1);
        end
    end
end

end