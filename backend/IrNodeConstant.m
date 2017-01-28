classdef IrNodeConstant < IrNodeNumerical
% IRNODECONSTANT represents a Verilog-A constant

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        dataType = '';
        value = [];
    end

    methods
        function obj = IrNodeConstant(dataType, value)
            obj = obj@IrNodeNumerical();
            obj.dataType = dataType;
            obj.value = value;
        end

        function dataType = getDataType(thisConstant)
            dataType = thisConstant.dataType;
        end

        function out = hasDataType(thisConstant, dataType)
            out = strcmp(thisConstant.dataType, dataType);
        end

        function value = getValue(thisConstant)
            value = thisConstant.value;
        end

        function outStr = sprintNumerical(thisConstant, ~)
            if thisConstant.hasDataType('str')
                % if this constant is a string which contains a new line (\n),
                % we use VAPP's internal symbol for it (###n)
                % for the reason why, plese see IrNode's convertDelimiters
                % method.
                % replace newline with "###n"
                outStr = thisConstant.value;
                outStr = regexprep(outStr, '\n', '###n');
                % replace formatting place-holder "%" with "//"
                % note that "//" will be replaced with "%" again during the
                % file printing process
                outStr = regexprep(outStr, '%', '//'); 
                outStr = ['"', outStr, '"'];
            else
                outStr = num2str(thisConstant.value);
            end
        end
    end

end
