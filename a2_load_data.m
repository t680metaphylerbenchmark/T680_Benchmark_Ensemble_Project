% close all;clc;clear;

%{

    Loads the previously compiled data into smaller dataset and defines
    some helper functions

taxa ranks

domain ?superkingdom
kingdom
phylum
class
order
family
genus
species
?subspecies

%}

%% data
if ~exist('data.txt','file')
    unzip('data.zip')
end

t_data=readtable('data.txt','delimiter','\t');
subdirectory={'full','genus','species','subspecies'};

% tax lookup
s_data.tax=sortrows(unique(t_data(:,{'tax_id','name', 'taxa_lvl'})));
% seperate the tables
s_data.full.table=t_data(strcmp(t_data.output,'full'),:);
s_data.genus.table=t_data(strcmp(t_data.output,'genus'),:);
s_data.species.table=t_data(strcmp(t_data.output,'species'),:);
s_data.subspecies.table=t_data(strcmp(t_data.output,'subspecies'),:);
% get unique samples
s_data.full.samples=sortrows(unique(s_data.full.table.sample));
s_data.genus.samples=sortrows(unique(s_data.genus.table.sample));
s_data.species.samples=sortrows(unique(s_data.species.table.sample));
s_data.subspecies.samples=sortrows(unique(s_data.subspecies.table.sample));

%% helpers
taxlookupname = @(x) table2cell( s_data.tax(s_data.tax.tax_id==x,'name') );
taxlookuplevel = @(x) table2cell( s_data.tax(s_data.tax.tax_id==x,'taxa_lvl') );

% from t_data
getsample = @(output,sample) t_data( strcmp(t_data.sample,sample) & strcmp(t_data.output,output),:);
gettool = @(output,sample,tool) t_data(strcmp(t_data.sample,sample) & strcmp(t_data.output,output) & strcmp(t_data.tool,tool),:);
gettruth = @(output,sample) t_data(strcmp(t_data.sample,sample) & strcmp(t_data.output,output) & strcmp(t_data.tool,'TRUTH'),:);

% from specific table
get_sample_t = @(output,sample, table) table( strcmp(table.sample,sample) & strcmp(table.output,output),:);
get_tool_t = @(output,sample,tool, table) table(strcmp(table.sample,sample) & strcmp(table.output,output) & strcmp(table.tool,tool),:);
get_truth_t = @(output,sample, table) table(strcmp(table.sample,sample) & strcmp(table.output,output) & strcmp(table.tool,'TRUTH'),:);

tidx = @(table, col, match) table(strcmp(table.(col),match),:);
get_idx = @(table, col, match) strcmp(table.(col),match);


%%
fprintf('\n\n done loading data. \n')







