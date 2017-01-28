classdef IrNodeModule < IrNode
% IRNODEMODULE represents a module in Verilog-A and serves as the main data
% class of a model representation in VAPP.
%
% Modules include four important classes of objects:
% 1. IOs (MsInputOutput)
% 2. Variables (MsVariable)
% 3. Parameters (MsParameter)
% 4, Analog functions (IrNodeAnalogFunction)
%
% The Ms prefix for the above objects signifies that they are ModSpec objects
% rather than Verilog-A objects (which are represented in the IR tree).
% Analog functions are an exception to this and are stored in the module
% because they are separated from other parts of the model code. They are
% printed separately at the very end as MATLAB functions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties (Access = protected)
        terminalList = {};      % list of terminals (strings)
        nodeList = {};          % list of nodes (strings)
        internalNodeList = {};  % list of nodes that are not terminals (strings)
        internalUnkList = {};   % list of internal unknowns (strings)
        explicitOutList = {};   % list of explicit outputs (strings)
        branchList = {};        % list of branches (strings)
        refLabel = '';          % label of the reference node (string)

        % IO related properties
        ioVec = MsInputOutput.empty;
        % NOTE: ioVec is not a Map object like the variables and parameters but
        % a vector. The reason for that is my method of representing "inverse"
        % IOs. These "inverse" IO objects (e.g., vnp is the inverse of vpn)
        % are contained in the primary IO objects (vpn in the above example) as
        % separate but dependent objects (see the IrNodeInputOutputInverse
        % class). If we were to hold them in a Map object, this relationship of
        % primary and inverse IOs could not be preserved.
        varMap = containers.Map;
        parmMap = containers.Map;
        funcMap = containers.Map;
        % note that contrary to vars and parms funcs are not ModSpec objects.
        % They are IrNode objects.
        nTerminal = 0;	    % number of terminals
        nIo = 0;            % number of IOs
        nFeQe = 0;          %
        nImplicitEqn = 0;   % number of implicitly defined equations
        nImplicitOut = 0;   % number of IOs that are internal unknowns and that
                            % receive and outIdx.
    end

    methods
        function obj = IrNodeModule(name, terminalList)
            obj = obj@IrNode();
            if nargin > 0
                obj.name = name;
                obj.setTerminalList(terminalList);
            end
            obj.varMap = containers.Map();
            obj.parmMap = containers.Map();
            obj.funcMap = containers.Map();
        end

        function setTerminalList(thisModule, terminalList)
            nTerminal = numel(terminalList);

            thisModule.terminalList = terminalList;
            thisModule.nTerminal = nTerminal;
            % reference node is the last terminal
            thisModule.refLabel = terminalList{nTerminal};

            % add voltage IOs
            terminalList = setdiff(terminalList, thisModule.refLabel, 'stable');
            for i=1:nTerminal-1
                io = thisModule.addIo('v', terminalList{i}, thisModule.refLabel);
                io.setPrimary();
            end

            % add current IOs
            for i=1:nTerminal-1
                io = thisModule.addIo('i', terminalList{i}, thisModule.refLabel);
                io.setPrimary();
            end
        end

        function terminalList = getTerminalList(thisModule)
            terminalList = thisModule.terminalList;
        end

        function setNodeList(thisModule, nodeList)
            thisModule.nodeList = nodeList;
            internalNodeList = setdiff(nodeList, thisModule.terminalList);
            thisModule.internalNodeList = internalNodeList;
            nIntNode = numel(internalNodeList);

            % add voltage and current IOs for internal nodes.
            for i=1:nIntNode
                io = thisModule.addIo('v', internalNodeList{i}, thisModule.refLabel);
                io.setInternal();
                io = thisModule.addIo('i', internalNodeList{i}, thisModule.refLabel);
                io.setInternal();
            end
        end

        function addBranch(thisModule, branchLabel, nodeLabel1, nodeLabel2)

            if thisModule.isBranch(branchLabel) == false

                thisModule.branchList = [thisModule.branchList, branchLabel];
                % branches are aliases to IOs

                ioV = thisModule.addIo('v', nodeLabel1, nodeLabel2);
                ioI = thisModule.addIo('i', nodeLabel1, nodeLabel2);

                ioVAlias = strcat('v', branchLabel);
                ioIAlias = strcat('i', branchLabel);

                % ATTENTION: there is nothing here to prevent to add and alias that
                % is also the alias of another IO
                ioV.addAlias(ioVAlias);
                ioI.addAlias(ioIAlias);
            end
        end

        function out = isBranch(thisModule, branchLabel)
            out = any(strcmp(thisModule.branchList, branchLabel));
        end

        function [io, ioIdx] = getIo(thisModule, ioLabel)
        % GETIO get the IO with ioLabel in the list of IOs.
        % this function returns the MsInputOutput object and its index.
        % ioLabel can be the inverse of another label, e.g., vpn and vnp. This
        % function will return the inverse IO in that case.
        % See the MsInputOutput class for the definition of an inverseIo.

            [io, ioIdx] = MsInputOutput.getIoInIoVec(thisModule.ioVec, ioLabel);
        end

        function ioObj = addIoNode(thisModule, ioNode)
            ioLabel = AstFunctions.extractIoLabel(ioNode);
            ioObj = thisModule.getIo(ioLabel); % do we have the IO already in there?
            if isempty(ioObj) == true % if no
                % construct new IO object
                ioObj = MsInputOutput(ioNode);
                % add IO object to module
                thisModule.addIoObj(ioObj);
            end
        end

        function ioObj = addIo(thisModule, ioType, varargin)
            % varargin has either 1 or 2 elements.
            % 1 element, if the IO is given by a branch
            % 2 elements, if the IO is given by its nodes
            ioLabel = strcat(ioType, varargin{:});
            ioObj = thisModule.getIo(ioLabel); % do we have the IO already in there?
            if isempty(ioObj) == true % if no
                % Construct new IO object
                % Note that in this case the IO must have been given by its two
                % nodes. Otherwise we would have included it along with its
                % branch in the IO list when we have visited the branch
                % statements in the beginning of the VA module.
                nodeLabel1 = varargin{1};
                nodeLabel2 = varargin{2};
                ioObj = MsInputOutput(ioType, nodeLabel1, nodeLabel2);
                % add IO object to module
                thisModule.addIoObj(ioObj);
            end
        end

        function assignIoIdx(thisModule)
        % ASSIGNIOIDX assigns the indices to IOs which will be occupied by them
        % in the fe,fi,qe,qi vectors of the ModSpec model.

            % keep track of the index counters below and increase them by one
            % for each IO.
            expIdx = 1; % counter for explicit IOs (fe,qe)
            impIdx = 1; % counter for implicit IOs (fi, qi)

            % explicit IOs always get an output index.
            % internal unknowns might or might not get one -> the test for this
            % is: either the IO is an internal unknown and comes up at the lhs
            % of a contribution or it is and internal current sink.
            % NOTE: room for optimization ->
            % We might get away with not giving an internal current sink an
            % output index if its two defIos are already internal_unks.
        
            for i = 1:thisModule.nIo
                io = thisModule.ioVec(i);
                if io.isExplicitOut() == true
                    io.setOutIdx(expIdx);
                    expIdx = expIdx + 1;
                elseif (io.isInternalUnk() == true && io.isLhs() == true) ||...
                        io.isInternalCurrentSink() == true
                    io.setOutIdx(impIdx);
                    impIdx = impIdx + 1;
                end
            end

            thisModule.nFeQe = expIdx-1;
            thisModule.nImplicitOut = impIdx-1;
        end

        function out = isRefLabel(thisModule, nodeLabel)
            out = strcmp(thisModule.refLabel, nodeLabel);
        end

        function n = getNFeQe(thisModule)
            n = thisModule.nFeQe;
        end

        function n = getNFiQi(thisModule)
            n = thisModule.nImplicitOut + thisModule.nImplicitEqn;
        end

        function incNImplicitEqn(thisModule)
            thisModule.nImplicitEqn = thisModule.nImplicitEqn + 1;
        end

        function refLabel = getRefLabel(thisModule)
            refLabel = thisModule.refLabel;
        end

        % Don't print function definitions in the module body.
        % We will do it  later at the end.
        function outStr = sprintChild(thisNode, childIdx)
            childNode = thisNode.childVec(childIdx);
            if isa(childNode, 'IrNodeAnalogFunction')
                outStr = '';
            else
                outStr = sprintChild@IrNode(thisNode, childIdx);
            end
        end

        function [outStr, printSub] = sprintFront(thisModule)
            printSub = true;
            templateFileName = 'module.templ';
            templateText = fileread(templateFileName);
            expVarInfoStr = '\n';
            intVarInfoStr = '\n';

            explicitOutList = {};
            internalUnkList = {};
            for i=1:thisModule.nIo
                io = thisModule.ioVec(i);

                % populate explicit_out and internal_unk lists
                if io.isExplicitOut()
                    expVarInfoStr = [expVarInfoStr, thisModule.indentStr,...
                                            sprintf(['// variable name: %s, ',...
                                                       'equation index: %d\n'],...
                                                                 io.getLabel(),...
                                                                 io.getOutIdx())];
                    explicitOutList = [explicitOutList, io.getLabel()];
                elseif io.isInternalUnk() == true
                    intVarInfoStr = [intVarInfoStr, thisModule.indentStr,...
                                            sprintf(['// variable name: %s, ',...
                                                       'equation index: %d\n'],...
                                                                 io.getLabel(),...
                                                                 io.getOutIdx())];
                    internalUnkList = [internalUnkList, io.getLabel()];
                end
            end

            % populate the parameter list, along with their default values.
            % TODO: print ranges here as comments.
            parmArr = thisModule.parmMap.values;
            nParm = numel(parmArr);
            for i=1:nParm
                parmObj = parmArr{i};
                parmList{2*i-1} = ['''', parmObj.getName(), ''''];
                parmList{2*i} = parmObj.getValueStr();
            end

            % fill in the placeholders in the module template
            templStr = sprintf(templateText, ...
                                    thisModule.name(), ...
                                    thisModule.name(), ...
                                    cell2str_vapp(thisModule.terminalList, ''''),...
                                    expVarInfoStr,...
                                    intVarInfoStr,...
                                    cell2str_vapp(explicitOutList, ''''),...
                                    cell2str_vapp(internalUnkList, ''''),...
                                    cell2str_vapp(parmList, [], 2, 42));


            outStr = '';

            % initialize variables (set them to zero if not initialized in the
            % actual module code)
            outStr = [outStr, thisModule.sprintInitializeVars()];

            % print IO aliases defined by branches
            outStr = [outStr, '// printing IO aliases\n'];
            for i = 1:thisModule.nIo
                io = thisModule.ioVec(i);
                defStr = io.printDef();
                aliasStr = io.printAlias();

                    outStr = [outStr, defStr];
                    outStr = [outStr, aliasStr];
            end

            % print math stuff
            outStr = [outStr, '// module body\n'];
            outStr = [templStr, thisModule.sprintfIndent(outStr)];

        end

        function outStr = sprintBack(thisModule)
            outStr = '';
            outStr = [outStr, '\n', '// module back \n'];

            % KCL, KVL equations
            for i = 1:thisModule.nIo
                kvlIdx = thisModule.getNFiQi() + 1;
                io = thisModule.ioVec(i);
                ioLabel = io.getLabel();
                [kcl, kvl] = io.printKclKvl(kvlIdx);

                if isempty(kcl) == false
                    outStr = [outStr, kcl];
                elseif isempty(kvl) == false
                    outStr = [outStr, kvl];
                    thisModule.nImplicitEqn = thisModule.nImplicitEqn + 1;
                end
            end

            outStr = [outStr, '\n', '// module finishing\n'];

            % here we set all unset values in fe,qe,fi,qi to zero and print
            % KCL/KVL equations for internal unknowns.
            for i = 1:thisModule.nIo
                io = thisModule.ioVec(i);
                finalizeStr = io.printFinalize();
                if isempty(finalizeStr) == false
                    outStr = sprintf([outStr, finalizeStr]);
                end

            end

            % set fe,qe and fi,qi to empty vectors if they are not used at all.
            if thisModule.getNFeQe() ==  0
                outStr = [outStr, 'fe = [];\n'];
                outStr = [outStr, 'qe = [];\n'];
            end

            if thisModule.getNFiQi() ==  0
                outStr = [outStr, 'fi = [];\n', 'qi = [];\n'];
            end

            outStr = [thisModule.sprintfIndent(outStr), 'end'];

            % print Verilog-A analog functions
            funcArr = thisModule.funcMap.values;
            nFunc = numel(funcArr);
            for i = 1:nFunc
                outStr = [outStr, '\n\n', funcArr{i}.sprintAll()];
            end
        end

        function outStr = sprintInitializeVars(thisModule)
        % SPRINTINITIALIZEVARS set a variable to zero if it is not initialized
        % by the module at all, i.e., it is used before it is being set.
            varArr = thisModule.varMap.values;
            nVar = numel(varArr);
            outStr = '';

            for i=1:nVar
                varObj = varArr{i};
                if varObj.isUsedBeforeInit() == true
                    outStr = [outStr, sprintf('%s = %s;\n', ...
                                                        varObj.getName(),...
                                                        varObj.getValueStr())];
                end
            end

            if isempty(outStr) == false
                outStr = ['// initializing variables\n', outStr];
            end
        end

        function addVar(thisModule, varName, defValTree)
            if thisModule.isVar(varName) == false
                thisModule.varMap(varName) = MsVariable(varName, defValTree);
            end
        end

        function msVar = getVar(thisModule, varName)
            msVar = MsVariable.empty;
            if thisModule.isVar(varName) == true
                msVar = thisModule.varMap(varName);
            end
        end

        function out = isVar(thisModule,  varName)
            out =  thisModule.varMap.isKey(varName);
        end

        function addParm(thisModule, parmName, defVal)
            if thisModule.isParm(parmName) == false
                thisModule.parmMap(parmName) = MsParameter(parmName, defVal);
            end
        end

        function msParm = getParm(thisModule, parmName)
            msParm = MsParameter.empty;
            if thisModule.isParm(parmName)
                msParm = thisModule.parmMap(parmName);
            end
        end

        function addFunc(thisModule, funcNode)
            funcName = funcNode.getName;
            if thisModule.isFunc(funcNode.getName) == false
                thisModule.funcMap(funcName) = funcNode;
            end
        end

        function out = isFunc(thisModule, funcName)
            out = thisModule.funcMap.isKey(funcName);
        end

        function out = isParm(thisModule, parmName)
            out = thisModule.parmMap.isKey(parmName);
        end

        function nIo = getNIo(thisModule)
            nIo = thisModule.nIo;
        end

        function ioVec = getIoVec(thisModule)
            ioVec = thisModule.ioVec;
        end

    % end methods
    end

    methods (Static)
        function outStr = addImplicitEqn(eqnIdx, rhsStr)
            outStr = sprintf('fi(%d,1) = %s;\nqi(%d,1) = 0;', eqnIdx,...
                                                              rhsStr,...
                                                              eqnIdx);
        end
    end

    methods (Access = private)

        function addIoObj(thisModule, ioObj)
            % called by addIO
            if all(thisModule.ioVec ~= ioObj)
                thisModule.ioVec = [thisModule.ioVec; ioObj];
                thisModule.nIo = thisModule.nIo + 1;
                thisModule.setIoAttrs(ioObj);
            end
        end

        function setIoAttrs(thisModule, ioObj)
            % this function sets the properties of IOs that can be known at the
            % time they are added to the module
            [nodeLabel1, nodeLabel2] = ioObj.getNodeLabels();

            % if the second node is not the ref node this IO is extra
            % note: this is never true for IOs that are added at the beginning
            % when we are creating the terminal and internalNode lists
            if thisModule.isRefLabel(nodeLabel2) == false
                ioObj.setExtra();
                ioObj.setDef(thisModule);
            end
        end

    end
end
