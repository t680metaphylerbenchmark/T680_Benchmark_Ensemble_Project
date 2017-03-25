clc;

%%
if ( ~exist('t_data','var') )
    a2_load_data
end

%%
%taking intersect of 4 top performing classifiers, no cascading
tools = {'MetaFlow', 'BlastMeganFiltered'};%, 'OneCodexAbundanceFiltered', 'DiamondMegan'};

% ranked_tools = tools;
Comp=cell(0);
for output_idx = 2
% for output_idx = 2

    cn_data=subdirectory{output_idx};
    ct_data=s_data.(cn_data);
    
%     Comp=cell(0);
    for sample_idx = 1:numel(ct_data.samples)
%     for sample_idx = 2
        cn_sample = char(ct_data.samples(sample_idx));
        ct_sample = get_sample_t(cn_data,cn_sample,ct_data.table);
         
        ct_truth=get_truth_t(cn_data,cn_sample,ct_sample);
        
%         fprintf('%10s : %s \n',cn_data,cn_sample);
        ids=cell(0);
        for tool_idx = 1:length(tools)
%         for tool_idx = 11
            t_get = get_tool_t(cn_data,cn_sample,tools{tool_idx},ct_sample);
            ids = [ids {t_get.tax_id}];
        end %tool
        int3 = intersect(ids{1},ids{2});
%         int3 = intersect(int3,ids{3});
%         int3 = intersect(int3,ids{4});
        %Comparison to Truth. Finding the number of FP's. Negative numbers mean
        %ensemble did not pick up all taxa in truth
        Comp = [Comp; {cn_data,cn_sample, (numel(intersect(int3,ct_truth.tax_id)) - height(ct_truth)) (numel(intersect(int3,ct_truth.tax_id)) - height(ct_truth))/height(ct_truth)}];
    end %sample
end %output

t_cell=cell2table(Comp);
t_cell.Properties.VariableNames={'output','sample','diff_truth','nomalized'};
t_cell=sortrows(t_cell,'nomalized','descend');
t_cell
