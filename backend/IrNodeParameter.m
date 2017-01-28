classdef IrNodeParameter < IrNodeNumerical
% IRNODEPARAMETER represents a parameter in Verilog-A
% This class is a container for an MsParameter object.
% See also MSPARAMETER.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        parmObj = MsParameter.empty;
    end

    methods
        function obj = IrNodeParameter(parmObj)
            obj = obj@IrNodeNumerical();
            obj.parmObj = parmObj;
            obj.additive = 1;
            obj.multiplicative = 1;
        end

        function parmName = getName(thisParameter)
            parmName = thisParameter.parmObj.getName();
        end

        function outStr = sprintNumerical(thisNode, ~)
            outStr = thisNode.getName();
        end
    end

end
