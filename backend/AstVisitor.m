classdef AstVisitor < handle
% ASTVISITOR visit a node of an abstract syntax tree and run the corresponding
% method
% AstVisitor class is an implementation of the "visitor pattern" that is
% frequently used to traverse tree like structures.
% In a programming language with dynamic dispatch all the visit methods of this
% class would have been just "visit(NodeType)". But MATLAB does not have
% dynamic dispatch and this kind of defeats the purpose of using the visitor
% pattern in the first place. Instead, one could just implement a visit method
% in the AstVisitor class that checks the type of the node in a long case
% statement and calls the appropriate method. Nevertheless, I chose to
% implement this class this way because I like the idea of tree nodes having
% control over what to do when they are visited by a visitor object. Besides
% this way, there is no possibility of adding a new type of tree node and not
% handling it in the visitor. The trick I use in order to circumvent the
% drawback of not having dynamic dispatch goes like this:
%       * Add a property
%           visitMethod
%         to the tree nodes that determines the method to be
%         called when an object of this class is visited by a visitor object.
%       * During the construction of every tree object assign a value to this
%         property using the type of the tree node.
%       * A tree object with the type "root" will hence have the visitMethod
%         "visitRoot" and the AstVisitor will implement the visitRoot method
%         explicitly. After that every visitor class (that is derived from the
%         AstVisitor abstract class) that wants to perform some specific
%         operation when it visits a root node will implement the visitRoot
%         method
%
% See also VAPP_AST_NODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Abstract)
        % use visitGeneric method to perform a default operation for every node
        % that has not a specific visit method in your Visitor class.
        out = visitGeneric(thisVisitor, astNode);
    end

    methods

        function traverseAst(thisVisitor, astRoot)
        % TRAVERSEAST traverse a tree starting with astRoot
        % Call the accept_visitor method of the astRoot and run traverseAst on
        % its children.

            % traverse the tree recursively and visit every node
            nChild = astRoot.get_num_children();

            out = astRoot.accept_visitor(thisVisitor);
            % accept_visitor() can return a cell array as its output (out).
            % the first element of this cell array will indicate if the tree
            % traversal is be continued.

            if iscell(out)
                traverseSub = out{1};
            else
                traverseSub = out;
            end

            if traverseSub == true
                for i=1:nChild
                    thisVisitor.traverseAst(astRoot.get_child(i));
                end
            end

            if astRoot.has_type('root')
                thisVisitor.endTraversal();
            end
        end

        function out = visitRoot(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitModule(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitFunc(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitV(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitI(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitPort(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitOp(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitConst(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitVar(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitAssignment(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitContribution(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitElectrical(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitAliasparam(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitVar_decl_stmt(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitVar_decl(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitParm_stmt(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitParm(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitParm_range(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitParm_interval(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitInf(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitBlock(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitIf(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitCase(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitCase_item(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitCase_candidates(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitSim_var(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitSim_func(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitSim_stmt(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitInput(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitOutput(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitAnalog_func(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitAnalog(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitBranch(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitThermal(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitFor(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitWhile(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function out = visitRepeat(thisVisitor, astNode)
            out = thisVisitor.visitGeneric(astNode);
        end

        function endTraversal(thisVisitor)
            % ENDTRAVERSAL gets called after all children of a root node are
            % traversed
            %
            % overload this method to wrap up a traversal.
            % See AstVisitorContribution class for an example application.
        end
    end


% end classdef
end
