classdef IrNodeNumerical < IrNode
% IRNODENUMERICAL abstract class for IrNodes that are encountered in
% assignments and contributions. These are nodes such as operations, functions,
% constants, variables, etc. Main functionality added by IrNodeNumerical is the
% functionality given by the sprintAllDdt method. This method prints only the
% ddt part of a numerical statement. The usual method (sprintAll), on the other
% hand, does NOT print the ddt part.
%
% Classes that implement IrNodeNumeical must define the sprintAllNumerical
% method and they inherit the sprintAllDdt method.
% sprintAllDdt prints a numeric object depending on its ddtTopNode and
% onDdtPath properties.
%
% A ddtTopNode is a node which has a multiplicative path to a ddt function or
% the ddt function itself.
%
%   3*(I(p,s) + 2*ddt(I(p,n))) -> 2 is ddtTopNode
%
% A node is onDdtPath if it has a multiplicative and/or additive connection to
% a ddtTopNode.
%
%   3*(I(p,s) + 2*ddt(I(p,n))) -> '+' and 3 are onDdtPath, I(p,s) is not.
%
% the ddt part of the above contribution will be printed as
%
%   3*(+2*ipn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = protected)
        additive = 0; % 1 when an IO appears without being multiplied by anything.
        % -1 when IO is inverseIo.
        % this is used by IrVisitorMark1 to determine if a contribution is a
        % nullEqn.
        multiplicative = false; % do we have a multiplicative path to the ddtTopNode?
        affine = false; % is the node +,-,* or /?
        ddtTopNode = false; % an operation or a function can be a ddtTopNode
        % ddtTopNode property is currently set by IrVisitorMark1
        onDdtPath = false; % do we print this node when we are printing the ddt
                           % part?
    end

    methods (Abstract)
        outStr = sprintNumerical(thisNode, sprintAllFuncHandle);
        % the second argument above, sprintAllFunctionHandle, is used when
        % calling the print methods of the CHILDREN of a node. It tells
        % thisNode which of the print methods of it's children it should call.
        % The two possibilities are:
        % 1. sprintAllFuncHandle = @sprintAll
        % 2. sprintAllFuncHandle = @sprintAllDdt
        % The first one is used when we want to print all the child nodes up to
        % the ddtTopNode. The second one is used when we want to print nodes
        % connected to the ddt function.
    end

    methods
        function obj = IrNodeNumerical()
            obj = obj@IrNode();
        end

        function addChild(thisNode, childNode)
            addChild@IrNode(thisNode, childNode);
            childNode.setAdditive(thisNode.additive);
        end

        function setAdditive(thisNode, inVal)
            thisNode.additive = thisNode.additive*inVal;
        end

        function out = isAdditive(thisNode)
            out = thisNode.additive;
        end

        function out = isMultiplicative(thisNode)
            out = thisNode.multiplicative;
        end

        function out = isAffine(thisNode)
            out = thisNode.affine;
        end

        function setDdtTopNode(thisNode)
            thisNode.ddtTopNode = true;
        end

        function out = isDdtTopNode(thisNode)
            out = thisNode.ddtTopNode;
        end

        function setOnDdtPath(thisNode)
            thisNode.onDdtPath = true;
        end

        function out = isOnDdtPath(thisNode)
            out = thisNode.onDdtPath;
        end

        function [outStr, printSub] = sprintAll(thisNode)
            % if this node is a ddtTopNode don't print anything and stop
            % printing the children as well.
            if thisNode.ddtTopNode == true
                outStr = '';
            else
                % if not call the sprintNumerical method of this object
                outStr = thisNode.sprintNumerical(@sprintAll);
                % the @sprintAll argument above tell the object that it should
                % call the sprintAll method of its children.
            end
            printSub = false;
        end

        function outStr = sprintAllDdt(thisNode)
            if thisNode.ddtTopNode == true
                % if this a ddtTopNode, every child of this node belongs to a
                % ddt contribution. HENCE, CALL THE SPRINTNUMERICAL METHOD
                % ALONG WITH ITS CHILDREN'S SPRINTALL METHODS
                outStr = thisNode.sprintNumerical(@sprintAll);
            elseif thisNode.onDdtPath == true
                % if this node is not a ddtTopNode but it's on the ddtPath,
                % call this objects sprintAllNumerical method BUT TELL IT TO
                % CALL ITS CHILDREN'S SPRINTALLDDT METHODS
                outStr = thisNode.sprintNumerical(@sprintAllDdt);
            else
                % if not a ddtTopNode or onDdtPath this node does not get
                % printed in the ddt contribution. Hence don't print anything
                % and directly call its children's sprintAllDdt methods.
                % Note that a child of this node can still be onDdtPath or even
                % ddtTopNode.
                outStr = '';
                for i=1:thisNode.nChild
                    outStr = [outStr, thisNode.childVec(i).sprintAllDdt()];
                end
            end
        end

    end
end
