classdef IrNodeFunction < IrNodeNumerical
% IRNODEFUNCTION represents a function call on the RHS of an assignment or a
% contribution statement.
% For the class responsible for defining a function in Verilog-A, see the
% IrNodeAnalogFunction class.
%
% See also IrNodeAnalogFunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods
        function obj = IrNodeFunction(name)
            obj = obj@IrNodeNumerical();
            obj.name = name;
            obj.indentStr = '';
        end

        function outStr = sprintNumerical(thisNode, sprintAllFunc)

            funcName = thisNode.name;
            if strcmp(funcName, 'ddt') == true
                childNode = thisNode.getChild(1);
                outStr = childNode.sprintAll();
            else
                % add function names that should be overridden by VAPP here
                switch funcName
                    case 'ln'
                        funcName = 'log';
                    case 'log'
                        funcName = 'log10';
                    case {'pow', 'limexp'}
                        funcName = [funcName, '_vapp'];
                end

                outStr = [funcName, '('];

                % add the first child to the argument list (this is not in the
                % for loop below because we don't want to put a comma before
                % the first argument).
                childNode = thisNode.getChild(1);
                outStr = [outStr, sprintAllFunc(childNode)];
                % add all the remaining children to the argument list if any
                for i=2:thisNode.nChild
                    childNode = thisNode.getChild(i);
                    outStr = [outStr, ', ', sprintAllFunc(childNode)];
                end
                outStr = [outStr, ')'];
            end
        end
    end

end
