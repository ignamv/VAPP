classdef IrNodeCaseItem < IrNode
% IRNODECASEITEM represents a Verilog-A case item

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function [outStr, traverseSub] = sprintFront(thisNode)
        % SPRINTFRONT
            traverseSub = false;

            nChild = thisNode.getNChild();

            % this node has always 2 children
            candidatesNode = thisNode.getChild(1);
            caseBlockNode = thisNode.getChild(2);

            if candidatesNode.isDefault == false
                outStr = 'case ';
            else
                outStr = 'otherwise ';
            end

            outStr = [outStr, candidatesNode.sprintAll(), '\n'];
            blockStr = caseBlockNode.sprintAll();
            outStr = [outStr, thisNode.sprintfIndent(blockStr)];
        end
    % end methods
    end
    
% end classdef
end
