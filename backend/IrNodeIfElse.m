classdef IrNodeIfElse < IrNode
% IRNODEIFELSE represents an if/else statement in Verilog-A

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        function obj = IrNodeIfElse()
            obj = obj@IrNode();
        end

        function [outStr, printSub] = sprintFront(thisIe)
            printSub = false;
            nChild = thisIe.nChild;

            childNode1 = thisIe.getChild(1);
            childNode2 = thisIe.getChild(2);
            condStr = childNode1.sprintAll();
            thenStr = childNode2.sprintAll();

            outStr = sprintf('if %s\n', condStr);
            outStr = sprintf('%s%s', outStr, thisIe.sprintfIndent(thenStr));
            if nChild > 2
                childNode3 = thisIe.getChild(3);
                elseStr = childNode3.sprintAll();
                outStr = sprintf('%selse\n%s', outStr,...
                                             thisIe.sprintfIndent(elseStr));
            end
        end

        function outStr = sprintBack(thisIe)
            outStr = 'end\n';
        end

    % end methods
    end

% end classdef
end
