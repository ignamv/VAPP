classdef IrVisitorMark2 < IrVisitor
% IRVISITORMARK2 runs the second pass over the IR tree
% This visitor sets the equation indices of implicit contributions.
%
% See also IRVISITOR IRVISITORMARK1

% NOTE: planned optimization features can be implemented here.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        module = IrNodeModule.empty;
    end

    methods

        function obj = IrVisitorMark2(module)
            obj.module = module;
            obj.traverseIr(module);
        end

        function traverseSub = visitGeneric(thisVisitor, irNode)
            traverseSub = true;
        end

        function traverseSub = visitIrNodeContribution(thisVisitor, contribNode)

            % If the contribution is a "regular contribution" add it to the
            % list of equations. A regular contribution has isNullEqn attribute
            % set to false. Note that a contribution can have its isNullEqn
            % attribute set to true regardless of it being implicit or
            % explicit.
            module = thisVisitor.module;
            if contribNode.isImplicit == true
                module.incNImplicitEqn();
                contribNode.setEqnIdx(module.getNFiQi());
            end

            % TODO: this might be the place to mark unmarked IOs in an implicit
            % contribution

            traverseSub = false;

        % end visitContribution
        end

    end
end
