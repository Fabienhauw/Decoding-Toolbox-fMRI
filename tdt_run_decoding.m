function res_dir = tdt_run_decoding(dcdg)
%tdt_run_decoding Executable job that decodes between 2 conditions for fMRI experiment.
%
% The core code of this function is an implementation of https://sites.google.com/site/tdtdecodingtoolbox/'
%
% SYNTAX
%       tdt_run_decoding(dcdg)
%
% INPUTS
%       dcdg.fname                  (char) : fullpath of the output file
%       dcdg.dir                    (char) : path of the directory with beta image
%       dcdg.conds.cond1            (char) : name of the first condition
%       dcdg.conds.cond2            (char) : name of the second condition
%       dcdg.labels                 ( int) : decoding design, which conditions you want to classify.
%       dcdg.nrun                   ( int) : number of run/chunk in your experiment
%       dcdg.analysis               (    ) : type of analysis: searchlight/roi/wholebrain
%       dcdg.mask                   (char) : path to the mask to restrain analyses
%       dcdg.output                 (    ) : type of results: AUC or accuracy minus chance.

% See also tdt_cfg_matlabbatch
cfg = decoding_defaults;

if nargin==0, help(mfilename('fullpath')); return; end

fname = dcdg.fname;

fprintf('[%s]: Final output = %s \n', mfilename, fname)

nb_run = dcdg.options.nrun;

%--------------------------------------------------------------------------
% Identify beta localisation and conditions
%--------------------------------------------------------------------------

beta_loc            = dcdg.subj.dir{1};
regressor_names     = design_from_spm(beta_loc);
labels              = dcdg.subj.labels.num;
regmask             = regexp(regressor_names(1,:), 'R*');
regmask             = ~cellfun('isempty',regmask);
cond_names          = regressor_names(1,:);
cond_names(regmask) = [];
spmc_reg            = {'SPM constant'};
label_names         = setdiff(unique(cond_names(1,:)),spmc_reg);

labelname1 = dcdg.subj.conds.cond1;
if sum(~cellfun('isempty',regexp(label_names,labelname1))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one among: \n\n%s', label_names_disp);
    error(msge1);
end

labelname2 = dcdg.subj.conds.cond2;
if sum(~cellfun('isempty',regexp(label_names,labelname2))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one.');
    error(msge1);
end

cfg = decoding_describe_data(cfg,{labelname1 labelname2},[labels],regressor_names,beta_loc);

tmp_run = 0;
for i = 1 : size(cfg.files.name, 1)
    if tmp_run < nb_run
        tmp_run = tmp_run + 1;
    else
        tmp_run = 1;
    end
    cfg.files.chunk(i) = tmp_run;
end


%--------------------------------------------------------------------------
% Defining the res directory
%--------------------------------------------------------------------------
decod_cond(1) = find(ismember(label_names, labelname1));
decod_cond(2) = find(ismember(label_names, labelname2));
results_folder = sprintf('results_%d_vs_%d_decod', labelname1, labelname2);
cd(beta_loc)
files = dir;
dirFlags = [files.isdir];
subDirs = files(dirFlags);
cfg.results.overwrite = dcdg.options.overwrite.val;
cfg.design = make_design_cv(cfg);

%--------------------------------------------------------------------------
% Different other options
%--------------------------------------------------------------------------
if isempty(dcdg.subj.res_dir)
    res_dir = fullfile(beta_loc,results_folder);
else
    res_dir = fullfile(dcdg.subj.res_dir{1}, results_folder);
end

if issubfield(dcdg.options.anal,'searchlight')
    cfg.analysis = 'searchlight';
    cfg.searchlight.unit = dcdg.options.anal.searchlight.unit; % comment or set to 'voxels' if you want normal voxels
    cfg.searchlight.radius = dcdg.options.anal.searchlight.rad; % this will yield a searchlight radius of 12 units (here: mm).
    cfg.searchlight.spherical = 0;
    cfg.files.mask = dcdg.options.anal.searchlight.mask;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if isempty(dcdg.subj.res_dir) & ~strcmpi(nam,'mask')
        cfg.results.dir = sprintf('%s_in_mask_%s', res_dir,nam);
    else
        cfg.results.dir = res_dir;
    end
elseif issubfield(dcdg.options.anal,'ROI')
    cfg.analysis = 'ROI';
    cfg.files.mask = dcdg.options.anal.ROI.mask_roi;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if isempty(dcdg.subj.res_dir)
        cfg.results.dir = sprintf('%s_ROI_%s', res_dir,nam);
    else
        cfg.results.dir = sprintf('%s_ROI', res_dir);
    end
elseif issubfield(dcdg.options.anal,'wholebrain')
    cfg.analysis = 'wholebrain';
    cfg.files.mask = dcdg.options.anal.wholebrain.mask_wholebrain;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if isempty(dcdg.subj.res_dir)
        cfg.results.dir = sprintf('%s_wholebrain_%s', res_dir,nam);
    else
        cfg.results.dir = sprintf('%s_wholebrain', res_dir);
    end
end

if ~isdir(cfg.results.dir)
    mkdir(cfg.results.dir)
end

if strcmpi(dcdg.options.meth,'kernel')
    cfg.decoding.method = 'classification_kernel';
elseif strcmpi(dcdg.options.meth,'classif')
    cfg.decoding.method = 'classification';
elseif strcmpi(dcdg.options.meth,'regression')
    cfg.decoding.method = 'regression';
end

if strcmpi(dcdg.options.display,'yes')
    cfg.plot_design = 1;
    display_design(cfg);
else
    cfg.plot_design = 0;
end


if strcmpi(dcdg.options.analysis,'auc')
    cfg.results.output = 'AUC_minus_chance';
elseif strcmpi(dcdg.options.analysis,'accuracy')
    cfg.results.output = 'accuracy_minus_chance';
end

decoding(cfg);

res_dir = cfg.results.dir;

end
