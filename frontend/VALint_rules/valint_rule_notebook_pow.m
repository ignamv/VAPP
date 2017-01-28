function valint_rule_notebook_pow(notebook, AST)
% >> Rule
% The use of branch in access function is recommended
%
% >> Type
% Warning
%
% >> Bad practice code
% x=$pow(a,b);
% y=$pow(a,c);
% z=$pow(a,d);
%
% >> Good practice code
% ln_a=$ln(a);
% x=$exp(b*ln_a);
% y=$exp(c*ln_a);
% z=$exp(d*ln_a);
%
% >> Comment
% If you have several calls to $pow() with the same first argument, replace
% $pow(x,y) with $exp(y*ln_x), where ln_x=$ln(x) is computed once
%
% >> Reference
% Page 392 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 2.1


chapter_pow = notebook.pow;

for index = 1:size(chapter_pow,1)
    if chapter_pow{index,2} > 1
        this_argu = chapter_pow{index,1};
        
        result = '';
        for i = 1:length(this_argu)
            result = [result num2str(this_argu{i})];
        end

        AST.add_valint_result(mfilename, 'notice', sprintf('%d instances of pow(%s,) is found. Replace with $exp for speed.', chapter_pow{index,2}, result), 2.1, 0);
    end
end

end
 