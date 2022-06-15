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

beta_loc = dcdg.subj.dir{1};
regressor_names = design_from_spm(beta_loc);
regmask = regexp(regressor_names(1,:), 'R*');
regmask = ~cellfun('isempty',regmask);
cond_names = regressor_names(1,:);
cond_names(regmask) = [];
spmc_reg = {'SPM constant'};
label_names = setdiff(unique(cond_names(1,:)),spmc_reg);
label_names_disp = label_names{1};
for ln = 1 : length(label_names)-1
    label_names_disp = [label_names_disp ', ' label_names{ln+1}];
end

labelname1 = dcdg.subj.conds.cond1;
labelname1bis = sprintf('%s%s', '\w*',labelname1, '\w*');
if sum(~cellfun('isempty',regexp(label_names,labelname1bis))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one among: \n\n%s', label_names_disp);
    error(msge1);
    error(label_names_disp);
end
labelname2 = dcdg.subj.conds.cond2;
labelname2bis = sprintf('%s%s', '\w*',labelname2, '\w*');
if sum(~cellfun('isempty',regexp(label_names,labelname2bis))) == 0
    msge1 = sprintf('This label name does not exist, please be careful to the case and re-enter a new one.');
    error(msge1);
    remaining_label_names = cellfun(@setdiff, label_names, regexp(label_names,labelname1bis,'match'), 'UniformOutput',false)';
    remaining_label_names = [remaining_label_names{:}]
end

common_labelname1 = regexp(label_names,labelname1bis,'match');
idx = ~cellfun(@isempty,common_labelname1);
partial_labelname1 = [common_labelname1{idx}];

final_labelname1 = [];

if length(partial_labelname1)>1
    j = ismember(partial_labelname1{1}, partial_labelname1{2});
    for i=1:length(j)
        if j(i) == 1
            final_labelname1 = [final_labelname1 partial_labelname1{1}(i)];
            if i<length(j) & j(i+1)==0
                break
            end
        end
    end
else
    final_labelname1 = partial_labelname1{1};
end

common_labelname2 = regexp(label_names,labelname2bis,'match');
idx = ~cellfun(@isempty,common_labelname2);
partial_labelname2 = [common_labelname2{idx}];

final_labelname2 = [];

if length(partial_labelname2)>1
    j = ismember(partial_labelname2{1}, partial_labelname2{2});
    for i=1:length(j)
        if j(i) == 1
            final_labelname2 = [final_labelname2 partial_labelname2{1}(i)];
            if i<length(j) & j(i+1)==0
                break
            end
        end
    end
else
    final_labelname2 = partial_labelname2{1};
end

labelname1 = sprintf('%s%s','*',labelname1, '*');
labelname2 = sprintf('%s%s','*',labelname2, '*');
cfg = decoding_describe_data(cfg,{labelname1 labelname2},[1 -1],regressor_names,beta_loc);

nb_chunk_1 = length(find(cfg.files.label == 1));
nb_chunk_2 = length(find(cfg.files.label == -1));

nb_cond_1 = nb_chunk_1/nb_run;
nb_cond_2 = nb_chunk_2/nb_run;

for i = 1:nb_run*nb_cond_1
    cfg.files.chunk(i)= ceil(i/nb_cond_1);
end
for i = (nb_chunk_1)+1:(nb_chunk_1)+nb_chunk_2
    cfg.files.chunk(i)= ceil((i-(nb_chunk_1))/nb_cond_2);
end

%--------------------------------------------------------------------------
% Defining the res directory
%--------------------------------------------------------------------------
results_folder = sprintf('results_%s_vs_%s', final_labelname1, final_labelname2);
results_fold_inv = sprintf('results_%s_vs_%s', final_labelname2, final_labelname1);
cd(beta_loc)
files = dir;
dirFlags = [files.isdir];
subDirs = files(dirFlags);
for dirname = 1 : length(subDirs)
    if ~isempty(regexp(subDirs(dirname).name,results_fold_inv))
        results_folder=results_fold_inv;
        fprintf('This analysis already exists, with %s labelled Condition1 and inversely (same decoding). Overwriting in the corresponding folder', final_labelname2)
    end
end
cfg.results.overwrite = 1;
cfg.design = make_design_cv(cfg);

%--------------------------------------------------------------------------
% Different other options
%--------------------------------------------------------------------------
if issubfield(dcdg.options.anal,'searchlight')
    cfg.analysis = 'searchlight';
    cfg.searchlight.unit = dcdg.options.anal.searchlight.unit; % comment or set to 'voxels' if you want normal voxels
    cfg.searchlight.radius = dcdg.options.anal.searchlight.rad; % this will yield a searchlight radius of 12 units (here: mm).
    cfg.searchlight.spherical = 0;
    cfg.files.mask = dcdg.options.anal.searchlight.mask;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    if ~strcmpi(nam,'mask')
        cfg.results.dir = sprintf('%s_%s', fullfile(beta_loc,results_folder),nam);
    else
        cfg.results.dir = fullfile(beta_loc,results_folder);
    end
elseif issubfield(dcdg.options.anal,'ROI')
    cfg.analysis = 'ROI';
    cfg.files.mask = dcdg.options.anal.ROI.mask_roi;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    cfg.results.dir = sprintf('%s_ROI_%s', fullfile(beta_loc,results_folder, nam));
elseif issubfield(dcdg.options.anal,'wholebrain')
    cfg.analysis = 'wholebrain';
    cfg.files.mask = dcdg.options.anal.wholebrain.mask_wholebrain;
    [pth,nam,~] = spm_fileparts(cfg.files.mask{1});
    cfg.results.dir = sprintf('%s_wholebrain_%s', fullfile(beta_loc,results_folder, nam));
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
