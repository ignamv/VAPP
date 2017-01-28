function modObj = valint(inFileName, output_format, varargin)
% VALINT checks a Verilog-A code for bad practices
%
% This is the VAPP implementation of the VALint program. VALint is the 
% NEEDS created, automatic Verilog-A code checker. Its purpose is to check 
% the quality of the Verilog-A code and provide the author feedback if bad 
% practices, common mistakes, pitfalls, or inefficiencies are found.
%
% Caution: If the output file already exists, VAPP will overwrite it.
% 
% VAPP will require an 'include' directory where the files inserted into the
% model with the `include directives (such as `include "disciplines.vams") in
% the Verilog-A file are located. By default this directory is assumed to be in
% the same directory as the Verilog-A input file.
%       
% Usage:
%       valint(path_to_input_file)
%           will take the path_to_input_file as the Verilog-A source, 
%           check the quality of the code and return result.
%
%       valint(path_to_input_file, 'outputDir', path_to_output_directory)
%           will write the translated ModSpec file to path_to_output_directory 
%
%       valint(path_to_input_file, 'includeDir', path_to_include_directory)
%           will include additional search paths
%       
% See also MAPP, MODSPEC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: Xufeng Wang, A. Gokcen Mahmutoglu                                                %
%% Date: 02/11/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    inPar = inputParser;
%    inPar.addRequired('inFileName', @isstr);
%    inPar.addParameter('outputDir', [], @isstr);
%    inPar.addParameter('includeDir', [], @isstr);
%    inPar.parse(inFileName, varargin{:});
%    outputDir = inPar.Results.outputDir;
%    includeDir = inPar.Results.includeDir;

    if ~exist('output_format')
        output_format = 'default';
    end
    
    str_utils = VAPP_str_utils();

    % append output_format to str_utils
    str_utils.output_format = output_format;
    
    % pre-process
    macro_definitions = {};
    sIdx = strfind(inFileName, '/');
    if isempty(sIdx) == false
        sIdx = sIdx(end);
        working_dir = inFileName(1:sIdx);
    else
        working_dir = '';
    end

    pre_process_parms.combine_lines_allow_whitespace = true;

    if ~isempty(varargin)
        pre_process_parms.include_dirs = varargin(1);
    else
        pre_process_parms.include_dirs = {};
    end
    
    fprintf('Pre-processing and tokenizing... \n');
    tic;
    toks  = VAPP_pre_process(inFileName, macro_definitions, ...
                                             pre_process_parms, str_utils);
    processingTime = toc;
    fprintf('  %.2f seconds\n', processingTime);
   
    % parse
    fprintf('Parsing... \n');
    tic;
    ast = VAPP_parse(toks, str_utils);
    processingTime = toc;
    fprintf('  %.2f seconds\n', processingTime);
    
    % construct advanced AST tree
    VAPP_advanced_ast(ast);
    
    % lint
    VAPP_lint(ast, output_format);
    
    fprintf('--------------------------------------------------------\n');
    fprintf('----------------- VALint complete ----------------------\n');
    fprintf('--------------------------------------------------------\n');
    
end
