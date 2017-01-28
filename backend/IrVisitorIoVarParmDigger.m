classdef IrVisitorIoVarParmDigger < IrVisitor
% IRVISITORIOVARPARMDIGGER operates on the rhs of an assignment or a
% contribution and gathers information about IOs and variables.
% This visitor is intended to be spawned by other visitors that operate on
% larger scopes than a single equation or contribution.
%
% See also IRVISITORMARK1 IRVISITORMARK2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        ioVec = MsInputOutput.empty;
        parmVec = MsParameter.empty;
        varVec = MsVariable.empty;
        targetIoObj = MsInputOutput.empty;
        matchedIoNode = IrNodeInputOutput.empty;
        nMatchedIo = 0; % number of times the target IO is encountered
    end

    methods

        function obj = IrVisitorIoVarParmDigger(targetIoObj)
            if nargin > 0
                obj.targetIoObj = targetIoObj;
            end
        end

        function traverseSub = visitGeneric(thisVisitor, irNode)
            traverseSub = true;
        end

        function traverseSub = visitIrNodeInputOutput(thisVisitor, ioNode)
            traverseSub = false; % IO nodes don't have any children anyway
            ioObj = ioNode.getIoObj();
            thisVisitor.add2IoVec(ioObj);
            targetIoObj = thisVisitor.targetIoObj;

            if isempty(targetIoObj) == false && (ioObj == targetIoObj)
                thisVisitor.nMatchedIo = thisVisitor.nMatchedIo + 1;
                thisVisitor.matchedIoNode = ioNode;
            end
        end

        function traverseSub = visitIrNodeVariable(thisVisitor, varNode)
            traverseSub = false;
            varObj = varNode.getVarObj();
            thisVisitor.add2VarVec(varObj);
        end

        function add2IoVec(thisVisitor, ioObj)
            if all(thisVisitor.ioVec ~= ioObj)
                thisVisitor.ioVec = [thisVisitor.ioVec, ioObj];
            end
        end

        function add2VarVec(thisVisitor, varObj)
            if all(thisVisitor.varVec ~= varObj)
                thisVisitor.varVec = [thisVisitor.varVec, varObj];
            end
        end

        function ioVec = getIoVec(thisVisitor)
            ioVec = thisVisitor.ioVec;
        end

        function varVec = getVarVec(thisVisitor)
            varVec = thisVisitor.varVec;
        end

        function nMatch = getNMatchedIo(thisVisitor)
            nMatch = thisVisitor.nMatchedIo;
        end

        function matchedNode = getMatchedIoNode(thisVisitor)
            matchedNode = thisVisitor.matchedIoNode;
        end
    end

end
