function valint_rule_constants_redefine(AST)
% >> Rule
% Redefine constants outside of "constants.vams" is not recommended
%
% >> Type
% Warning
%
% >> Bad practice code
% `define pi 3.14
%
% >> Good practice code
% Use definitions from "constants.vams"
%
% >> Comment
% Use the mathematical constants that are defined in the Verilog-A standard
% "constants.vams"
%
% >> Reference
% Page 386 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 3/8/2016
%
% >> ID
% 3


constants_vams_values = [
    {'M_E'                2.7182818284590452354}
    {'M_LOG2E'            1.4426950408889634074}
    {'M_LOG10E'           0.43429448190325182765}
    {'M_LN2'              0.69314718055994530942}
    {'M_LN10'             2.30258509299404568402}
    {'M_PI'               3.14159265358979323846}
    {'M_TWO_PI'           6.28318530717958647693}
    {'M_PI_2'             1.57079632679489661923}
    {'M_PI_4'             0.78539816339744830962}
    {'M_1_PI'             0.31830988618379067154}
    {'M_2_PI'             0.63661977236758134308}
    {'M_2_SQRTPI'         1.12837916709551257390}
    {'M_SQRT2'            1.41421356237309504880}
    {'M_SQRT1_2'          0.70710678118654752440}
    {'P_Q_NIST2010'       1.602176565e-19}
    {'P_C'                2.99792458e8}
    {'P_K_NIST2010'       1.3806488e-23}
    {'P_H_NIST2010'       6.62606957e-34}
    {'P_EPS0_NIST2010'    8.854187817e-12}
    {'P_U0'               (4.0e-7 * 3.14159265358979323846)}
    {'P_CELSIUS0'         273.15}
];

if strcmp(AST.get_type, 'const')
    if max(strcmp(AST.get_pos{:}.macro_path, {'constant.vams','constant.va','constants.vams','constants.va'}))
        % definition of constant is okay within "constant.vams"
    else
        if max(strcmp(AST.get_attr('dtype'), {'float','integer','NI','int','real','NF'}))
            % check only if this contant is a number
        this_value = AST.get_attr('value');
        
        this_result = abs((cell2mat(constants_vams_values(:,2))-this_value)./this_value) < 1e-4;
        
        if sum(this_result)>0
            % idt found.
            AST.add_valint_result(mfilename, 'warning', ['Constant ' cell2mat(constants_vams_values(this_result,1)) ' appears to be used here without being sourced from "constant.vams". '], 3, 1);
        end
        end
    end
end
end
 