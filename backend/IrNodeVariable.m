classdef IrNodeVariable < IrNodeNumerical
% IRNODEVARIABLE represents a variable in Verilog-A
% This class is a container for an MsVariable object.
% See also MSVARIABLE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        varObj = MsVariable.empty;
    end

    methods
        function obj = IrNodeVariable(varObj)
            obj = obj@IrNodeNumerical();
            obj.varObj = varObj;
            obj.additive = 1;
            obj.multiplicative = 1;
        end

        function varName = getName(thisVariable)
            varName = thisVariable.varObj.getName();
        end

        function varObj = getVarObj(thisVariable)
            varObj = thisVariable.varObj;
        end

        function outStr = sprintNumerical(thisNode, ~)
            outStr = thisNode.getName();
        end

    end
end
