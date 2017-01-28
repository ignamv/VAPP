classdef IrVisitorMark1 < IrVisitor
% IRVISITORMARK1 runs the first pass over the IR tree.
%
% The job of IrVisitorMark1 is the following:
% 1. Visit assignments and find out which variables are being initialized
% 2. Visit contributions and mark them as explicit/implicit/nullEqn
%    discover dummy IOs if any. 
%
% See also IRVISITOR
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        module = IrNodeModule.empty;
    end

    methods

        function obj = IrVisitorMark1(irTree)
            if nargin > 0
                obj.traverseIr(irTree);
            end
        end

        function traverseSub = visitGeneric(thisVisitor, irNode)
            traverseSub = true;
        end

        function endTraversal(thisVisitor)
            thisVisitor.module.assignIoIdx();
        end

        function traverseSub = visitIrNodeModule(thisVisitor, moduleNode)
            traverseSub = true;
            thisVisitor.module = moduleNode;
        end

        function traverseSub = visitIrNodeAssignment(thisVisitor, assignNode)
            traverseSub = false;

            digger = IrVisitorIoVarParmDigger();
            rhsNode = assignNode.getRhsNode();
            digger.traverseIr(rhsNode);

            % Note that it is important to first the rhs vars as used before
            % setting the lhs var as initialized.
            rhsVarVec = digger.getVarVec();

            for varObj = rhsVarVec
                varObj.setUsed();
            end

            lhsNode = assignNode.getLhsNode();
            lhsVarObj = lhsNode.getVarObj();
            lhsVarObj.setInitialized();

            rhsIoVec = digger.getIoVec();
            for io = rhsIoVec
                io.setRhs();
            end
        end

        function traverseSub = visitIrNodeContribution(thisVisitor, contNode)
            traverseSub = true;

            lhsIoObj = contNode.getLhsIoObj();
            lhsNode = contNode.getLhsNode();
            rhsNode = contNode.getRhsNode();

            % create a digger object to dig trough the RHS of the
            % contribution statement
            digger = IrVisitorIoVarParmDigger(lhsIoObj);
            digger.traverseIr(rhsNode);

            rhsVarVec = digger.getVarVec();
            for varObj = rhsVarVec
                varObj.setUsed();
            end

            rhsIoVec = digger.getIoVec();
            for io = rhsIoVec()
                if io ~= lhsIoObj
                    % the rhs/lhs flags of the lhsIo will be handled below
                    % (depending on the contribution being implicit or not and
                    % its having a dummy IO on the lhs or not).
                    io.setRhs();
                end
            end

            nMatch = digger.getNMatchedIo();

            if nMatch == 0
                lhsIoObj.setLhs();
            else
                contNode.setImplicit();
                if nMatch == 1
                    % the lhsIo is not a LHS IO any more. When printing, it
                    % will be moved to the RHS. Hence we set its rhs flag
                    % below.
                    matchedIoNode = digger.getMatchedIoNode();
                    isAdditive = matchedIoNode.isAdditive();
                    % Here the lhsNode can also be an inverse IO. Hence, we
                    % multiply isAdditive with the sign of the lhsIo
                    isAdditive = isAdditive*lhsNode.isAdditive();

                    if isAdditive == 1
                        % lhsIo is dummy. Don't set its lhs/rhs flags.
                        % instead, set dummy flag for the IO node.
                        contNode.setNullEqn();
                        contNode.setRhsDummyNode(matchedIoNode);
                        matchedIoNode.setDummy();
                        lhsNode.setDummy();
                    else
                        lhsIoObj.setRhs();
                    end
                else
                    lhsIoObj.setRhs();
                end
            end
        end

        function  traverseSub = visitIrNodeVariable(thisVisitor, varNode)
            % Variables can be used in assignments/conditionals etc.
            % the only time when we don't want to mark a variable as used is if
            % it's on the rhs of an assignment. This case is handled by the
            % visitAssignment method above. This means a lhs variable is never
            % visited by this visitor.
            traverseSub = true;
            varObj = varNode.getVarObj();
            varObj.setUsed();
        end

        function traverseSub = visitIrNodeFunction(thisVisitor, funcNode)
        % VISITIRNODEFUNCTION discovers ddt functions
        % This is the place where we use the functionality provided by
        % IrNodeNumerical.

            % ddt rules
            if funcNode.hasName('ddt')
                parentNode = funcNode.getParent();
                childNode = funcNode;
                
                % we allow the parent node to be either a contribution node or
                % an operation

                % start with a ddt node
                % go on until you hit an operation that is not multiplicative
                while parentNode.isMultiplicative() == true
                    childNode = parentNode();
                    parentNode = childNode.getParent();
                end

                % set it ddtTopNode
                childNode.setDdtTopNode();

                % go on traversing the tree upwards until you find a node that
                % breaks the chain to the ddtTopNode
                % set all the nodes in between onDdtPath
                while parentNode.isAffine() == true
                    parentNode.setOnDdtPath();
                    childNode = parentNode();
                    parentNode = childNode.getParent();
                end


            % end if ddt
            end
            traverseSub = true;
        % end visitFunc
        end

        function traverseSub = visitIrNodeAnalogFunction(thisVisitor, funcNode)
            traverseSub = false;
            funcVisitor = IrVisitorMark1();
            funcVisitor.module = funcNode; % again, this is ugly!
            funcVisitor.traverseChildren(funcNode);
        end
    end
end
