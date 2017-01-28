classdef MsInputOutput < handle & matlab.mixin.Heterogeneous
% MSINPUTOUTPUT represents a ModSpec IO object
%
% An MsInputOutput object has the following main properties
% MsInputOutput is
% * either primary OR internal OR extra
% * lhs (encountered in the LHS of an equation or contribution)
% * rhs (encountered in the RHS of an equation or contribution)
%
% From these properties we can determine the role of an IO in a ModSpec model.
% An IO in ModSpec is
% * either explicit_out OR internal_unk OR other_io
%
% IOs are categorized according to the following table
%
%             Primary                    explicit_out
%             Internal                   internal_unk
% I or v       Extra       LHS   RHS     other_io         has_out_idx?
%
%    i         extra        0     0         other             no -> empty IO
%    i         extra        0     1         int               no -> extra current variable
%    i         extra        1     0         other             no -> special  case (lhs=1, idx=0)
%    i         extra        1     1         int               yes
%    i         internal     0     0         other             no
%    i         internal     0     1         int               no
%    i         internal     1     0         other             yes -> internalCurrentSink
%    i         internal     1     1         int               yes
%    i         primary      0     0         other             no
%    i         primary      0     1         other             no
%    i         primary      1     0         exp               yes
%    i         primary      1     1         int               yes
%    v         extra        0     0         other             no -> empty IO
%    v         extra        0     1         other             no
%    v         extra        1     0         int               yes -> extra voltage variable
%    v         extra        1     1         int               yes
%    v         internal     0     0         other             no
%    v         internal     0     1         int               no
%    v         internal     1     0         int               yes
%    v         internal     1     1         int               yes
%    v         primary      0     0         other             no
%    v         primary      0     1         other             no
%    v         primary      1     0         exp               yes
%    v         primary      1     1         int               yes
%
%
% When IO object print their contributions, they keep track of the status of
% the states of the output vector (fe,fi,qe,qi) and add the contribution to the
% existing value if necessary.
% The same effect could have been achieved be initializing everything to zero
% in the beginning and then adding to this initial value whenever a
% contribution came up. But this creates issues with vecvalder. I think this
% solution is clean enough to be considered a permanent one.
%
% See also MSINPUTOUTPUTINVERSE MSVARIABLE MSPARAMETER 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE:
% construct equations related to explicit current outputs considering the
% following comment (from MNA_EqnEngine_ModSpec)
%
% if an explicit output is of type 'i', this is a branch current; find the
% corresponding node (using NIL.IOnodeNames and NIL.IOtypes), from which
% find the index of the KCL equation for the node, and store it (as
% DAE.cktnetlist.elements{i}.i_explicitOutPut_KCLindices_into_fq(idx2),
% where ExplicitOutputNames(idx2) is the name of the unknown). At eval
% time, the CORRESPONDING EXPLICIT OUTPUT IS ADDED TO THE CIRCUIT KCL'S f
% AND q VECTORS, AND SUBTRACTED FROM THE KCL FOR THE DEVICE'S REFERENCE
% NODE.

    properties (Access = private)
        label = '';
        aliasList = {}; % branches in VA
        nodeLabel1 = '';
        nodeLabel2 = '';
        lhs = false; % IO appears on the LHS of a contribution
        rhs = false; % IO appears on the LHS of a contribution or an assignment
        extra = false; % IO does not have the reference node as the second node
        defIo1 = MsInputOutput.empty % extra IO depends on this IO (first one)
        defIo2 = MsInputOutput.empty % extra IO depends on this IO (second one)
        ioDef = ''; % how to write IO in terms of other IOs (if extra == true)
        ioType = ''; % currently 'v' or 'i'
        primary = false; % IO is primary if it's one of the IOs associated with
                         %the terminals of the model
        internal = false; % if the first node is an internal node and the
                          % second, the reference node
        outIdx = 0; % if explicitOut: what is n in fe[n] for this IO
        initializedF = false; % used for printing in Contribution
        initializedQ = false; % used for printing in Contribution
        inverseIo = MsInputOutputInverse.empty;
        % NOTE: an IO is either primary, internal or extra
        % cannot be two of these things at the same time
        % cannot be non of these things either
        % => one and only one of these three variables is true
    end


    methods

        function obj = MsInputOutput(varargin)

            if nargin > 0
                if (nargin==3)
                    ioType = varargin{1};
                    nodeLabel1 = varargin{2};
                    nodeLabel2 = varargin{3};
                elseif nargin == 1
                    ioNode = varargin{1};
                    ioType = ioNode.get_attr('ioType');
                    nodeLabelList = ioNode.get_attr('nodeLabelList');
                    % NOTE: notice how we assume that the IO node has two
                    % nodes. This is not always the case, e.g., if an IO node
                    % is defined through a branch like V(branchName). But this
                    % is exactly what we don't want -> an IO defined through a
                    % branch should have been created beforehand and the branch
                    % name should have been added as an alias; not as a
                    % nodeLabel.
                    % TLDR: we always expect 2 nodeLabels here.
                    nodeLabel1 = nodeLabelList{1};
                    nodeLabel2 = nodeLabelList{2};
                end

                label = strcat(ioType, nodeLabel1, nodeLabel2);

                obj.nodeLabel1 = nodeLabel1;
                obj.nodeLabel2 = nodeLabel2;
                obj.ioType = ioType;
                obj.label = label;
                obj.inverseIo = MsInputOutputInverse(obj);
            end

        end
        
        function out = isExplicitOut(thisIo)
            out = (thisIo.primary == true) && ...
                  (thisIo.lhs == true) && ...
                  (thisIo.rhs == false);
        end

        function out = isInternalCurrentSink(thisIo)
            out = (thisIo.internal == true) && ...
                  (thisIo.hasType('i') == true) && ...
                  (thisIo.lhs == true) && ...
                  (thisIo.rhs == false);
        end

        function out = isInternalUnk(thisIo)
            if thisIo.primary == true
                out = (thisIo.lhs == true) && ...
                      (thisIo.rhs == true);
            elseif thisIo.internal == true
                if thisIo.hasType('i')
                    out = (thisIo.rhs == true);
                else
                    out = (thisIo.lhs == true) || (thisIo.rhs == true);
                    % this is one of the places where the new concept of
                    % internalVoltageLoop will matter
                    % NOTE: notice how it's the dual of internalCurrentSink
                end
            elseif thisIo.extra == true
                % NOTE: IO can have another type such as PWR (power)
                if thisIo.hasType('i')
                    out = (thisIo.rhs == true);
                elseif thisIo.hasType('v')
                    out = (thisIo.lhs == true);
                end
            else
                out = false;
            end
        end

        function out = hasLabelOrAlias(thisIo, ioName)
            out = (thisIo.hasLabel(ioName) || thisIo.hasAlias(ioName));
        end

        function out = hasLabel(thisIo, label)
           out = strcmp(thisIo.label, label);
        end

        function out = hasAlias(thisIo, ioAlias)
            out = any(strcmp(ioAlias, thisIo.aliasList));
        end

        function setLhs(thisIo)
            thisIo.lhs = true;
            if thisIo.extra == true
                thisIo.notifyDefIos();
            end
        end

        function setRhs(thisIo)
            thisIo.rhs = true;
            if thisIo.extra == true
                thisIo.notifyDefIos();
            end
        end

        function notifyDefIos(thisIo)
            % NOTE: below is a very good example how voltages and currents are
            % dual quantities. We set the lhs flag for currents and the rhs
            % flag for voltages. The software should keep reproducing this dual
            % structure.
            if thisIo.hasType('i')
                thisIo.defIo1.setLhs();
                thisIo.defIo2.setLhs();
            elseif thisIo.hasType('v')
                thisIo.defIo1.setRhs();
                thisIo.defIo2.setRhs();
            end
        end

        function setExtra(thisIo)
            thisIo.extra = true;
        end

        function out = isExtra(thisIo)
            out = thisIo.extra;
        end

        function setPrimary(thisIo)
            thisIo.primary = true;
        end

        function setOutIdx(thisIo, idx)
            thisIo.outIdx = idx;
        end

        function outIdx = getOutIdx(thisIo)
            outIdx = thisIo.outIdx;
        end

        function label = getLabel(thisIo)
            label = thisIo.label;
        end

        function out = isPrimary(thisIo)
            out = thisIo.primary;
        end

        function aList = getAliasList(thisIo)
            aList = thisIo.aliasList;
        end

        function setInternal(thisIo)
            thisIo.internal = true;
        end

        function out = isInternal(thisIo)
            out = thisIo.internal;
        end

        function [defLabel1, defLabel2] = setDef(thisIo, module)
        % SETDEF set defining IOs for an extra IO
        % an extra IO is an IO with none of its nodes equal to the reference
        % node.

            refLabel = module.getRefLabel();
            [defLabel1, defLabel2] = thisIo.getDefLabels(refLabel);
            thisIo.setDefIos(module.getIo(defLabel1), module.getIo(defLabel2));

            if module.isRefLabel(thisIo.nodeLabel1)
                thisIo.ioDef = ['-', defLabel2];
            elseif thisIo.hasType('v') == true
                thisIo.ioDef = [defLabel1, ' - ', defLabel2];
            elseif thisIo.hasType('i') == true
                % if IO is a branch current, we have to write down a KCL for it.
                defIo1 = module.getIo(defLabel1);
                defIo2 = module.getIo(defLabel2);
            end
        end

        function [defLabel1, defLabel2] = getDefLabels(thisIo, refLabel)
            nodeLabel1 = thisIo.nodeLabel1;
            nodeLabel2 = thisIo.nodeLabel2;
            ioType = thisIo.ioType;
            defLabel1 = strcat(ioType, nodeLabel1, refLabel);
            defLabel2 = strcat(ioType, nodeLabel2, refLabel);
        end

        function setDefIos(thisIo, ioObj1, ioObj2)
            thisIo.defIo1 = ioObj1;
            thisIo.defIo2 = ioObj2;
        end

        function [defIo1, defIo2] = getDefIos(thisIo)
            defIo1 = thisIo.defIo1;
            defIo2 = thisIo.defIo2;
        end

        function ioDef = getDef(thisIo)
            ioDef = thisIo.ioDef;
        end

        function ioType = getType(thisIo)
            ioType = thisIo.ioType;
        end

        function out = hasType(thisIo, iot)
            out = strcmp(iot, thisIo.ioType);
        end

        function out = isLhs(thisIo)
            out = thisIo.lhs;
        end

        function out = isRhs(thisIo)
            out = thisIo.rhs;
        end

        function addAlias(thisIo, ioAlias)
            thisIo.aliasList = [thisIo.aliasList; ioAlias];
        end

        function [nl1, nl2] = getNodeLabels(thisIo)
            nl1 = thisIo.nodeLabel1;
            nl2 = thisIo.nodeLabel2;
        end

        function iio = getInverseIo(thisIo)
            iio = thisIo.inverseIo;
        end

        function out = isInverseIo(thisIo)
            if isa(thisIo, 'MsInputOutputInverse')
                out = true;
            else
                out = false;
            end
        end

        function out = isInitializedF(thisIo)
            out = thisIo.initializedF;
        end

        function out = isInitializedQ(thisIo)
            out = thisIo.initializedQ;
        end

        function setInitializedF(thisIo)
            thisIo.initializedF = true;
        end

        function setInitializedQ(thisIo)
            thisIo.initializedQ = true;
        end

        % printing methods

        function outStr = printDef(thisIo)
            outStr = '';
            if (thisIo.extra == true) && (thisIo.isInternalUnk() == false)
                if isempty(thisIo.getDef()) == false
                    %outStr = sprintf('%% extra IO def for %s \n', thisIo.getLabel);
                    outStr = [outStr, sprintf('%s = %s;\n', thisIo.label, ...
                                                                thisIo.ioDef)];
                end
            end

            % does the inverse IO come up on a RHS
            if thisIo.inverseIo.isToDefine() == true
                outStr = [outStr, sprintf('%s = -%s;\n', ...
                                            thisIo.inverseIo.getLabel(), ...
                                            thisIo.label)];
            end
        end

        function outStr = printAlias(thisIo)
            % TODO: don't print if not known to the analog block
            outStr = '';
            if thisIo.isRhs() == true
                if isempty(thisIo.aliasList) == false
                    for j = 1:numel(thisIo.aliasList)
                        outStr = [outStr, sprintf('%s = %s;\n', ...
                                    thisIo.aliasList{j}, thisIo.getLabel())];
                    end
                end
            end
        end

        function outStr = add2F(thisIo, contStr)
            outStr = thisIo.add2Eqn(contStr, 'f');
        end

        function outStr = add2Q(thisIo, contStr)
            outStr = thisIo.add2Eqn(contStr, 'q');
        end

        function outStr = add2Eqn(thisIo, contStr, fOrQ)
            if thisIo.isExplicitOut() == false && ...
               thisIo.isInternalUnk() == false  && ...
               thisIo.isInternalCurrentSink() == false

                % TODO: the above if condition should be replaced with a
                % positive condition, i.e., with a "== true"

               % this case is for current IOs with two internal nodes

                    [defIo1, defIo2] = thisIo.getDefIos();


                    % notice how thisIo.hasType('i') == true must be true
                    % if an IO of type 'v' is a lhs IO then it is necessarily a
                    % variable, i.e., explicit_out or internal_unk
                    % IO is extra IO -> double contribution

                    outStr = defIo1.add2Eqn(contStr, fOrQ);
                    contStrNeg = ['(-', contStr, ')'];
                    outStr = [outStr, '\n', defIo2.add2Eqn(contStrNeg, fOrQ)];
            else
                if thisIo.isExplicitOut() == true
                    outType = 'e';
                elseif thisIo.isInternalUnk() == true || ...
                        thisIo.isInternalCurrentSink() == true
                    outType = 'i';
                else
                    error('There is no equation for this IO (%s)!', thisIo.label);
                end
                lhsStr = [fOrQ, outType, sprintf('(%d,1)', thisIo.outIdx)];
                outStr = [lhsStr, ' = '];

                if strcmp(fOrQ, 'f')
                    initialized = thisIo.initializedF;
                else
                    initialized = thisIo.initializedQ;
                end

                if initialized
                    outStr = [outStr, lhsStr, ' + '];
                else
                    if strcmp(fOrQ, 'f')
                        thisIo.setInitializedF();
                    else
                        thisIo.setInitializedQ();
                    end
                end
                outStr = [outStr, sprintf('%s;', contStr)];
            end
        end

        function [kclStr, kvlStr] = printKclKvl(thisIo, kvlIdx)
            ioLabel = thisIo.label;
            kclStr = '';
            kvlStr = '';

            if thisIo.isInternalUnk() == true && thisIo.extra == true
                if thisIo.hasType('i') == true

                    kclStr = [kclStr, '// kcl equation for ', ioLabel,  '\n'];
                    [defIo1, defIo2] = thisIo.getDefIos();
                    kclStr = [kclStr, defIo1.add2F(ioLabel), '\n'];

                    kclStr = [kclStr, defIo2.add2F(sprintf('(-%s)', ioLabel)), '\n'];

                elseif thisIo.hasType('v')
                    kvlStr = [kvlStr, '// kvl equation for ', ioLabel, '\n'];
                    kvlStr = [kvlStr, sprintf(['fi(%d,1) = %s - (%s);\n',...
                                               'qi(%d,1) = 0;\n'],...
                                                            kvlIdx,...
                                                            ioLabel,...
                                                            thisIo.getDef(),...
                                                            kvlIdx)];
                end
            end
        end

        function outStr = printFinalize(thisIo)
            outStr = '';
            if thisIo.isInternalUnk() == true && thisIo.lhs == true
                if thisIo.hasType('v')
                    outStr = [outStr, thisIo.add2F(sprintf('(-%s)',...
                                                         thisIo.label)), '\n'];
                else
                    outStr = [outStr, thisIo.add2F(sprintf('%s',...
                                                         thisIo.label)), '\n'];
                end
            end

            if thisIo.outIdx ~= 0
                if thisIo.initializedF == false
                    outStr = [outStr, thisIo.add2F('0'), '\n'];
                end

                if thisIo.initializedQ == false
                    outStr = [outStr, thisIo.add2Q('0'), '\n'];
                end
            end
        end


    % end methods
    end

    methods (Sealed)
        % the empty() checks below allows us to use all() and any() methods
        % with vectors.
        % all(ioVec ~= someIo) then add someIo to ioVec
        % this works because all([]) returns true
        function out = eq(thisIo, otherIo)
            if isempty(thisIo) || isempty(otherIo)
                out = [];
            else
                if isa(thisIo, 'MsInputOutputInverse')
                    thisIo = thisIo.getOriginIo();
                end
                if isa(otherIo, 'MsInputOutputInverse')
                    otherIo = otherIo.getOriginIo();
                end
                out = eq@handle(thisIo, otherIo);
            end
        end

        function out = ne(thisIo, otherIo)
            out = ~(thisIo == otherIo);
        end
    end
    methods (Static)

        function [foundIo, ioIdx] = getIoInIoVec(ioVec, label)
        % GETIOINIOVEC find IO in a vector of IOs with its label
        % The important thing about the behavior of this function is the
        % following:
        % We no only check the IOs themselves but their inverse IOs as well. If
        % we find the label in the inverse, we return a pointer to the inverse
        % IO.

            foundIo = MsInputOutput.empty;
            iter = 1;
            nEl = numel(ioVec);
            while isempty(foundIo) && (iter <= nEl)
                nextIo = ioVec(iter);
                if nextIo.hasLabelOrAlias(label);
                    foundIo = nextIo;
                elseif nextIo.getInverseIo().hasLabelOrAlias(label)
                    foundIo = nextIo.getInverseIo();
                end
                iter = iter + 1;
            end
            ioIdx = iter-1;
        end
    end

% end classdef
end
