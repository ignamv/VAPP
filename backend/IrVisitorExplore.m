classdef IrVisitorExplore < IrVisitor
% IRVISITOREXPLORE print the IR tree

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        function traverseIr(thisVisitor, irNode, indentLevel)

            % traverse the tree recursively and visit every node
            
            nChild = irNode.getNChild();

            out = irNode.acceptVisitor(thisVisitor, indentLevel);

            if iscell(out)
                traverseSub = out{1};
            else
                traverseSub = out;
            end

            if traverseSub == true
                indentLevel = indentLevel+1;
                for i=1:nChild
                    thisVisitor.traverseIr(irNode.getChild(i), indentLevel);
                end
            end

            if irNode.hasType('Module')
                thisVisitor.endTraversal();
            end
        end

        function out = visitGeneric(thisVisitor, irNode, indentLevel)
            out =  true;
            thisVisitor.printIndent(class(irNode), indentLevel);
        end

        function out = visitIrNodeInputOutput(thisVisitor, ioNode, indentLevel)
            out = true;
            outStr = sprintf('InputOutput: %s', ioNode.getIoObj.getLabel());
            thisVisitor.printIndent(outStr, indentLevel);
        end

        function out = visitIrNodeOperation(thisVisitor, opNode, indentLevel)
            out = true;
            outStr= sprintf('Operation: %s, ddtTopNode: %d, onDdtPath = %d',...
                                                         opNode.getOpType(),...
                                                         opNode.isDdtTopNode(),...
                                                         opNode.isOnDdtPath());
            thisVisitor.printIndent(outStr, indentLevel);
        end

        function out = visitIrNodeVariable(thisVisitor, varNode, indentLevel)
            out = true;
            outStr = sprintf('Variable: %s', varNode.getName());
            thisVisitor.printIndent(outStr, indentLevel);
        end

        function out = visitIrNodeParameter(thisVisitor, parmNode, indentLevel)
            out = true;
            outStr = sprintf('Parameter: %s', parmNode.getName());
            thisVisitor.printIndent(outStr, indentLevel);
        end

        function out = visitIrNodeConstant(thisVisitor, constNode, indentLevel)
            out = true;
            outStr = sprintf('Constant: type = %s, value = %g, onDdtPath = %d',...
                                                     constNode.getDataType(),...
                                                     constNode.getValue(),...
                                                     constNode.isOnDdtPath());
            thisVisitor.printIndent(outStr, indentLevel);
        end

        function out = visitIrNodeFunction(thisVisitor, funcNode, indentLevel)
            out = true;
            outStr = sprintf('Function: %s, ddtTopNode: %d', ...
                                                        funcNode.getName(),...
                                                        funcNode.isDdtTopNode);
            thisVisitor.printIndent(outStr, indentLevel);
        end

    end
    methods (Static)
        function outStr = printIndent(inStr, indentLevel)
            indentStr = repmat('  ', 1, indentLevel);
            fprintf([indentStr, inStr, '\n']);
        end
    end
end
