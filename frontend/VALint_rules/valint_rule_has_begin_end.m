function valint_rule_has_begin_end(AST)
% >> Rule
% Use begin and end around a conditional code block even if it consists of
% just a single statement
%
% >> Type
% Warning
%
% >> Bad practice code
% if (a<0)
%    b=9;
% c=10;
%
% >> Good practice code
% if (a<0) begin
%    b=9;
% end
% c=10;
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
% 7


if max(strcmp(AST.get_type, {'if' 'for' 'while'}))
    for this_children = AST.get_children
        % return if any of the children is a block
        if strcmp(this_children{1}.get_type,'block')
            return;
        end
    end
    
    AST.add_valint_result(mfilename, 'warning', 'Use "begin" and "end" around a consitional code block is recommended!', 7, 1);        
end
end
 