classdef IrNodeAnalogFunction < IrNodeModule
% IRNODEANALOGFUNCTION represents Verilog-A analog function
%
% This class is derived from IrNodeModule because it has it's own scope for
% variables. This way we can add MsVariable objects to it and use
% IrNodeModule's functionality for initializing them.
%
% See also IRNODEMODULE

% NOTE: Verilog-A's support for multiple outputs is weird.
% See Agilent Technologies Verilog-A Reference Manual Sec. 2-4
% This is to be investigated in future.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties (Access = private)
        inputList = {};
        outputList = {};
    end

    methods

        function obj = IrNodeAnalogFunction(name)
            obj = obj@IrNodeModule();
            obj.name = name;
            % We add the function name as a variable here. This is useful when
            % no output names are given in the VA code. In this case it is
            % assumed that the output has the same name as the function.
            obj.addVar(name, IrNodeConstant('real', 0));
        end

        function setInputList(thisFunc, inputList)
            thisFunc.inputList = inputList;
        end

        function setOutputList(thisFunc, outputList)
            thisFunc.outputList = outputList;
        end

        function out = isInput(thisFunc, inputName)
            out = any(strcmp(thisFunc.inputList, inputName));
        end

        function out = isOutput(thisFunc, outputName)
            out = any(strcmp(thisFunc.outputList, outputName));
        end

        function [outStr, printSub] = sprintFront(thisFunc)
            printSub = true;

            funcInList = thisFunc.inputList;
            funcOutList = thisFunc.outputList;
            funcName = thisFunc.name;

            if isempty(funcOutList)
                funcOutList = {thisFunc.name};
            end

            numOut = numel(funcOutList); 

            if numOut == 1
                funcOutStr = funcOutList{1};
            else
                funcOutStr = ['[', cell2str_vapp(funcOutList), ']'];
            end

            funcInStr = cell2str_vapp(funcInList);

            outStr = sprintf('function %s = %s(%s)\n', funcOutStr,...
                                                      funcName,...
                                                      funcInStr);

            outStr = [outStr, thisFunc.sprintInitializeVars()];
        end

        function outStr = sprintBack(thisFunc)
            outStr = 'end\n';
        end

        function outStr = sprintInitializeVars(thisFunc)
            varArr = thisFunc.varMap.values;
            nVar = numel(varArr);
            outStr = '';

            for i=1:nVar
                varObj = varArr{i};
                if varObj.isUsedBeforeInit() == true && ...
                                thisFunc.isInput(varObj.getName) == false 
                    outStr = [outStr, sprintf('%s = 0;\n', varObj.getName())];
                end
            end

            if isempty(outStr) == false
                outStr = ['// initializing variables\n', outStr];
            end

            outStr = thisFunc.sprintfIndent(outStr);
        end

    end
end
