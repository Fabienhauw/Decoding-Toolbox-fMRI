function pmat_dir = tdt_run_ttest(ttest)
%tdt_run_ttest Executable job that does ttests on permutations of decoding between 2 conditions (useful when only one subject to perform statistics).
%
% The core code of this function is an implementation of https://sites.google.com/site/tdtdecodingtoolbox/'
%
% SYNTAX
%       [pmat_dir] = tdt_run_ttest(ttest)
%       pmat_dir                        (char) : name of the directory of the first decoding results (with right labels)
%
%
% INPUTS
%       ttest.fname                     (char) : name of the output file
%       ttest.dcdg_dir                  (char) : path of the directory with cfg resulting from decoding
%       ttest.perm_dir                  (char) : name of the directory to write the results
%       ttest.options                   (char/int) : number of permutations you want to perform: set to 'all' for maximum permutations, or precise how many you want

if nargin==0, help(mfilename('fullpath')); return; end

fname_pvalue = ttest.fname_pvalue;
fname_inv_pvalue = ttest.fname_inv_pvalue;

fprintf('[%s]: Final output = %s / %s \n', mfilename, fname_pvalue, fname_inv_pvalue)

n_correct = [];
load(fullfile(ttest.dcdg_dir{1}, 'res_cfg.mat'))
outputname = cfg.results.output{1};
output_type = strsplit(outputname, '_');
output_type = output_type{1};
load(sprintf('%s/res_%s.mat', ttest.dcdg_dir{1}, outputname))
n_correct = results.(outputname).output;

reference = [];
cd(ttest.perm_dir{1})
ref = dir(sprintf('res_%s*.mat',output_type));

for perm = 1:length(ref)
    load (ref(perm).name);
    reference(:,perm) = results.AUC_minus_chance.output;
end

tail = ttest.options;

p = stats_permutation(n_correct,reference,tail);
one_minus_p=1-p;
save('p_value.mat','p');
save('1-p_value.mat','one_minus_p');

pmat_dir = cfg.results.dir;
end
