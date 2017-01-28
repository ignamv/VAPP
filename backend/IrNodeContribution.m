classdef IrNodeContribution < IrNodeNumerical
% IRNODECONTRIBUTION represents a Verilog-A contribution statement
%
% A contribution statement in Verilog-A is denoted by "<+" and has a probe (V,
% I or Pwr) on its left-hand side. E.g.,
%
%   I(p,n) <+ G*V(p,n)
%    (LHS)      (RHS)
%
% MAPP supports two types of contributions:
%  1. Explicit
%  2. Implicit
%
% Explicit contributions are those for which the RHS expression can be
% computed directly. The simple resistance equation given above is such a
% contribution.
%
% Implicit contributions have RHS expressions that depend on the LHS IO of the
% contribution itself. The following expression for a diode is such a
% contribution:
% 
%   I(p,n) <+ is*(limexp((V(p,n) - r*I(p,n))/$vt) - 1);
%
% Notice how I(p,n) appears both on the LHS and RHS of the contribution.
%
% The detection to which class a particular contribution belongs is currently
% being performed by the IrVisitorMark1 class.
%
% NOTE: VAPP currently does not support variable tracing, i.e., if a variable
% on the RHS depends on the RHS IO, this is not detected. This feature is to be
% included in the next release.
%
% See also IRVISITORMARK1 IRNODENUMERICAL

% TODO: see the note above.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        implicit = false; % is the contribution implicit?
        nullEqn = false;  % is the contribution a null-equation?
        % a null-equation is an equation where the LHS IO occurs on the RHS in
        % an additive fashion and cancels out the LHS IO.
        % null-equations are implicit equations and their LHS IOs are dummy
        % IOs.
        eqnIdx = 0;       % which row does this contribution occupy in the
                          % output vectors
        rhsDummyNode = IrNodeInputOutput.empty; % empty if nullEqn==false,
        % otherwise points to the IR tree node that contains the RHS dummy IO.
    end

    methods

        function obj = IrNodeContribution()
            obj = obj@IrNodeNumerical();
            obj.additive = 1;
            % contributions have to have additive = 1 because of their lhs IOs.
            % We need to determine if a lhs IO is an inverse IO or not in order
            % to detect implicitly defined equations.
            % To how this is done, take a look at the visitIrNodeContribution
            % method of IrVisitorMark1 class.
        end

        function outStr = sprintNumerical(thisContrib, ~)
            lhsNode = thisContrib.getLhsNode();
            rhsNode = thisContrib.getRhsNode();
            fStr = rhsNode.sprintAll();
            qStr = rhsNode.sprintAllDdt(); % this prints the ddt chain
            eqnIdx = thisContrib.eqnIdx;

            outStr = '';

            if thisContrib.implicit == false
                % Contribution is explicit. Just let the LHS IO that it gets
                % the contribution on the RHS.
                lhsIoObj = thisContrib.getLhsIoObj();
                outStr = [outStr, '// contribution for ', ...
                                                lhsIoObj.getLabel(), '\n'];
                if isempty(fStr) == false
                    outStr = [outStr, lhsIoObj.add2F(fStr), '\n'];
                end

                if isempty(qStr) == false
                    outStr = [outStr, lhsIoObj.add2Q(qStr), '\n'];
                end
            else
                % contribution is implicit.
                if thisContrib.nullEqn == true
                    lhsStr = '';
                else
                    % if nullEqn, add a minus the LHS IO
                    lhsStr = ['-', lhsNode.sprintAll()];
                end

                outStr = [outStr, sprintf('fi(%d,1) = %s%s;\n', eqnIdx,...
                                                                     fStr,...
                                                                     lhsStr)];
                if isempty(qStr) == false
                    outStr = [outStr, sprintf('qi(%d,1) = %s;\n', eqnIdx, qStr)];
                else
                    % FIXME: the line below causes an error in MAPP when used
                    % with vecvalder. For an explanation, see bug #60 in MAPP's
                    % bug tracking system.
                    outStr = [outStr, sprintf('qi(%d,1) = 0;\n', eqnIdx)];
                end
            end
        end

        function setImplicit(thisContrib)
            thisContrib.implicit = true;
        end

        function out = isImplicit(thisContrib)
            out = thisContrib.implicit;
        end

        function setNullEqn(thisContrib)
            thisContrib.nullEqn = true;
        end

        function out = isNullEqn(thisContrib)
            out = thisContrib.nullEqn;
        end

        function lhsIo = getLhsIoObj(thisContrib)
            lhsNode = thisContrib.getLhsNode();
            lhsIo =  lhsNode.getIoObj();
        end

        function setEqnIdx(thisContrib, idx)
            thisContrib.eqnIdx = idx;
        end

        function lhsNode = getLhsNode(thisContrib)
            lhsNode = thisContrib.getChild(1);
        end

        function rhsNode = getRhsNode(thisContrib)
            rhsNode = thisContrib.getChild(2);
        end

        function setRhsDummyNode(thisContrib, rhsDummyNode)
            thisContrib.rhsDummyNode = rhsDummyNode;
        end

        function rhsDummyNode = getRhsDummyNode(thisContrib)
            rhsDummyNode = thisContrib.rhsDummyNode;
        end

    % end methods
    end
% end classdef
end
