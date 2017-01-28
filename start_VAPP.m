function start_VAPP(VAPPTOP)
% START_VAPP setup VAPP paths
%
% Call start_VAPP from the top-level directory where the VAPP files are located
% in order to setup paths to all the source files.
%
% See also VA2MODSPEC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: J. Roychowdhury
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0
    VAPPTOP=pwd;
end

addpath(strcat(VAPPTOP));
addpath(strcat(VAPPTOP,'/utils'));
addpath(strcat(VAPPTOP,'/backend'));
addpath(strcat(VAPPTOP,'/frontend'));
addpath(strcat(VAPPTOP,'/frontend/VALint_rules'));
addpath(strcat(VAPPTOP,'/backend/utils'));
addpath(strcat(VAPPTOP,'/backend/print_templates'));
fprintf('VAPP paths have been set up.\n');
