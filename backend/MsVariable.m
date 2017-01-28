classdef MsVariable < handle
% MSVARIABLE represents a variable in a ModSpec model.
%
% Variables keep track of their states in the model, and initialize themselves
% to zero at the beginning of the analog block if they are used before they are
% set.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        name = '';
        used = false;
        initialized = false;
        usedBeforeInit = false;
        valTree = IrNodeNumerical.empty;
    end

    methods
        function obj = MsVariable(varName, valTree)
            obj.name = varName;
            obj.valTree = valTree;
        end

        function varName = getName(thisVar)
            varName = thisVar.name;
        end

        function setInitialized(thisVar)
            if thisVar.initialized == false
                thisVar.initialized = true;
                if thisVar.used == true
                    thisVar.usedBeforeInit = true;
                else
                    thisVar.usedBeforeInit = false;
                end
            end
        end

        function setUsed(thisVar)
            if thisVar.used == false
                thisVar.used = true;
                if thisVar.initialized == true
                    thisVar.usedBeforeInit = false;
                else
                    thisVar.usedBeforeInit = true;
                end
            end
        end

        function out = isUsedBeforeInit(thisVar)
            out = thisVar.usedBeforeInit;
        end

        function varValStr = getValueStr(thisVar)
            varValStr = thisVar.valTree.sprintAll();
        end
    end

end
