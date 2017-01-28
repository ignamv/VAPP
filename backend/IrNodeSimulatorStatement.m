classdef IrNodeSimulatorStatement < IrNode
% IRNODESIMULATORSTATEMENT represents a simulator statement in Verilog-A

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = IrNodeSimulatorStatement()
            obj = obj@IrNode();
            obj.indentStr = '';
        end

        function [outStr, printSub] = sprintFront(thisNode)
            printSub = false;
            outStr = sprintAll(thisNode.getChild(1));
            outStr = [outStr, '\n'];
        end
    end
end
