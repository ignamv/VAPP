classdef IrNodeSimulatorFunction < IrNodeFunction
% IRNODESIMULATORFUNCTION represents a simulator function in Verilog-A

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = IrNodeSimulatorFunction(name)
            obj = obj@IrNodeFunction(name);
            obj.name = ['sim_', obj.name, '_vapp'];
        end
    end
end
