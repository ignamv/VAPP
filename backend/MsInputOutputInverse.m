classdef MsInputOutputInverse < MsInputOutput
% MSINPUTOUTPUTINVERSE represents the inverse of an MsInputOutput
%
% What is an inverse IO:
% If vpn is the voltage between the positive and the negative node of a
% resistor, vnp is its inverse.
%
% Why do we need inverse IOs?
% Because inverse IOs don't carry extra information that isn't already carried
% by the IO itself. That means if we encounter them in the model, we must not
% treat them as new outputs and unknowns.
%
% The MsInputOutputInverse IO object is tightly coupled with its regular IO. In
% fact, to all the queries from outside, it acts like the regular IO itself.
% The only thing it does differently is when we supply a contribution to an
% inverse IO, it prints this contribution with a minus sign in front.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        originIo = MsInputOutput.empty;
        label = '';
        aliasList = {}; % can have different aliases than the regular IO
        toDefine = false; % do we print out the definition of this inverse IO?
    end

    methods

        function obj = MsInputOutputInverse(originIo)
            ioType = originIo.getType();
            [nodeLabel1, nodeLabel2] = originIo.getNodeLabels();
            obj.originIo = originIo;
            obj.label = [ioType, nodeLabel2, nodeLabel1];
        end

        % converter method
        % function obj = InputOutput(thisIo)
        %     obj = thisIo.originIo;
        % end
        %

        function originIo = getOriginIo(thisIo)
        % GETORIGINIO
            originIo = thisIo.originIo;
        end

        function out = isToDefine(thisIo)
            out = thisIo.toDefine;
        end

        function out = isExplicitOut(thisIo)
            out = thisIo.originIo.isExplicitOut();
        end

        function out = isInternalCurrentSink(thisIo)
            out = thisIo.originIo.isInternalCurrentSink();
        end

        function out = isInternalUnk(thisIo)
            out = thisIo.originIo.isInternalUnk();
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
            thisIo.originIo.setLhs();
        end

        function setRhs(thisIo)
            thisIo.toDefine = true;
            thisIo.originIo.setRhs();
        end

        function notifyDefIos(thisIo)
            thisIo.originIo.notifyDefIos();
        end

        function setExtra(thisIo)
            thisIo.originIo.setExtra();
        end

        function out = isExtra(thisIo)
            out = thisIo.originIo.isExtra();
        end

        function setPrimary(thisIo)
            thisIo.originIo.setPrimary();
        end

        function setOutIdx(thisIo, idx)
            thisIo.originIo.setOutIdx(idx);
        end

        function outIdx = getOutIdx(thisIo)
            outIdx = thisIo.originIo.getOutIdx();
        end

        function label = getLabel(thisIo)
            label = thisIo.label;
        end

        function out = isPrimary(thisIo)
            out = thisIo.originIo.isPrimary();
        end

        function aList = getAliasList(thisIo)
            aList = thisIo.aliasList;
        end

        function setInternal(thisIo)
            thisIo.originIo.setInternal();
        end

        function out = isInternal(thisIo)
            out = thisIo.originIo.isInternal();
        end

        function [defLabel1, defLabel2] = setDef(thisIo, module)
            % TODO: this function is to be removed. It should be never getting
            % called. Reason: setDef is only called when an IO is created. If
            % we create an extra IO, that means we are encountering it for the
            % first time, and hence, we set it as a "non inverseIo". The
            % corresponding inverseIo is created along with it.
            [defLabel1, defLabel2] = thisIo.originIo.setDef(module);
        end

        function [defLabel1, defLabel2] = getDefLabels(thisIo, refLabel)
            [defLabel1, defLabel2] = thisIo.originIo.getDefLabels(refLabel);
        end

        function setDefIos(thisIo, ioObj1, ioObj2)
            thisIo.originIo.setDefIos(ioObj1, ioObj2);
        end

        function [defIo1, defIo2] = getDefIos(thisIo)
            [defIo1, defIo2] = thisIo.originIo.getDefIos();
        end

        function ioDef = getDef(thisIo)
            ioDef = thisIo.originIo.getDef();
        end

        function ioType = getType(thisIo)
            ioType = thisIo.originIo.getType();
        end

        function out = hasType(thisIo, iot)
            out = thisIo.originIo.hasType(iot);
        end

        function out = isLhs(thisIo)
            out = thisIo.originIo.isLhs();
        end

        function out = isRhs(thisIo)
            out = thisIo.originIo.isRhs();
        end

        function addAlias(thisIo, ioAlias)
            thisIo.aliasList = [thisIo.aliasList; ioAlias];
        end

        function out = isInitializedF(thisIo)
            out = thisIo.originIo.isInitializedF();
        end

        function out = isInitializedQ(thisIo)
            out = thisIo.originIo.isInitializedQ();
        end

        function setInitializedF(thisIo)
            thisIo.originIo.setInitializedF();
        end

        function setInitializedQ(thisIo)
            thisIo.originIo.setInitializedQ();
        end

        % printing methods
        % this is where the InputOutputInverse class will shine

        function outStr = printDef(thisIo)
            outStr = '';
            if (thisIo.isExtra() == true)
                if isempty(thisIo.getDef()) == false
                    %outStr = sprintf('%% extra IO def for %s \n', thisIo.getLabel);
                    outStr = [outStr, sprintf('%s = -%s;\n', ...
                                                thisIo.getLabel(), ...
                                                thisIo.originIo.getLabel())];
                end
            end
        end

        function outStr = printAlias(thisIo)
            % TODO: don't print if not known to the sim
            outStr = '';
            if thisIo.isRhs() == true
                if isempty(thisIo.aliasList) == false
                    for j = 1:numel(thisIo.aliasList)
                        %outStr = [outStr, '\n', '%% alias def \n'];
                        outStr = [outStr, sprintf('%s = %s;\n', ...
                                    thisIo.aliasList{j}, thisIo.getLabel())];
                    end
                end
            end
        end

        function outStr = add2F(thisIo, contStr)
            contStr = ['(-(', contStr, '))'];
            outStr = thisIo.originIo.add2Eqn(contStr, 'f');
        end

        function outStr = add2Q(thisIo, contStr)
            contStr = ['(-(', contStr, '))'];
            outStr = thisIo.originIo.add2Eqn(contStr, 'q');
        end

        function [kclStr, kvlStr] = printKclKvl(thisIo, kvlIdx)
            kclStr = '';
            kvlStr = '';
        end

        function outStr = printFinalize(thisIo)
            outStr = '';
        end

    % end methods
    end

% end classdef
end
