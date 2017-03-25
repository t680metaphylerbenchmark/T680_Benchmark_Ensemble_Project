close all;clear;clc;

%{
  
  Compiles all of the provided OTU tables into a data format in MATLAB

  Does not need to be run unless new OTU tables are created.

%}


%%

% get dataset name from filname
getdataset = @(x) x(1:find(x == '_', 1, 'last')-1);
% get tool from filename
gettool = @(x) x(find(x == '_', 1, 'last')+1:end-4);
% construct filename from dataset and tool
getfilename = @(directory,data,tool) [directory filesep data '_' tool '.txt'];
% return cells containing 'text'
cellfind = @(cellarray,text) cellarray(~cellfun(@isempty,strfind(cellarray,text)));
% return cells not containing 'text'
cellnotfind = @(cellarray,text) cellarray(cellfun(@isempty,strfind(cellarray,text)));
% get tools from dataset name
gettools = @(files, dataset) unique(cellfun(gettool,cellfind(files,dataset),'uniformoutput',false));


%%
directory = 'E:\Users\nyid\Dropbox\output';
subdirectory={'full','genus','species','subspecies'};


% prime the table
tt = cell2table(cell(0,8));
tt.Properties.VariableNames = {'Var1','Var2','Var3','Var4','Var5','Var6','Var7','Var8'};

for diridx = 1:numel(subdirectory)
% for diridx = 4
    
    working=[directory filesep subdirectory{diridx}];
    list = dir(working);
    files = {list(~[list.isdir]).name}'; % no dirs
    files = files(~cellfun(@isempty,regexp(files,'.txt$'))); % just the txt files
    files = cellnotfind(files,'CosmosID'); % ignore CosmosID
    
    % only looking at datasets with the TRUTH table
    ds = unique(cellfun(getdataset,cellfind(files,'TRUTH'),'uniformoutput',false));
    
    % get tool data from this sample
    for sampleidx = 1:numel(ds)
        tools = gettools(files,ds(sampleidx));
        
        for toolidx = 1:numel(tools)
            currentfile = getfilename(working,ds{sampleidx},tools{toolidx});
            disp(currentfile)
            
            temp_table=readtable(currentfile,'delimiter','\t','readvariablenames',false);
            
            if(isempty(temp_table))
                fprintf('EMPTY : %s \n',currentfile);
                continue;
            end
            
            % append output, sample, tool
            output_column=cell(size(temp_table,1),1);
            sample_column=cell(size(temp_table,1),1);
            tool_column=cell(size(temp_table,1),1);
            output_column(:) = subdirectory(diridx);
            tool_column(:) = tools(toolidx);
            sample_column(:)= ds(sampleidx);
            temp_table.Var6=tool_column;
            temp_table.Var7=sample_column;
            temp_table.Var8=output_column;
            
            tt=vertcat(tt,temp_table);
        end
    end
end

disp('import done. writing table to disk...')

tt.Properties.VariableNames = {'tax_id','num_reads','abundance','taxa_lvl','name','tool','sample','output'};

writetable(tt,'data','Delimiter','\t')

disp('done.');