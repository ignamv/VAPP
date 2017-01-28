classdef IrNode < handle & matlab.mixin.Heterogeneous
% IRNODE superclass for the nodes of the intermediate representation tree
%
% Subclasses derived from IrNode have two main functionalities:
%   1. Store information about model objects like IOs, contributions etc.
%   2. Supply an interface to represent the model information contained in this
%   node and its child nodes in printed form, e.g., as MATLAB code.
%
% Subclasses derived from IrNode have their names prefixed with "IrNode"
%
% See also IRVISITOR, IRNODE.SPRINTALL

% NOTE this class has to be derived from matlab.mixin.Heterogeneous.
% Otherwise, we cannot bundle all the sub-classes derived from IrNode into
% a tree because childVec property is a regular array -> not a cell array.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties (Access = protected)
        childVec = IrNode.empty; % hold a list of children here
        parent = IrNode.empty;   % pointer to the parent
        nChild = 0;              % number of children
        visitMethod;             % used by IrVisitor objects
        name = '';
        indentStr = '';          % indent string 
        tabStr = '    ';         % tab string
        % The difference between indentStr and tabStr is the following:
        % indentStr is the main property that is used when indenting node
        % outputs, e.g., for printing the ModSpec model. It is by default set
        % to be equal to the tabStr. The reason we have tabStr is the plan to
        % offer this property as a configuration parameter at the user
        % interface. This way one can switch between tabs/spaces and set how
        % wide the spaces should be.
    end

    methods

        function obj = IrNode()
            obj.indentStr = obj.tabStr;
            nodeType = class(obj);
            obj.visitMethod = eval(['@visit', nodeType]);
        end

        function out = acceptVisitor(thisNode, visitor, varargin)
        % ACCEPTVISITOR call the appropriate visit method of the visitor
        % For an explanation of the design involving the visitor pattern please
        % see the ASTVISITOR

            out = thisNode.visitMethod(visitor, thisNode, varargin{:});
        end

        function out = hasType(thisNode, irType)
            out = any(strcmp(class(thisNode), irType));
        end

        function setParent(thisNode, parentNode)
            thisNode.parent = parentNode;
        end

        function addChild(thisNode, childNode)
            thisNode.childVec = [thisNode.childVec, childNode];
            thisNode.nChild = thisNode.nChild + 1;
        end

        function nChild = getNChild(thisNode)
            nChild = thisNode.nChild;
        end

        function childNode = getChild(thisNode, childIdx)
            childNode = thisNode.childVec(childIdx);
        end

        function parentNode = getParent(thisNode)
            parentNode = thisNode.parent;
        end

        function modelNode = getModel(thisNode)
            modelNode = thisNode;
            while (isa(modelNode, 'Model') == false) && ...
                                                (isempty(modelNode) == false)
                modelNode = modelNode.parent;
            end
        end

        function name = getName(thisNode)
            name = thisNode.name;
        end

        function setName(thisNode, name)
            thisNode.name = name;
        end

        function out = hasName(thisNode, name)
            out = strcmp(thisNode.name, name);
        end

        function setIndentStr(thisNode, istr)
            thisNode.indentStr = istr;
        end

        function printSub = fprintAll(thisNode, outFileId)
        % FPRINTALL print an m-code representation of this node to a file
        % See also IRNODE.SPRINTALL
            [outStr, printSub] = thisNode.sprintAll();
            outStr = thisNode.convertDelimiters(outStr);
            fprintf(outFileId, outStr);
        end

        % The methods below are used to generate a printed version of the
        % ModSpec model in form of a MATLAB file.

        function [outStr, printSub] = sprintAll(thisNode)
        % SPRINTALL print the m-code represantation of this node
        % See also IRNODE.SPRINTFRONT IRNODE.SPRINTBACK
        
            % We are going to break the print function of the node into
            % multiple sub-parts. The reason: we want to give greater control
            % to the subclassses.
            [outStr, printSub] = thisNode.sprintFront();
            if printSub == true
                outStr = [outStr, thisNode.sprintChildren()];
            end
            outStr = sprintf([outStr, thisNode.sprintBack()]);
        end

        function outStr = sprintChildren(thisNode)
            outStr = '';
            for i=1:thisNode.nChild
                outStr = [outStr, thisNode.sprintChild(i)];
            end
        end

        function outStr = sprintChild(thisNode, childIdx)
            childNode = thisNode.childVec(childIdx);
            outStr = thisNode.sprintfIndent(childNode.sprintAll());
        end

        function [outStr, printSub] = sprintFront(thisNode)
        % SPRINTFRONT print the front portion of this node
        % The front portion of this node comes before the printed version of
        % its children and is followed by the back portion after all children's
        % print methods are called. For instance, the IrNodeModule class prints
        % all the information contained in the module and it's children here
        % and prints book keeping/wrap-up related stuff in sprintBack.
        % See also IRNODE.SPRINTBACK
            
            % generic print function
            % This function is intentionally left blank for subclasses to
            % override.
            printSub = true;
            outStr = '';
        end

        function outStr = sprintBack(thisNode)
        % SPRINTBACK print book keeping and wrap-up related parts of the node
        % See also IRNODE.SPRINTFRONT

            % generic print function
            % This function is intentionally left blank
            outStr = '';
        end
        
        function outStr = sprintfIndent(thisNode, inStr)
            % (?-s:.) means treat . as every character but the new line
            outStr = sprintf(inStr); % in case inStr is not formatted
            % TODO: make sure every input to this function is formatted and
            % remove the line above.
            outStr = regexprep(outStr, '^(?-s:.)*$', [thisNode.indentStr, '$0'], 'lineanchors');
        end

    end

    methods (Static)
        function outStr = convertDelimiters(inStr)
        % CONVERTDELIMITERS convert symbols used internally by VAPP for
        % commenting etc. to MATLAB's delimiters.
        %
        % VAPP needs internal delimiters because it prints IrNodes recursively.
        % If we use the same delimiters as MATLAB, sprintf calls will convert
        % those delimiters. An example: if we use '%' for comments and want to
        % print a comment like '%% ex nihilo quodlibet', this would work fine
        % in the first level
        %   sprintf('%% ex nihilo quodlibet') -> % ex nihilo quodlibet
        % but
        %   sprintf(sprintf('%% ex nihilo quodlibet') -> % ex nihilo quodlibet)
        % results in an empty string!
        %
        % See also IRNODE.FPRINTALL
        
            % internal to VAPP: use
            % // for comments (%)
            % " for a single quote (')
            % ### for a backslash (\)
            outStr = regexprep(inStr, {'//', '"', '###'}, {'%%', '''', '\\\'});
        end
    end
% end classdef
end
