function valint_rules_documentation_generate()
% This function parses through all the "valint_rule_xxxxx.m" files and
% collect the rules. A documentation will be generated afterward.
%--------------------------------------------------------------------------
% Standard comment has the following form
%--------------------------------------------------------------------------
%
% >> Rule
% Check if the parameter has a range specified
%
% >> Bad practice code
% parameter real r=0;
%
% >> Good practice code
% parameter real r=0 from [0:inf);
%
% >> Comment
% All parameters need to have a range. This applies even to version number.
% A model's version number shall have a range that is positive.
%
% >> Reference
% Page 387 in C. C. McAndrew et al., "Best Practices for Compact Modeling in Verilog-A," in IEEE Journal of the Electron Devices Society, vol. 3, no. 5, pp. 383-396, Sept. 2015. doi: 10.1109/JEDS.2015.2455342
%
% >> Added
% 2/14/2016