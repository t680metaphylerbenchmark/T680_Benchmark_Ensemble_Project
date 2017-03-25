%{

    Performs weighted majority voting

%}

clc;

%%
if ( ~exist('t_data','var') )
    a2_load_data
end

%%
clc

cv_vs=[];
cn_cell=cell(0);
cv_pp=[]; % trusted tax ids

% rank, best to worst
tools = unique({'MetaFlow','BlastMeganFiltered','OneCodexAbundanceFiltered','DiamondMegan','Metaphlan'})
% tools = unique({'OneCodexAbundanceFiltered','Gottcha','BlastMeganFiltered','DiamondMegan','KrakenFiltered'})

for output_idx = 2:3
    
    cn_data=subdirectory{output_idx};
    ct_data=s_data.(cn_data);
    
    for sample_idx = 1:numel(ct_data.samples)
        %     for sample_idx = 1
        cn_sample = char(ct_data.samples(sample_idx));
        ct_sample = get_sample_t(cn_data,cn_sample,ct_data.table);
        ct_truth=sortrows(get_truth_t(cn_data,cn_sample,ct_sample),'tax_id');
        
        cv_tax=[];
        cv_fp=[];
        for tool_idx = 1:numel(tools)
            % current tool weight
            weight=numel(tools)+1-tool_idx;
            % skip TRUTH
            cn_tool=char(tools(tool_idx));
            if( strcmp(cn_tool,'TRUTH') );continue;end
            
            ct_tool=sortrows(get_tool_t(cn_data,cn_sample,cn_tool,ct_sample),'tax_id');
            % weighted tax ids found
            cv_tax=[cv_tax repelem(ct_tool.tax_id',weight)];
            
            % percent false positives
            tool_fp=numel(setdiff(ct_tool.tax_id,ct_truth.tax_id))/numel(ct_truth.tax_id);
            cv_fp=[cv_fp tool_fp];
            
        end %tool
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Weighted Majority Voting Ensemble
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        p = unique(cv_tax);
        y = zeros(size(p));
        
        for i = 1:length(p)
            y(i) = sum(cv_tax==p(i));
        end
        p=[p; y]';
        
        pp=p(p(:,2)>8);
        cv_pp = [cv_pp pp'];
        t=ct_truth.tax_id;
        
        ensemble_fp=numel(setdiff(pp,ct_truth.tax_id))/numel(ct_truth.tax_id);
        vs=cv_fp-ensemble_fp;
        cv_vs=[cv_vs; vs];
        
        e=isequal(t,pp);
        v=sprintf('% 2.3f ', vs);
        cn_cell=[cn_cell; {e cn_data cn_sample v}];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
    end %sample
end %output

%% 

t_cell=cell2table(cn_cell);
t_cell.Properties.VariableNames={'perfect','taxa_level','sample','percent_diff_fp'};

t_cell
sum(cv_vs)
sum(t_cell.perfect)/height(t_cell)

trusted_taxa = unique(cv_pp);

%% compute and save trusted taxa

trusted_taxa_final=cell(0);
for i=1:numel(trusted_taxa)
    cv_tt = {trusted_taxa(i) taxlookuplevel(trusted_taxa(i)) taxlookupname(trusted_taxa(i))};
    trusted_taxa_final = [trusted_taxa_final; cv_tt];
end

trusted_taxa_final=cell2table(trusted_taxa_final,'VariableNames',{'taxa_id','taxa_lvl','taxa_name'});
writetable(trusted_taxa_final,'trusted_taxa_final','Delimiter','\t')