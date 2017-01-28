function modObj = va2modspec(inFileName, varargin)
% VA2MODSPEC translate a Verilog-A model into ModSpec format
%
% va2modspec is the main user interface for VAPP. It translates a Verilog-A
% model into ModSpec format and prints the result into an output file. The name
% of the output file will be the module name with an ".m" extension. Note that
% the module name in the Verilog-A file can be different from the name of the
% file itself. 
%
% Caution: If the output file already exists, VAPP will overwrite it.
% 
% VAPP will require an 'include' directory where the files inserted into the
% model with the `include directives (such as `include "disciplines.vams") in
% the Verilog-A file are located. By default this directory is assumed to be in
% the same directory as the Verilog-A input file.
%       
% Usage:
%       va2modspec(path_to_input_file)
%           will take the path_to_input_file as the Verilog-A source, generate
%           the ModSpec model and write the output file to the current
%           directory. 
%
%       va2modspec(path_to_input_file, 'outputDir', path_to_output_directory)
%           will write the translated ModSpec file to path_to_output_directory 
%
%       va2modspec(path_to_input_file, 'include', path_to_include_directory)
%           will
%       
% See also MAPP, MODSPEC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of VAPP, the Berkeley Verilog-A Parser and Preprocessor.  %
%% Author: A. Gokcen Mahmutoglu                                                %
%% Date: 01/25/2016                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    inPar = inputParser;
    inPar.addRequired('inFileName', @isstr);
    inPar.addParameter('outputDir', [], @isstr);
    inPar.addParameter('includeDir', [], @isstr);
    inPar.parse(inFileName, varargin{:});
    outputDir = inPar.Results.outputDir;
    includeDir = inPar.Results.includeDir;

    str_utils = VAPP_str_utils();
    str_utils.output_format = 'default';

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
    if isempty(includeDir)
        includeDir = [working_dir, 'include'];
    end
    pre_process_parms.include_dirs = {includeDir};


    fprintf('Pre-processing and tokenizing... ');
    tic;
    toks  = VAPP_pre_process(inFileName, macro_definitions, ...
                                             pre_process_parms, str_utils);
    processingTime = toc;
    fprintf('%.2f seconds\n', processingTime);

    % parse
    fprintf('Parsing... ');
    tic;
    ast = VAPP_parse(toks, str_utils);
    processingTime = toc;
    fprintf('%.2f seconds\n', processingTime);

    % translate
    fprintf('Translating... ');
    tic;

    % create intermediate representation (IR) tree
    ig = AstVisitorIrGenerator(ast);

    module = ig.getModule;

    % go over the IR tree in several passes and perform various operations on
    % its nodes.
    IrVisitorMark1(module);
    IrVisitorMark2(module);

    outFileBase = ig.getModule.getName();
    outFileName = [outFileBase, '.m'];
    if isempty(outputDir) == false
        outFileName = [outputDir, '/', outFileName];
    end
    outFileId = fopen(outFileName, 'w+');
    ig.printModSpec(outFileId);
    fclose(outFileId);
    processingTime = toc;
    fprintf('%.2f seconds\n', processingTime);

    fprintf('Done: Output printed to ''%s''\n', outFileName);

    if nargout == 1
        modObj = eval([outFileBase, '()']);
    end

end
