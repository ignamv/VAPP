classdef MsParameter < handle
% MSPARAMETER represents a parameter in a ModSpec model
%
% Parameter names can be augmented with a prefix. The rationale behind this is
% that we don't want to force the user to check the Verilog-A model for
% reserved MATLAB keywords. "type" is a common example which, if used as a
% parameter, will create problems in ModSpec.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties (Access = private)
        name = '';
        valTree = IrNodeNumerical.empty;
        % The valTree defines the default value of this parameter.
        % valTree is an IR tree. The reason we don't use a simple constant here
        % is that the default value of a parameter can be given with a math
        % expression such as 2*1e-3.
        parmPrefix = 'parm_';
        % this prefix is used wherever a parameter object is encountered in the
        % code.
        range = '';
    end

    methods
        function obj = MsParameter(parmName, valTree)
            obj.name = parmName;
            obj.valTree = valTree;
        end

        function parmName = getName(thisParm)
            parmName = [thisParm.parmPrefix, thisParm.name];
        end

        function parmValStr = getValueStr(thisParm)
            parmValStr = thisParm.valTree.sprintAll();
        end
    end

end
