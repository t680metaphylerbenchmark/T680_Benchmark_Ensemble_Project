%%

%{

    Creates false positive table

%}

if ( ~exist('t_data','var') )
    a2_load_data
end

tidx = @(table, col, match) table(strcmp(t_data.(col),match),:);

%%
clc

temp_fp_table=cell(0);

% for output_idx = 1:numel(subdirectory)
for output_idx = 2:3

    cn_data=subdirectory{output_idx};
    ct_data=s_data.(cn_data);
    
    for sample_idx = 1:numel(ct_data.samples)
%     for sample_idx = 2
        cn_sample = char(ct_data.samples(sample_idx));
        ct_sample = get_sample_t(cn_data,cn_sample,ct_data.table);
        tools = unique(ct_sample.tool);
        
        ct_truth=sortrows(get_truth_t(cn_data,cn_sample,ct_sample),'tax_id');
        
        fprintf('%10s : %s \n',cn_data,cn_sample);
        
        for tool_idx = 1:numel(tools)
%         for tool_idx = 10
            
            cn_tool=char(tools(tool_idx));
            if( strcmp(cn_tool,'TRUTH') );continue;end
            
            ct_tool=sortrows(get_tool_t(cn_data,cn_sample,cn_tool,ct_sample),'tax_id');
            cv_truth_tax=sort(unique(ct_truth.tax_id));
            cv_tool_tax=sort(unique(ct_tool.tax_id));
            
            [ca_fp,ca_fp_idx]=setdiff(cv_tool_tax, cv_truth_tax);
            cv_fp=numel(ca_fp);
            
            temp_fp_table=[temp_fp_table;ct_tool(ca_fp_idx,:)];
            
        end %tool
    end %sample
end %output

writetable(temp_fp_table,'false_positives_only','Delimiter','\t');


