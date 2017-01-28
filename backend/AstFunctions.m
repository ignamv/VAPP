classdef AstFunctions
% ASTFUNCTIONS extract information and manipulate abstract syntax trees

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)

        function [ioLabel, ioType, nodeLabelList] = extractIoLabel(headNode)
            % EXTRACTIOLABEL find the label of IO given its head node
            %
            % headNode must have a 'Type' of either V or I
            % In MAPP, IO labels are composed of three parts.
            % 1. IO type (v, i)
            % 2. Label of the first node
            % 3. Label of the reference node
            % This function takes a V or an I node in the AST as input and
            % creates a label like the ones in MAPP  for the IO represented by
            % the input node.
            % inputs:
            %       headNode (VAPP_AST_Node): an AST node representing a VA
            %       probe
            % outputs:
            %       ioLabel (string): label that corresponds to the headNode in
            %       MAPP.
            %       ioType: (string): 'v' or 'i'
            %       nodeLabelList (cell array of strings): a list of input
            %       arguments to the VA probe, i.e., nodeLabelList will be
            %           {'p', 'n'}
            %       for the probe
            %           V(p,n)
            %       nodeLabelList has either 1 or 2 elements. 1, if the probe
            %       is defined with a branch; 2, if the probe is defined by its
            %       end nodes.

            ioType = headNode.get_type();
            % TODO: support ioType 'Pwr' in the future
            if any(strcmp(ioType, {'V', 'I'})) == false
                error('This node is not a V or I node!');
            end

            branchName = {};
            nodeLabelList = {};
            nChildren = headNode.get_num_children(); % this is either 1 or 2

            for i=1:nChildren
                child = headNode.get_child(i);
                nodeLabelList{i} = child.get_name();
            end
            branchName = strcat(nodeLabelList{:});

            ioType = lower(ioType);
            ioLabel = strcat(ioType, branchName);

        % end extractIoLabel
        end
    % end methods
    end

% end classdef
end
