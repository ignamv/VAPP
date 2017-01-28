function valint_rule_no_bitwise_and_shift_operators(AST)
% >> Rule
% The use of bit-wise operators is not recommeded, and the use of shift
% operators is not allowed.
%
% >> Type
% Error
%
% >> Bad practice code
%  if ((NBG!=0) & (!$param_given(PHIG2)))  begin
%
% >> Good practice code
%  if ((NBG!=0) && (!$param_given(PHIG2)))  begin
%
% >> Comment
% The bit-wise operators and shift operators shall not be used in
% Verilog-A. The bitwise operatire "&", for example, is often confused and
% mis-used as the logical AND, which is "&&"
%
% >> Reference
%
% >> Added
% 3/8/2016
%
% >> ID
% 18


if strcmp(AST.get_type, 'op')
    if sum(strcmp(AST.get_attr('op'), {'^', '^~', '~^', '~', '<<', '>>', '<<<', '>>>', '&', '|'}))
        
        AST.add_valint_result(mfilename, 'error', 'Use of bitwise and shift operators are not allowed!', 18, 1);
    end
end
end
 