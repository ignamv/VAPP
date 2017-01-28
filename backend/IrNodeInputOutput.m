classdef IrNodeInputOutput < IrNodeNumerical
% IRNODEINPUTOUTPUT represents a probe in Verilog-A
% This class is a container around the actual IO class MsInputOutput
%
% See also MSINPUTOUTPUT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties (Access = private)
        ioObj = MsInputOutput.empty;
        label = '';
        dummy = false;
    end

    methods
        function obj = IrNodeInputOutput(ioObj, label)
            obj = obj@IrNodeNumerical();
            obj.ioObj = ioObj;
            obj.label = label;
            obj.additive = 1;       % inherited from IrNodeNumerical
            obj.multiplicative = 1; % inherited from IrNodeNumerical
        end

        function ioObj = getIoObj(thisNode)
            ioObj = thisNode.ioObj;
        end

        function label = getLabel(thisNode)
            label = thisNode.label;
        end

        function outStr = sprintNumerical(thisNode, ~)
            if thisNode.dummy == true
                outStr = '0';
            else
                outStr = thisNode.label;
            end
        end

        function setDummy(thisNode)
        % SETDUMMY make this node a dummy node
        % For an explanation of what a dummy node is, see the
        % IrNodeContribution class.
            thisNode.dummy = true;
        end

        function out = isDummy(thisNode)
        % ISDUMMY is this node a dummy node?
            out = thisNode.dummy;
        end

        function out = isAdditive(thisNode)
            out = thisNode.additive;
            if thisNode.ioObj.isInverseIo() == true
                % additive property of the IO node is set to -1 if it's an
                % inverse IO. This is used in order to determine if a
                % contribution is a nullEqn. 
                % For the explanations see 
                % nullEqn -> IrNodeContribution
                % inverseIo -> MsInputOutput
                % additive(ness) -> IrNodeNumerical
                out = -1*out;
            end
        end
    end
end
