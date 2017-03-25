%%

%{

    Creates statistics table.

    fp, tp, sensitivity, etc

%}


if ( ~exist('t_data','var') )
    a2_load_data
end

% number of known taxa to calculate true negatives
% full genus species subspecies, as of 2017 from NCBI
num_known_taxa=[516944 81445 382954 27253];

%% generate statistics
clc

temp_stats=cell(0);

for output_idx = 1:numel(subdirectory)
% for output_idx = 2

    cn_data=subdirectory{output_idx};
    cn_known_taxa=num_known_taxa(output_idx);
    ct_data=s_data.(cn_data);
    
    for sample_idx = 1:numel(ct_data.samples)
%     for sample_idx = 2
        cn_sample = char(ct_data.samples(sample_idx));
        ct_sample = get_sample_t(cn_data,cn_sample,ct_data.table);
        tools = unique(ct_sample.tool);
        
        ct_truth=get_truth_t(cn_data,cn_sample,ct_sample);
        
        fprintf('%10s : %s \n',cn_data,cn_sample);
        
        for tool_idx = 1:numel(tools)
%         for tool_idx = 11
            
            cn_tool=char(tools(tool_idx));
            if( strcmp(cn_tool,'TRUTH') );continue;end
            
            ct_tool=get_tool_t(cn_data,cn_sample,cn_tool,ct_sample);
            cv_truth=unique(ct_truth.tax_id);
            
            % true positive
            ca_tp=intersect(ct_tool.tax_id,ct_truth.tax_id);
            cv_tp=numel(ca_tp);
            
            % false positive
            ca_fp=setdiff(ct_tool.tax_id,ct_truth.tax_id);
            cv_fp=numel(ca_fp);
            
            % true negative ??
            cv_tn=num_known_taxa(output_idx)-cv_tp-cv_fp;
            
            % false negative
            ca_fn=setdiff(ct_truth.tax_id,ct_tool.tax_id);
            cv_fn=numel(ca_fn);
            
            % sensitivity
            cv_sen=cv_tp/(cv_tp+cv_fn);
            
            % specificity
            cv_spe=cv_tn/(cv_tn+cv_fp);
            
            % predictive value positive
            cv_pvp=cv_tp/(cv_tp+cv_fp);
            
            % predictive value negative
            cv_pvn=cv_tn/(cv_tn+cv_fn);
            
            current_stats={cn_data cn_sample cn_tool cv_fp cv_tp cv_fn cv_tn cv_sen cv_spe cv_pvp cv_pvn};
            temp_stats=[temp_stats;current_stats];
            
        end %tool
    end %sample
end %output

t_stats = cell2table(temp_stats,'variablenames',{'output','sample','tool','fp','tp','fn','tn','sensitivity','specificity','pred_val_pos','pred_val_neg'});
writetable(t_stats,'statistics','Delimiter','\t');


fprintf('\n\n done writing statistics.txt \n');