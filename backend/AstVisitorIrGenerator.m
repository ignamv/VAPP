classdef AstVisitorIrGenerator < AstVisitor
% ASTVISITORIRGENERATOR generate and intermediate representation from an AST
%
% AstVisitorIrGenerator will traverse the abstract syntax tree and generate an
% intermediate representation tree from the AST. The nodes of an IR tree is
% derived from the IrNode class and have this prefix, e.g., IrNodeContribution.
%
% See also ASTVISITOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: out{1}, out{2} expressions below are ugly. The reason I am using
% them is because there is no other way in MATLAB of making the visitor
% pattern generic enough in order to use a variable number of outputs in
% the visit methods. varargout does not work because it's a one time thing:
% We can't pass varargout from function to function.
%
% function varargout = fun1()
%     varargout = fun2();
% end
%
% function varargout = fun2()
%     varargout{1} = 'foo';
%     varargout{2} = 'bar';
% end
%
% does not work.
% This would work if we knew the nargout for fun2 beforehand,
%
% function varargout = fun1()
%     varargout = cell(nargoutFun2,1);
%     [varargout{:}] = fun2();
% end
%
% but this is exactly what we don't know.
%
% If, in the future, we settle down to a fixed number of outputs for the
% visit methods, then we can implement that version and get rid of the cell
% array output.
%
% TODO: The error messages emanating from the semantic checks in this class
% should ideally be done in a separate class with a design that can support a
% sort of a "rule book".
    properties (Access = private)
        irTree = IrNode.empty;
        module = IrNodeModule.empty; % for now assume there is only a single module
    end

    methods
        function obj = AstVisitorIrGenerator(astRoot)
            if nargin > 0
                obj.irTree = obj.traverseAst(astRoot);
            end
        end

        function out = visitGeneric(thisVisitor, astNode)
            out{1} = true;
            out{2} = IrNode();
            % the warning below should tell the programmer that a specific
            % IrNode for the astNode is missing and a generic one is being
            % created that will do nothing but pass the ball on when it gets
            % visited by an IrVisitor object. 
            warning('IrGen: Created generic node for %s: %s!', astNode.get_type())
        end

        function irTree = traverseAst(thisVisitor, astRoot)
            nChild = astRoot.get_num_children();

            out = astRoot.accept_visitor(thisVisitor);
            traverseSub = out{1};
            irTree = out{2};

            if traverseSub == true
                thisVisitor.traverseChildren(astRoot, irTree);
            end

            if astRoot.has_type('root')
                thisVisitor.endTraversal();
            end
        end

        function traverseChildren(thisVisitor, astNode, irNode)
            nChild = astNode.get_num_children();
            for i=1:nChild
                childTree = thisVisitor.traverseAst(astNode.get_child(i));
                if isempty(childTree) == false
                    childTree.setParent(irNode);
                    irNode.addChild(childTree);
                end
            end
        end

        function out = visitRoot(thisVisitor, rootNode)
            % for now assume that the model has only one module and do nothing
            % here. Just pass the ball on.
            out{1} = false;
            out{2} = thisVisitor.traverseAst(rootNode.get_child(1));
        end

        function out = visitModule(thisVisitor, moduleNode)
            out{1} = true;

            name = moduleNode.get_name();
            terminalList = moduleNode.get_attr('terminals');
            module = IrNodeModule(name, terminalList);
            thisVisitor.module = module;
            out{2} = module;
        end

        function out = visitElectrical(thisVisitor, electricalNode)
            % Don't create a tree node. Just import electrical nodes into the
            % module.
            nodeList = electricalNode.get_attr('terminals');
            thisVisitor.module.setNodeList(nodeList);
            out{1} = false;
            out{2} = IrNode.empty; % don't add an IrNode to the IR
        end

        function out = visitParm_stmt(thisVisitor, parmStmtNode)
            % create a MsParameter object and add it to the module
            % TODO: print parameter ranges as comments
            parmNode = parmStmtNode.get_child(1);
            parmName = parmNode.get_name();
            defNode = parmNode.get_child(1);
            valGen = AstVisitorIrGenerator(defNode);
            defValTree = valGen.getIrTree();
            thisVisitor.module.addParm(parmName, defValTree);

            out{1} = false;
            out{2} = IrNode.empty; % don't add an IrNode to the IR
        end

        function out = visitBranch(thisVisitor, branchNode)
            % Don't create separate object. Add branch to modules branch list.
            module = thisVisitor.module;
            branchLabel = branchNode.get_name();
            % semantic check:
            % was this branch already defined for this module?
            if module.isBranch(branchLabel)
                error(['Error defining brach: the branch %s was already ',...
                                                              'defined.'],...
                                                                  branchLabel);
            end

            % does the branch have exactly two children?
            if branchNode.get_num_children() ~= 2
                error(['Error defining brach: %s. A branch must be between ',...
                       'exactly two nodes.\n',...
                       'Needs compatible Verilog-A does not allow ', ...
                       'global ground access from within the model. ',...
                       'If you would like to use a probe with reference ',...
                       'to the global ground, please explicitly define ',...
                       'a ground node in your model.'],...
                                                    branchLabel);
            end
            % end semantic check
            [nodeLabel1, nodeLabel2] = branchNode.get_child_names();
            % Add the branch to the module.
            module.addBranch(branchLabel, nodeLabel1, nodeLabel2);
            out{1} = false;
            out{2} = IrNode.empty;
        end

        function out = visitVar_decl_stmt(thisVisitor, declNode)

            out{1} = true;
            out{2} = IrNode.empty;
        end

        function out = visitVar_decl(thisVisitor, varNode)
            % Create MsVariable object and add it to the module.
            varName = varNode.get_name();
            % if the variable has a child, it has been assigned a default value
            if varNode.get_num_children() > 0
                defNode = varNode.get_child(1);
                valGen = AstVisitorIrGenerator(defNode);
                defValTree = valGen.getIrTree();
            else % otherwise set it to zero
                defValTree = IrNodeConstant('real', 0);
            end

            thisVisitor.module.addVar(varName, defValTree);

            out{1} = false;
            out{2} = IrNode.empty;
        end

        function out = visitVar(thisVisitor, varNode)
            % Here varNode can be a parameter or a variable
            module = thisVisitor.module;
            varOrParmName = varNode.get_name();
            out{1} = true;
            if module.isParm(varOrParmName)
                parmObj = module.getParm(varOrParmName);
                out{2} = IrNodeParameter(parmObj);
            elseif module.isVar(varOrParmName)
                varObj = module.getVar(varOrParmName);
                out{2} = IrNodeVariable(varObj);
            else % if this node is neither a parameter or a variable
                error(['The variable or parameter %s was not defined in ',...
                                                            'this module!'],...
                                                                varOrParmName);
            end
        end

        function out = visitContribution(thisVisitor, contribNode)
            out{1} = true;
            out{2} = IrNodeContribution();
        end

        function out = visitAnalog(thisVisitor, analogNode)
            out{1} = true;
            analog = IrNodeAnalog();
            analog.setIndentStr('');
            out{2} = analog;
        end

        function out = visitAnalog_func(thisVisitor, afNode)
            % create an IrNodeAnalogFunction node which is a subclass of the
            % IrNodeModule class.
            out{1} = false;
            module = thisVisitor.module;
            funcName = afNode.get_name();
            afunc = IrNodeAnalogFunction(funcName);
            funcGen = AstVisitorIrGenerator();
            funcGen.module = afunc; % NOTE: this seems a bit ugly
            % Skip the analog_func AST node and traverse its children.
            funcGen.traverseChildren(afNode, afunc);
            module.addFunc(afunc);
            out{2} = afunc;
        end

        function out = visitInput(thisVisitor, inputNode)
            % this will be only used if we  are inside of a function body
            out{1} = true;
            out{2} = IrNode.empty;

            func = thisVisitor.module;
            inputList = inputNode.get_attr('inputs');
            func.setInputList(inputList);
        end

        function out = visitOutput(thisVisitor, outputNode)
            % this will be only used if we  are inside of a function body
            out{1} = true;
            out{1} = true;
            out{2} = IrNode.empty;

            func = thisVisitor.module;
            outputList = outputNode.get_attr('outputs');
            func.setOutputList(outputList);
        end

        function out = visitAssignment(thisVisitor, assgnNode)
            % Create assignment node, traverse further down the tree.
            out{1} = true;
            out{2} = IrNodeAssignment();
        end

        function out = visitIf(thisVisitor, ifNode)
            % create if/else node, traverse further.
            out{1} = true;
            out{2} = IrNodeIfElse();
        end

        function out = visitBlock(thisVisitor, blockNode)
            out{1} = true;
            block = IrNodeBlock();
            block.setIndentStr('');
            out{2} = block;
        end

        function out = visitI(thisVisitor, iNode)
            out = thisVisitor.visitIorV(iNode);
        end

        function out = visitV(thisVisitor, vNode)
            out = thisVisitor.visitIorV(vNode);
        end

        function out = visitIorV(thisVisitor, ivNode)
            out{1} = false;
            module = thisVisitor.module;
            [ioLabel, ioType, nodeLabelList] = AstFunctions.extractIoLabel(ivNode);

            % semantic check:
            % Check if the probe has two nodes or a branch as its input.
            if ivNode.get_num_children() ==  1
                branchName = nodeLabelList{1};
                if module.isBranch(branchName) == false
                    probeStr = [upper(ioType), '(', branchName, ')'];
                    error(['The probe %s has only a single argument and ',...
                           'it is not a branch.\n',...
                           'Needs compatible Verilog-A does not allow ', ...
                           'global ground access from within the model. ',...
                           'If you would like to use a probe with reference ',...
                           'to the global ground, please explicitly define ',...
                           'a ground node in your model.'],...
                                                        probeStr);
                end
            end

            % end semantic check

            % note that addIo only adds a new IO if it isn't already in the
            % module
            ioObj = module.addIo(ioType, nodeLabelList{:});
            % we construct an IrNodeInputOutput object both with its ioObj and
            % ioLabel because the same IO can have different labels (because of
            % branches).
            out{2} = IrNodeInputOutput(ioObj, ioLabel);
        end

        function out = visitOp(thisVisitor, opNode)
            out{1} = true;
            opType = opNode.get_attr('op');
            out{2} = IrNodeOperation(opType);
        end

        function out = visitConst(thisVisitor, constNode)
            out{1} = false;
            dataType = constNode.get_attr('dtype');
            value = constNode.get_attr('value');
            out{2} = IrNodeConstant(dataType, value);
        end

        function out = visitFunc(thisVisitor, funcNode)
            out{1} = true;
            name = funcNode.get_name();
            out{2} = IrNodeFunction(name);
        end

        function out = visitSim_func(thisVisitor, sfNode)
            out{1} = true;
            name = sfNode.get_name();
            out{2} = IrNodeSimulatorFunction(name);
        end

        function out = visitSim_stmt(thisVisitor, ssNode)
            out{1} = true;
            out{2} = IrNodeSimulatorStatement();
        end

        function out = visitSim_var(thisVisitor, svNode)
            error(['Error at: $%s. ',...
                  'MAPP currently does not support simulator variables!'],...
                                                            svNode.get_name());
        end

        function out = visitCase(thisVisitor, caseNode)
            out{1} = true;
            out{2} = IrNodeCase();
        end

        function out = visitCase_item(thisVisitor, ciNode)
            out{1} = true;
            out{2} = IrNodeCaseItem();
        end

        function out = visitCase_candidates(thisVisitor, ccNode)
            out{1} = true;
            irNode = IrNodeCaseCandidates();
            if ccNode.has_attr('is_default', 'True')
                irNode.setDefault();
            end
            out{2} = irNode;
        end

        function out = visitWhile(thisVisitor, whileNode)
            out{1} = true;
            out{2} = IrNodeWhile();
        end

        function out = visitFor(thisVisitor, forNode)
            out{1} = true;
            out{2} = IrNodeFor();
        end

        function irTree = getIrTree(thisVisitor)
            irTree = thisVisitor.irTree;
        end

        function printModSpec(thisVisitor, outFileId)
            thisVisitor.module.fprintAll(outFileId);
        end

        function module = getModule(thisVisitor)
            module = thisVisitor.module;
        end
    end
% end classdef
end
