classdef IrNodeWhile < IrNode
% IRNODEWHILE represents a while loop in Verilog-A

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function [outStr, traverseSub] = sprintFront(thisNode)
        % SPRINTFRONT
            traverseSub = false;

            % this node has always two children

            condNode = thisNode.getChild(1);
            blockNode = thisNode.getChild(2);

            outStr = ['while ', condNode.sprintAll(), '\n'];
            blockStr = blockNode.sprintAll();
            outStr = [outStr, thisNode.sprintfIndent(blockStr)];
            outStr = [outStr, 'end\n'];
        end
    % end methods
    end
% end classdef
end
