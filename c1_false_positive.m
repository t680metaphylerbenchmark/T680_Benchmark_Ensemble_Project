%{

    Determines false positive tool rankings

%}

close all; clear; clc

subdirectory={'full','genus','species','subspecies'};
tidx = @(table, col, match) table(strcmp(table.(col),match),:);

% from specific table
get_sample_t = @(output,sample, table) table( strcmp(table.sample,sample) & strcmp(table.output,output),:);
get_tool_t = @(output,sample,tool, table) table(strcmp(table.sample,sample) & strcmp(table.output,output) & strcmp(table.tool,tool),:);
get_truth_t = @(output,sample, table) table(strcmp(table.sample,sample) & strcmp(table.output,output) & strcmp(table.tool,'TRUTH'),:);

if ( ~exist('t_falsepositive','var') )
    t_falsepositive=readtable('false_positives_only.txt','delimiter','\t');
    t_stats=readtable('statistics.txt','delimiter','\t');
end

%%


%{
RANK

'MetaFlow'
'OneCodexAbundanceFiltered'
'Metaphlan'
'BlastMeganFiltered'
'Gottcha'
'DiamondMegan'
'BlastMeganFilteredLiberal'
'KrakenFiltered'
'LMAT'
'MetaPallette-SmallDB-qual4-default'
'MetaPallette-SmallDB-qual4-specific'
'ClarkM4Spaced'
'Kraken'
'ClarkM1Default'
'PhyloSift90pct'
'NBC'
'PhyloSift'
'COMMUNITY'

%}

%%
clc;close all

for output_idx = 2:3
    
    cn_data=subdirectory{output_idx};
    ct_data= tidx(t_falsepositive, 'output', cn_data);
    cl_samples=table2array(unique(ct_data(:,{'sample'})));
    
    cv_min=min(ct_data.abundance);
    cv_max=max(ct_data.abundance);
    cv_step=(cv_max-cv_min)/1000;
    
    tools=unique(ct_data.tool);
    count=unique(ct_data(:,{'sample','tool'}));
    
    ca_matrix=[];
    
%     for tool_idx = 1:numel(tools)
    for tool_idx = 1:numel(tools)
        cn_tool=char(tools(tool_idx));
        cn_tool_num=height(tidx(count,'tool','NBC'));
        fprintf('%s : %s : %d \n',cn_data,cn_tool, cn_tool_num);
        
        ct_tool = tidx(ct_data,'tool',cn_tool);
        
        ca_row=[];
        for threshold = cv_min:cv_step:cv_max
            ct_new=ct_tool(ct_tool.abundance > threshold,:);
            ca_row=[ca_row height(ct_new)];
        end
        
        ca_matrix=[ca_matrix;ca_row];
        
    end %tool
end %output

%% translation table
rankk=@(x) [[1:18]' ca_matrix(:,1) ca_matrix(:,x) (ca_matrix(:,1)-ca_matrix(:,x))*.1 (ca_matrix(:,1)-ca_matrix(:,x))*.1+ca_matrix(:,x)];
r=num2cell(rankk(13));
t_new_fp = cell2table([tools r]);
t_new_fp.Properties.VariableNames = {'tool','num','fp_total','fp_thresh','fp_weighted','fp_new'};


%% bar graph
close all;
t=sortrows(t_new_fp,'fp_new');

bar(t.fp_new)
set(gca,'xtick',1:numel(t.fp_new));
set(gca,'xticklabel',t.tool);
set(gca,'xticklabelrotation',45);
title('Tool Ranking - Thresholding')
ylabel('False Positive Count')
xlabel('Tool')

figure
t=sortrows(t_new_fp,'fp_total');
bar(t.fp_total)
set(gca,'xtick',1:numel(t.fp_total));
set(gca,'xticklabel',t.tool);
set(gca,'xticklabelrotation',45);
title('Tool Ranking - Raw False Positive')
ylabel('False Positive Count')
xlabel('Tool')


%% plots
% for i = 1:size(ca_matrix,1)
%    figure
%    plot(ca_matrix(i,:)) 
%    title(tools(i))
% end


