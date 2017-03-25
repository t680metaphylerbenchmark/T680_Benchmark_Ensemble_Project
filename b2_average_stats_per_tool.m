
%{

    Generates averages statistics per each tool over species and genus taxa
    levels

%}

%% load data

clc;close all;
if ( ~exist('t_stats','var') )
    a2_load_data;
    c1_false_positive;
    t_stats=readtable('statistics.txt','delimiter','\t');
end

get_idx = @(table, col, match) strcmp(table.(col),match);

% combine stats
% replace fp with new fp
% calc new pvp

%% combine stats

% filter for just species and genus
t_stats_temp=t_stats(get_idx(t_stats,'output','species') | get_idx(t_stats,'output','genus'),:);
tools=unique(t_stats_temp.tool);
t_stats_combined=cell(0);

for tool_idx = 1:numel(tools)
    % tool name
    cn_tool=char(tools(tool_idx));
    % tool table
    ct_tool = tidx(t_stats_temp,'tool',cn_tool);
    
    % collect stats
%     t_fp = sum(ct_tool.fp);
    t_tp = sum(ct_tool.tp);
    t_fn = sum(ct_tool.fn);
    t_tn = sum(ct_tool.tn);
    t_sensitivity=mean(ct_tool.sensitivity);
    t_specificity=mean(ct_tool.specificity);
%     t_pred_val_pos=mean(ct_tool.pred_val_pos);
    t_pred_val_neg=mean(ct_tool.pred_val_neg);
    
    % replace fp with new fp
    ct_new_fp=tidx(t_new_fp,'tool',cn_tool);
    t_fp=ct_new_fp.fp_new;
    t_pred_val_pos=t_tp/(t_tp+t_fp);
        
    current_stat={cn_tool t_fp t_tp t_fn t_tn t_sensitivity t_specificity t_pred_val_pos t_pred_val_neg};
    t_stats_combined = [t_stats_combined;current_stat];
end

t_stats_combined=cell2table(t_stats_combined);
t_stats_combined.Properties.VariableNames = {'tool','fp','tp','fn','tn','sensitivity','specificity','pred_val_pos','pred_val_neg'};
t_stats_combined=sortrows(t_stats_combined,'pred_val_pos','descend')

%%
bar(t_stats_combined.pred_val_pos)
set(gca,'xtick',1:numel(t_stats_combined.pred_val_pos));
set(gca,'xticklabel',t_stats_combined.tool);
set(gca,'xticklabelrotation',45);
title('Tool Ranking - Precision Based')
ylabel('Precision')
xlabel('Tool')