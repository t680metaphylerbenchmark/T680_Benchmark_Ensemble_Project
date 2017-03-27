clc;

%%
if ( ~exist('t_data','var') )
    a2_load_data
end

%%
clc

cv_vs=[];
cn_cell=cell(0);
cn_performance=[];

for output_idx = 2:3
    
    cn_data=subdirectory{output_idx};
    ct_data=s_data.(cn_data);
    
    for sample_idx = 1:numel(ct_data.samples)
        
        cn_sample = char(ct_data.samples(sample_idx));
        ct_sample = get_sample_t(cn_data,cn_sample,ct_data.table);
        ct_truth=sortrows(get_truth_t(cn_data,cn_sample,ct_sample),'tax_id');
        
        tools = unique({'MetaFlow','BlastMeganFiltered','OneCodexAbundanceFiltered','DiamondMegan','Metaphlan'});
        
        cv_tax=[];
        cv_fp=[];
        for tool_idx = 1:numel(tools)
            
            cn_tool=char(tools(tool_idx));
            if( strcmp(cn_tool,'TRUTH') );continue;end
            
            ct_tool=sortrows(get_tool_t(cn_data,cn_sample,cn_tool,ct_sample),'tax_id');
            ct_tool;
            
            cv_tax=[cv_tax ct_tool.tax_id'];
            
            % percent false positives
            tool_fp=numel(setdiff(ct_tool.tax_id,ct_truth.tax_id))/numel(ct_truth.tax_id);
            cv_fp=[cv_fp tool_fp];
            
        end %tool
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Majority Voting Ensemble
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        tools_detected_taxa = unique(cv_tax);
        votes_per_taxa = zeros(size(tools_detected_taxa));
        taxa_in_truth=ct_truth.tax_id;
        taxa_in_truth_not_found_by_tools = setdiff(taxa_in_truth,tools_detected_taxa);
        
        % count the votes per detected taxa
        for i = 1:length(tools_detected_taxa)
            votes_per_taxa(i) = sum(cv_tax==tools_detected_taxa(i));
        end
        
        % combine detected taxa with votes
        taxa_with_votes=[tools_detected_taxa; votes_per_taxa]';
        
        % add taxa not found that are in the truth table (with zero votes)
        for i = 1:numel(taxa_in_truth_not_found_by_tools)
            taxa_with_votes = [taxa_with_votes; taxa_in_truth_not_found_by_tools(i) 0];
        end
        
        % find taxa that won the vote
        taxa_that_won=taxa_with_votes(taxa_with_votes(:,2)>2);
        
        % sum total taxa in truth table
        for i = 1:length(taxa_with_votes)
            taxa_with_votes(i,3) = numel(find(taxa_in_truth==taxa_with_votes(i,1)));
        end
        
        % generate ensemble statistics per sample
        ensemble_fp=numel(setdiff(taxa_that_won,ct_truth.tax_id))/numel(ct_truth.tax_id);
        vs=cv_fp-ensemble_fp;
        cv_vs=[cv_vs; vs];
        e=isequal(taxa_in_truth,taxa_that_won);
        v=sprintf('% 2.3f ', vs);
        cn_cell=[cn_cell; {e cn_data cn_sample v}];
        
        % save sample performance
        cn_performance = [cn_performance; taxa_with_votes];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
    end %sample
end %output

t_cell=cell2table(cn_cell);
t_cell.Properties.VariableNames={'perfect','output','sample','fp'};

t_cell
sum(cv_vs)
sum(t_cell.perfect)/height(t_cell)

%% get performance per taxa over all samples
cn_performance_overall=[];
cn_performance_overall=unique(cn_performance(:,1));
for i = 1:numel(cn_performance_overall)
    cn_performance_overall(i,2) = sum(cn_performance(cn_performance(:,1)==cn_performance_overall(i),3));
    cn_performance_overall(i,3) = numel(cn_performance(cn_performance(:,1)==cn_performance_overall(i),3));
    cn_performance_overall(i,4) = cn_performance_overall(i,2)/ cn_performance_overall(i,3);
end

ct_performance_overall = array2table(cn_performance_overall,'VariableNames',{'taxa_id','count_won_vote','count_truth_table','accuracy'});

if ( ~exist('majority_voting_overall.txt','file') )
    writetable(ct_performance_overall,'majority_voting_overall','Delimiter','\t')
end