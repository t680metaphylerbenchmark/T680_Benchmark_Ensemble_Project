close all;clc;

%{
Dr. Rosen suggested we do a 'per taxa' classification. This means for each taxa (E. Coli)
identify which tools do best to identify this taxa. To answer the question "Do some tools
do better on the genus level?" In MATLAB we count the absence/presence of a taxa and make
frequency histograms for each taxa and tool. Additionally we can quantify based on abundance
estimate instead of absence/presence for each taxa and try weighting each tool by the taxa it
does best.

Other possible classification approaches are to look at average/median estimations and identify
those tools that over or underestimate.

Only apply the ensemble classifier on 'TRUTH' datasets and exclude anything from CosmosID.
%}

%%
pd=mfilename('fullpath');
ddir = @(x) [pd(1:end-numel(mfilename)) x];

subdirectory={'full','genus','species','subspecies'};
d=pwd;

%%
rmdir('output','s')
mkdir('.','output')
cd('output')

figure
set(gcf,'visible','off');

for dir_idx = 1:numel(subdirectory)
% for dir_idx = 2
    
    current_data=s_data.(subdirectory{dir_idx});
    
    for sample_idx = 1:numel(current_data.samples)
%     for sample_idx = 34
        s=current_data.samples(sample_idx);
        tr=gettruth(subdirectory{dir_idx},s);
        tax=tr.tax_id;
        samp=getsample(subdirectory{dir_idx},s);
        sname=strrep(s,'_','\_');
        
        for tax_idx = 1:numel(tax)
%         for tax_idx = 1:5
            samp_filt=samp(samp.tax_id==tax(tax_idx),:);
            samp_filt=sortrows(samp_filt,3);
            
            bar(samp_filt.abundance);
            ylabel('Relative Abundance');
            xlabel('Tool');
            set(gca,'xtick',1:numel(samp_filt.tax_id))
            set(gca,'xticklabel',samp_filt.tool)
            set(gca,'xticklabelrotation',45)
            title( sprintf('%s - %s\n%d - %s',subdirectory{dir_idx},char(sname),tax(tax_idx),char(taxlookup(tax(tax_idx)))) )
            
            fn=sprintf('%s_%s_%d.png',subdirectory{dir_idx},char(s),tax(tax_idx));
            disp(fn)
            saveas(gcf,fn);
            
        end
    end
end

cd '..'
disp('done.')
