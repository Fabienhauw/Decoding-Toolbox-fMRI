function perm_res_dir = tdt_run_permutation(perm)
%tdt_run_permutation Executable job that does permutations between 2 conditions for fMRI experiment (useful when only one subject to perform statistics).
%
% The core code of this function is an implementation of https://sites.google.com/site/tdtdecodingtoolbox/'
%
% SYNTAX
%       tdt_run_permutation(perm)
%
% INPUTS
%       perm.fname                  (char) : fullpath of the output file
%       perm.res_cfg                (char) : path of the directory with cfg resulting from decoding
%       perm.res_dir                (char) : name of the directory to write the results
%       perm.perm.number            (char) : number of permutations you want to perform: set to 'all' for maximum permutations, or precise how many you want

if nargin==0, help(mfilename('fullpath')); return; end

fname = perm.fname;

fprintf('[%s]: Final output = %s \n', mfilename, fname)

load(perm.res_cfg{1})
cfg = rmfield(cfg,'design'); % this is needed if you previously used cfg.
cfg.design.function.name = 'make_design_cv';


if issubfield(perm.options, 'all_perm')
    cfg.permute.n_perms_select = 'all';
elseif issubfield(perm.options, 'not_all_perm')
    cfg.permute.n_perms_select = perm.options.not_all_perm;
end

cfg.permute.combine = 1;
[designs, all_perms] = make_design_permutation(cfg);
cfg.design = make_design_permutation(cfg);

if cfg.analysis == 'searchlight'
    cfg.results.dir = fullfile(perm.res_dir{1}, perm.suffix_res_dir);
elseif cfg.analysis == 'ROI'
    cfg.results.dir = fullfile(perm.res_dir{1}, perm.suffix_res_dir, 'roi');
elseif cfg.analysis == 'wholebrain'
    cfg.results.dir = fullfile(perm.res_dir{1}, perm.suffix_res_dir, 'wholebrain');
end

% decoding(cfg); % run permutation


perm_res_dir = cfg.results.dir;

end
