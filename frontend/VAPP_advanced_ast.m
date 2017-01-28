function VAPP_advanced_ast(AST)
% Construct advanced AST tree. The tree has following features:
% 1. Variables are linked to their definitions via "alias" pointers

% notebook.if_statement_layers = [1, 1, 0, 1]
% Currently inside 4th layer of if statements blocks. This variable has
% been defined inside first, second, and forth layer. 

notebook = '';
notebook.assign = '';
notebook.contrib = '';
notebook.pow = {}; % {"argument #1" "number of occurances"}
notebook.branch = {}; % {"branch name" "number of occurances"}
[notebook] = generate_advanced_ast(AST, notebook);

%% Here we append all notebook message to AST root node

% notebook rule book
valint_rules = {
 'valint_rule_notebook_pow'
};

for index = 1:length(valint_rules)
    feval(valint_rules{index},notebook, AST);
end

end % END of VAPP_advanced_ast

function [notebook] = generate_advanced_ast(AST_advanced, notebook)

% Find assignments
if strcmp(AST_advanced.get_type, 'assignment')
    this_name = AST_advanced.get_children{1}.get_attr('name'); % this should be the "a" in assignment a=b;
    this_value = AST_advanced.get_children{2}; % this should be the "b" in assignment a=b;
    
    [notebook] = generate_advanced_ast(AST_advanced.get_children{2}, notebook);
    
    if isfield(notebook.assign, this_name)
        % field already exist
        notebook.assign = setfield(notebook.assign, this_name, {this_value, notebook.assign.(this_name){:}});
    else
        notebook.assign = setfield(notebook.assign, this_name, {this_value});
    end
    
    
else
    % Variables
    if strcmp(AST_advanced.get_type, 'var')
        this_name = AST_advanced.get_attr('name');
        
        if isfield(notebook.assign, this_name)
            % if this variable has already been defined
            AST_advanced.set_alias(notebook.assign.(this_name));
        end
    end
    
    % contributions
    if strcmp(AST_advanced.get_type, 'contribution')
        this_type = AST_advanced.get_children{1}.get_type;
        this_branch = '';
        
        if AST_advanced.get_children{1}.get_num_children == 1
            % branch
            
            %if isfield(notebook.contrib, branch)
            %notebook.contrib.(branch)=1;
            this_branch = AST_advanced.get_children{1}.get_children{1}.get_attr('name');
            
        elseif AST_advanced.get_children{1}.get_num_children == 2
            % two nodes
            this_first_node = AST_advanced.get_children{1}.get_children{1}.get_attr('name');
            this_second_node = AST_advanced.get_children{1}.get_children{2}.get_attr('name');
            
            this_branch = [this_first_node '_' this_second_node];
        end
        
        if isfield(notebook.contrib, this_branch)
            % this branch is known to notebook
            if ~strcmp(notebook.contrib.(this_branch), this_type)
                % previous branch defined type is different from current
                % one
                if ~isempty(notebook.contrib.(this_branch))
                    % empty branch type means this branch has been defined as both flow and
                    % potential previously. no need to futhre catch such errors
                    
                    AST_advanced.set_note('contrib_type_change',notebook.contrib.(this_branch));
                    notebook.contrib.(this_branch) = '';
                end
            end
        else
            % this branch is unknown
            notebook.contrib.(this_branch) = this_type;
            
        end
    end
    
    % functions
    if strcmp(AST_advanced.get_type, 'func')
        this_func = AST_advanced.get_attr('name');
        
        if strcmp(this_func, 'pow')            
            this_argu = gather_all_children(AST_advanced.get_children{1},'');

            notebook = add_to_notebook(notebook, 'pow', this_argu, 1, 'increase_by');
        end
    end
    
    % branches
    if strcmp(AST_advanced.get_type, 'branch')
        this_branch = AST_advanced.get_attr('name');
        
        notebook = add_to_notebook(notebook, 'branch', this_branch, 1, 'increase_by');
    end
    
    % flow and potential
    if strcmp(AST_advanced.get_type, 'V')||strcmp(AST_advanced.get_type, 'I')
        if AST_advanced.get_num_children == 1
           % this potential only has one child, check if it is a branch
           if ~notebook_has_entry(notebook, 'branch', AST_advanced.get_children{1}.get_attr('name'))
               AST_advanced.set_attr('ref_to_ground', 1);
           end
        end
    end
    
    % if children exists, recursively get each child
    if ~isempty(AST_advanced.get_children)
        for this_child = AST_advanced.get_children
            % for each child
            [notebook] = generate_advanced_ast(this_child{1}, notebook);
        end
    end
end
end % END of generate_advanced_ast

%% Notebook functions
function notebook=add_to_notebook(notebook, this_field, this_index, this_value, opt)
% this function manages all communications with the notebook
% opt: option can be 'increase_by', 'decrease_by', 'replace'
this_page = notebook.(this_field);

% locate index of this_index in notebook.(this_field)
index_in_book=0;
for index = 1:size(this_page,1)
    if isequal(this_page{index,1},this_index)
            index_in_book = index;
    end
end

if index_in_book == 0
    % this index is new to the notebook
    notebook.(this_field)(end+1,:) = {this_index, this_value};
else
    % this index is known to notebook
    switch opt
        case 'increase_by'
            if isnumeric(this_value) && isnumeric(notebook.(this_field){index_in_book, 2})
                notebook.(this_field){index_in_book, 2} = notebook.(this_field){index_in_book, 2}+this_value;
            else
                error('value is not numeric. Cannot be increased/decreased');
            end
            
        case 'decrease_by'
            if isnumeric(this_value) && isnumeric(notebook.(this_field){index_in_book, 2})
                notebook.(this_field){index_in_book, 2} = notebook.(this_field){index_in_book, 2}-this_value;
            else
                error('value is not numeric. Cannot be increased/decreased');
            end
            
        case 'replace'
            notebook.(this_field){index_in_book, 2} = this_value;
            
        otherwise
            
    end
end

end % END of add_to_notebook

function has_entry = notebook_has_entry(notebook, this_field, this_index)
has_entry = 0;

for index = 1:size(notebook.(this_field))
    if isequal(this_index, notebook.(this_field){index,1})
       has_entry = 1;
       
       return
    end
end

end % END of notebook_has_entry
%% Other utility functions
function result = gather_all_children(AST,result)
this_type = AST.get_type;

switch this_type
    case 'const'
        result{end+1} = AST.get_attr('value');
        
    case 'op'
        result{end+1} = AST.get_attr('op');
                
    otherwise
        result{end+1} = AST.get_attr('name');
end

if ~isempty(AST.get_children)
    % if children exists, recursively get each child
    for this_child = AST.get_children
        % for each child
        result = gather_all_children(this_child{1},result);
    end
end

end % END of gather_all_children