classdef IrNodeAssignment < IrNodeNumerical
% IRNODEASSIGNMENT represents a Verilog-A assignment
%
% See also IRNODENUMERICAL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        function  obj = IrNodeAssignment()
            obj = obj@IrNodeNumerical();
            obj.additive = 1;
        end

        function outStr = sprintNumerical(thisNode, ~)
            lhsNode = thisNode.getLhsNode();
            rhsNode = thisNode.getRhsNode();
            lhsStr = lhsNode.sprintAll();
            rhsStr = rhsNode.sprintAll();

            outStr = sprintf('%s = %s;\n', lhsStr, rhsStr);
        end

        function lhsNode = getLhsNode(thisNode)
            lhsNode = thisNode.getChild(1);
        end

        function rhsNode = getRhsNode(thisNode)
            rhsNode = thisNode.getChild(2);
        end

    % end methods
    end

% end classdef
end
