# ECES_T680_Benchmarking_Ensemble_Project
Benchmark Metagenomic Tools or Primer Design

### See "MetaPhyler and Ensemble Building for Metagenomic Classifiers.pptx"

MATLAB scripts for ensemble building,
Metaphyler output will be placed on Proteus server

## Setup and help scripts
#### a1_compile_data.m
Compiles all OTU tables provided in data dump. Do not run unless new OTU tables have been generated.

#### a2_load_data.m
Helper script that loads data compliled from previous step into subtables and some helper functions.

#### b1_generate_fp_table.m
Created false positive table, not necessary to run if table is already generated.

#### b1_generate_statistics.m
Generates statistics table with metrics like false positives, true positives, sensitivity, etc. Do not run unless previous steps have been re-run.

#### b2_average_stats_per_tool.m
Averages statistical data by tool per taxa levels.

#### create_graphs.m
Generates relative abundance graphs for each tax id per tool. Note: this is no longer used

## Ensemble scripts
#### c1_false_positive.m
Executes tool ranking based on:
* Raw false positive
* False positive with thresholding

#### c2_majority_voting.m
Executes majority voting ensemble and outpus relavent metrics

#### c2_weighted_majority_vote.m
Executes weighted majority voting ensemble and outpus relavent metrics

#### test_emse.m
Ensembled based on N tool output unions

#### d1_majority_voting_per_taxa.m
Collects statistics per taxa id over genus and species for all samples and tools, for the majority voting ensemble.

## Tab delimited data files
#### data.zip
#### false_positives_only.txt
#### statistics.txt
#### trusted_taxa_final.txt
#### majority_voting_overall.txt
taxa_id<br />
count_won_vote - number of times the ensemble voted the taxa id was present<br />
count_truth_table - number of times the taxa is was actually present<br />
accuracy = (count_won_vote/count_truth_table)<br />
