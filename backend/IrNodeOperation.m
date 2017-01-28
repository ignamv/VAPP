classdef IrNodeOperation < IrNodeNumerical
% IRNODEOPERATION represents an operation node in Verilog-A
%
% Operator precedence in VA (Taken from: VAPP_parse.m)
% Table of precedence and associativity of Verilog-A operators (lower 
% precedence numbers indicate higher priority):
%
%    +------------+---------------+-----------+
%    | Precedence | Associativity | Operators |
%    +------------+---------------+-----------+
%    |          1 | Left          | u+ u- !   |
%    |          2 | Left          | **        |
%    |          3 | Left          | * / %     |
%    |          4 | Left          | + -       |
%    |          5 | Left          | < <= > >= |
%    |          6 | Left          | == !=     |
%    |          7 | Left          | &&        |
%    |          8 | Left          | ||        |
%    |          9 | Right         | ? :       |
%    +------------+---------------+-----------+
%
% Operator precedence in MATLAB (taken from MATLAB documentation)
% 
% 1. ()
% 2. .', .^, ', ^
% 3. +, -, ~
% 4. .*, ./, .\, *, /, \
% 5. +, -
% 6. :
% 7. <, <=, >, >=, ==, ~=
% 8. &, |, &&, ||
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Constant)
        % '%' and '?:' have NaN rank because we replace them with function
        % calls. Notice how for a number a, both (a > NaN) and (a < NaN) are
        % false. This is exactly the behavior we want when printing mod() and
        % qmcol().
        %
        % A higher number indicates higher precedence
        OPARR = {'**', 'u+', 'u-', '!', '*', '/', '+', '-', '<', '<=', '>', '>=', '!=', '==', '&&', '||', '?:', '%'};
        OPRANK = [6,    5,    5,    5,   4,   4,   3,   3,   2,   2,    2,   2,    2,    2,    1,    1,    NaN,  NaN];
    end

    properties (Access = private)
        opType = '';
        opRank = 0;
    end

    methods
        function obj = IrNodeOperation(opType)
            obj = obj@IrNodeNumerical();
            obj.opType = opType;
            obj.tabStr = '';
            obj.opRank = IrNodeOperation.OPRANK(...
                                        strcmp(opType, IrNodeOperation.OPARR));

            if obj.hasOpType({'+', '-'})
                obj.additive = 1;
                obj.affine = true;
            elseif obj.hasType('u+')
                obj.additive = 1;
                obj.affine = true;
                obj.multiplicative = true;
            elseif obj.hasOpType('u-')
                obj.additive = -1;
                obj.affine = true;
                obj.multiplicative = true;
            elseif obj.hasOpType({'*', '/'})
                obj.multiplicative = true;
                obj.affine = true;
            end
        end

        function addChild(thisNode, childNode)
            if thisNode.hasOpType('-') && thisNode.nChild == 1
                thisNode.additive = -1;
            end

            addChild@IrNodeNumerical(thisNode, childNode);
        end

        function out = getOpType(thisNode)
            out = thisNode.opType;
        end

        function out = hasOpType(thisNode, opType)
            out = any(strcmp(thisNode.opType, opType));
        end

        function setOnDdtPath(thisNode)
            % ATTENTION: this function is here because if we multiply a ddt
            % with a constant, we also would like to print out that constant.
            % Watch for side effects -> needs thorough testing
            setOnDdtPath@IrNodeNumerical(thisNode);
            if thisNode.isMultiplicative()
                for childNode = thisNode.childVec
                    childNode.setOnDdtPath();
                end
            end
        end

        function outStr = sprintNumerical(thisNode, sprintAllFunc)
            outStr = '';
            opStr = thisNode.opType;
            
            childNode1 = thisNode.getChild(1);
            childStr1 = sprintAllFunc(childNode1);

            if thisNode.getNChild() > 1
                childNode2 = thisNode.getChild(2);
                childStr2 = sprintAllFunc(childNode2);
            end

            if thisNode.getNChild() > 2
                childNode3 = thisNode.getChild(3);
                childStr3 = sprintAllFunc(childNode3);
            end

            % convert operators
            if thisNode.hasOpType('**') == true
                opStr = '^';
            end
                

            if thisNode.hasOpType({'u-', 'u+'}) == true
                outStr = [outStr, opStr(2), childStr1];
            elseif thisNode.hasOpType('!') == true
                outStr = [outStr, '~', childStr1];
            elseif thisNode.hasOpType('!=') == true
                outStr = [outStr, childStr1, '~=', childStr2];
            elseif thisNode.hasOpType('?:') == true
                outStr = [outStr, 'qmcol_vapp(', childStr1, ', ',...
                                                 childStr2, ', ',...
                                                 childStr3, ')'];
            elseif thisNode.hasOpType('%') == true
                outStr = [outStr, 'mod(', childStr1, ', ', childStr2, ')'];
            else
                if isempty(childStr2)
                    opStr = '';
                end
                outStr = [outStr, childStr1, opStr, childStr2];
            end

            parentNode = thisNode.getParent();
            % use parenthesis if operators have the same rank: the user might
            % have considered numerical effects and  separated them in the
            % original code.
            if isempty(outStr) == false && ...
                isa(parentNode, 'IrNodeOperation') && ...
                 thisNode.opRank <= parentNode.opRank
                outStr = ['(', outStr, ')'];
            end
        end
    end

end
