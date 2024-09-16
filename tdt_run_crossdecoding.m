function res_dir = tdt_run_crossdecoding(crossdcdg)
%tdt_run_decoding Executable job that decodes between 2 conditions for fMRI experiment.
%
% The core code of this function is an implementation of https://sites.google.com/site/tdtdecodingtoolbox/'
%
% SYNTAX
%       tdt_run_decoding(dcdg)
%
% INPUTS
%       crossdcdg.fname                  (char) : fullpath of the output file
%       crossdcdg.dir                    (char) : path of the directory with beta image
%       crossdcdg.conds.cond1            (char) : name of the first condition
%       crossdcdg.conds.cond2            (char) : name of the second condition
%       crossdcdg.conds.cond3            (char) : name of the third condition
%       crossdcdg.conds.cond4            (char) : name of the fourth condition
%       crossdcdg.labels                 ( int) : decoding design, which conditions you want to classify.
%       crossdcdg.xclass                 ( int) : xclass design, which conditions you train on, and which you want to generalize to.
%       crossdcdg.nrun                   ( int) : number of run/chunk in your experiment
%       crossdcdg.analysis               (    ) : type of analysis: searchlight/roi/wholebrain
%       crossdcdg.mask                   (char) : path to the mask to restrain analyses
%       crossdcdg.output                 (    ) : type of results: AUC or accuracy minus chance.

% See also tdt_cfg_matlabbatch
cfg = decoding_defaults;

if nargin==0, help(mfilename('fullpath')); return; end

fname = crossdcdg.fname;

fprintf('[%s]: Final output = %s \n', mfilename, fname)

nb_run = crossdcdg.options.nrun;

%--------------------------------------------------------------------------
% Identify beta localisation and conditions
%--------------------------------------------------------------------------

beta_loc            = crossdcdg.subj.dir{1};
regressor_names     = design_from_spm(beta_loc);
xclass              = crossdcdg.subj.xclass;
labels              = crossdcdg.subj.labels;
regmask             = regexp(regressor_names(1,:), 'R*');
regmask             = ~cellfun('isempty',regmask);
cond_names          = regressor_names(1,:);
cond_names(regmask) = [];
spmc_reg            = {'SPM constant'};
label_names         = setdiff(unique(cond_names(1,:)),spmc_reg);

labelname1 = crossdcdg.subj.conds.cond1;
if sum(~cellfun('isempty',regexp(label_names,labelname1))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one among: \n\n%s', label_names_disp);
    error(msge1);
end

labelname2 = crossdcdg.subj.conds.cond2;
if sum(~cellfun('isempty',regexp(label_names,labelname2))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one.');
    error(msge1);
end

labelname3 = crossdcdg.subj.conds.cond3;
if sum(~cellfun('isempty',regexp(label_names,labelname3))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one.');
    error(msge1);
end

labelname4 = crossdcdg.subj.conds.cond4;
if sum(~cellfun('isempty',regexp(label_names,labelname4))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one.');
    error(msge1);
end

cfg = decoding_describe_data(cfg,{labelname1 labelname2 labelname3 labelname4},[labels],regressor_names,beta_loc, [xclass]);

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
decod_cond(3) = find(ismember(label_names, labelname3));
decod_cond(4) = find(ismember(label_names, labelname4));
results_folder = sprintf('results_%d_%d_%d_%d_cross_decod', decod_cond);
cd(beta_loc)
files = dir;
dirFlags = [files.isdir];
subDirs = files(dirFlags);
cfg.results.overwrite = crossdcdg.options.overwrite;
cfg.design = make_design_xclass_cv(cfg);

%--------------------------------------------------------------------------
% Different other options
%--------------------------------------------------------------------------
if isempty(crossdcdg.subj.res_dir)
    res_dir = fullfile(beta_loc,results_folder);
else
    res_dir = fullfile(crossdcdg.subj.res_dir{1}, results_folder);
end

if issubfield(crossdcdg.options.anal,'searchlight')
    cfg.analysis = 'searchlight';
    cfg.searchlight.unit = crossdcdg.options.anal.searchlight.unit; % comment or set to 'voxels' if you want normal voxels
    cfg.searchlight.radius = crossdcdg.options.anal.searchlight.rad; % this will yield a searchlight radius of 12 units (here: mm).
    cfg.searchlight.spherical = 0;
    cfg.files.mask = crossdcdg.options.anal.searchlight.mask;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if isempty(crossdcdg.subj.res_dir) & ~strcmpi(nam,'mask')
        cfg.results.dir = sprintf('%s_in_mask_%s', res_dir,nam);
    else
        cfg.results.dir = res_dir;
    end
elseif issubfield(crossdcdg.options.anal,'ROI')
    cfg.analysis = 'ROI';
    cfg.files.mask = crossdcdg.options.anal.ROI.mask_roi;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if isempty(crossdcdg.subj.res_dir)
        cfg.results.dir = sprintf('%s_ROI_%s', res_dir,nam);
    else
        cfg.results.dir = sprintf('%s_ROI', res_dir);
    end
elseif issubfield(crossdcdg.options.anal,'wholebrain')
    cfg.analysis = 'wholebrain';
    cfg.files.mask = crossdcdg.options.anal.wholebrain.mask_wholebrain;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if isempty(crossdcdg.subj.res_dir)
        cfg.results.dir = sprintf('%s_wholebrain_%s', res_dir,nam);
    else
        cfg.results.dir = sprintf('%s_wholebrain', res_dir);
    end
end

if ~isdir(cfg.results.dir)
    mkdir(cfg.results.dir)
end

if strcmpi(crossdcdg.options.meth,'kernel')
    cfg.decoding.method = 'classification_kernel';
elseif strcmpi(crossdcdg.options.meth,'classif')
    cfg.decoding.method = 'classification';
elseif strcmpi(crossdcdg.options.meth,'regression')
    cfg.decoding.method = 'regression';
end

if strcmpi(crossdcdg.options.display,'yes')
    cfg.plot_design = 1;
    display_design(cfg);
else
    cfg.plot_design = 0;
end


if strcmpi(crossdcdg.options.analysis,'auc')
    cfg.results.output = 'AUC_minus_chance';
elseif strcmpi(crossdcdg.options.analysis,'accuracy')
    cfg.results.output = 'accuracy_minus_chance';
end

decoding(cfg);

res_dir = cfg.results.dir;

end
