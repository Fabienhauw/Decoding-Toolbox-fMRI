function tdt_jobs = tdt_cfg_matlabbatch

%tdt_CFG_MATLABBATCH is the configurarion file for all jobs of the the decoding toolbox branch
% This file is executed by spm job/batch system
%
% See also spm_cfg tdt_matlabbatch_job_output 

addpath(spm_file(mfilename('fullpath'),'path'));

%% Make decoding

%--------------------------------------------------------------------------
% nrun Number of run
%--------------------------------------------------------------------------
dcdg_nrun        = cfg_entry;
dcdg_nrun.tag     = 'nrun';
dcdg_nrun.name    = 'Number of run';
dcdg_nrun.help    = {
'How many run/chunks do you have in your experiment (the number of regressors you have for each condition, ex: Beta 1, Beta 6, Beta11, Beta16 for your first condition, in a experiment with 5 conditions and 4 runs).'
    };
dcdg_nrun.strtype = 'r';
dcdg_nrun.num     = [1  1];
dcdg_nrun.val     = {0};

%--------------------------------------------------------------------------
% wholebrain Wholebrain
%--------------------------------------------------------------------------
dcdg_mask_wholebrain         = cfg_files;
dcdg_mask_wholebrain.tag     = 'mask_wholebrain';
dcdg_mask_wholebrain.name    = 'Wholebrain Mask';
dcdg_mask_wholebrain.help    = {
    'Use mask in beta dir (e.g. SPM mask) as brain mask.'
    }';
dcdg_mask_wholebrain.filter  = 'nifti';
dcdg_mask_wholebrain.ufilter = '.*nii';
dcdg_mask_wholebrain.num     = [1 1];
dcdg_mask_wholebrain.preview = @(f) spm_check_registration(char(f));

dcdg_Wholebrain         = cfg_branch;
dcdg_Wholebrain.tag     = 'wholebrain';
dcdg_Wholebrain.name    = 'Wholebrain';
dcdg_Wholebrain.val     = {dcdg_mask_wholebrain};
dcdg_Wholebrain.help    = {
    'You must set a mask which will be used as a ROI'
    }';

%--------------------------------------------------------------------------
% roi ROI
%--------------------------------------------------------------------------
dcdg_mask_roi         = cfg_files;
dcdg_mask_roi.tag     = 'mask_roi';
dcdg_mask_roi.name    = 'ROI Mask';
dcdg_mask_roi.help    = {
    'This mask will be used as a ROI, and decoding will be done inside.'
    }';
dcdg_mask_roi.filter  = 'nifti';
dcdg_mask_roi.ufilter = '.*nii';
dcdg_mask_roi.num     = [1 1];
dcdg_mask_roi.preview = @(f) spm_check_registration(char(f));

dcdg_ROI         = cfg_branch;
dcdg_ROI.tag     = 'ROI';
dcdg_ROI.name    = 'ROI';
dcdg_ROI.val     = {dcdg_mask_roi};
dcdg_ROI.help    = {
    'You must set a mask which will be used as a ROI'
    }';

%--------------------------------------------------------------------------
% rad Radius of searchlight
%--------------------------------------------------------------------------
dcdg_unit         = cfg_menu;
dcdg_unit.tag     = 'unit';
dcdg_unit.name    = 'Unit';
dcdg_unit.help    = {'Units you want to use for your sphere: mm or vox.'};
dcdg_unit.labels = {
    'mm'
    'Voxel'
    }';
dcdg_unit.values = {
    'mm'
    'voxels'
    }';
dcdg_unit.val     = {'mm'};

%--------------------------------------------------------------------------
% dcdg Size of radius
%--------------------------------------------------------------------------

dcdg_rad         = cfg_entry;
dcdg_rad.tag     = 'rad';
dcdg_rad.name    = 'Radius';
dcdg_rad.help    = {'Radius size of the sphere within which you will decode.'};
dcdg_rad.strtype = 'r';
dcdg_rad.num     = [1  1];
dcdg_rad.val     = {12};

%--------------------------------------------------------------------------
% dcdg Mask for the searchlight decoding
%--------------------------------------------------------------------------

dcdg_mask         = cfg_files;
dcdg_mask.tag     = 'mask';
dcdg_mask.name    = 'Mask';
dcdg_mask.help    = {
    'This mask defines the volume in which you will perform decoding.'
    'Use mask in beta dir (e.g. SPM mask) as a mask.'
    }';
dcdg_mask.filter  = 'nifti';
dcdg_mask.ufilter = '.nii';
dcdg_mask.num     = [1 1];
dcdg_mask.preview = @(f) spm_check_registration(char(f));


dcdg_searchlight         = cfg_branch;
dcdg_searchlight.tag     = 'searchlight';
dcdg_searchlight.name    = 'Searchlight';
dcdg_searchlight.val     = {dcdg_unit dcdg_rad dcdg_mask};
dcdg_searchlight.help    = {
    'You may specify the radius of the searchlight (in voxels or mm).'
    }';

%--------------------------------------------------------------------------
% dcdg Analysis method
%--------------------------------------------------------------------------

dcdg_anal        = cfg_choice;
dcdg_anal.tag    = 'anal';
dcdg_anal.name   = 'Analysis method';
dcdg_anal.help   = {
    'Determines the type of analysis that is performed: searchlight, ROI or wholebrain (in this case, the whole brain will be considered as a "big" ROI.'
    ''
    'In the case of searchlight analysis, it will use a sphere of predefined radius, in which the searchlight will analyse the activation pattern'
    'ROI and wholebrain analyses will give you a variable, while searchlight analysis will give you a map of accuracy/AUC...'
    }';
dcdg_anal.values = { dcdg_searchlight dcdg_ROI dcdg_Wholebrain };
dcdg_anal.val    = {dcdg_searchlight};

%--------------------------------------------------------------------------
% dcdg Analysis method
%--------------------------------------------------------------------------

dcdg_meth        = cfg_menu;
dcdg_meth.tag    = 'meth';
dcdg_meth.name   = 'Decoding method';
dcdg_meth.help   = {
    'Choose the method you want to perform (classification or regression). If your classifier supports the kernel method (currently only libsvm), then you can also choose classification_kernel (our default).'
    'Classification kernel: this is our default anyway.'
    'Classification: this is slower, but sometimes necessary'
    'Regression: choose this for regression'
    }';
dcdg_meth.labels = {
    'Classification kernel'
    'Classification'
    'Regression'
    }';
dcdg_meth.values = {
    'kernel'
    'classif'
    'regression'
    }';
dcdg_meth.val    = {'kernel'};

%--------------------------------------------------------------------------
% dcdg Results output
%--------------------------------------------------------------------------

dcdg_out        = cfg_menu;
dcdg_out.tag    = 'analysis';
dcdg_out.name   = 'Analysis method';
dcdg_out.help   = {
    'Define which measures/transformations you like to get as ouput. You have the option to get different measures of the decoding. : you can get the accuracy for each voxel, the accuracy minus chance, or AUC minus chance.'
    }';
dcdg_out.labels = {
    'AUC minus chance'
    'Accuracy minus chance'
    }';
dcdg_out.values = {
    'auc'
    'accuracy'
    }';
dcdg_out.val    = {'auc'};

%--------------------------------------------------------------------------
% dcdg Display design
%--------------------------------------------------------------------------
dcdg_disp       = cfg_menu;
dcdg_disp.tag    = 'display';
dcdg_disp.name   = 'Display design';
dcdg_disp.help   = {
    }';
dcdg_disp.labels = {
    'Yes'
    'No'
    }';
dcdg_disp.values = {
    'yes'
    'no'
    }';
dcdg_disp.val    = {'no'};

%--------------------------------------------------------------------------
% doptions Decoding Options
%--------------------------------------------------------------------------
dcdg_options      = cfg_branch;
dcdg_options.tag  = 'options';
dcdg_options.name = 'Decoding Options';
dcdg_options.val  = {dcdg_nrun dcdg_anal dcdg_meth dcdg_out dcdg_disp};
dcdg_options.help = {'Various settings for decoding.'};

%--------------------------------------------------------------------------
% path Path
%--------------------------------------------------------------------------
dcdg_betaloc         = cfg_files;
dcdg_betaloc.tag     = 'dir';
dcdg_betaloc.name    = 'Directory';
dcdg_betaloc.help    = {'Select a directory where you can find the Beta.'};
dcdg_betaloc.filter  = 'dir';
dcdg_betaloc.ufilter = '.*';
dcdg_betaloc.num     = [1 1];

%--------------------------------------------------------------------------
% conds Conditions to decode between
%--------------------------------------------------------------------------

dcdg_cond1         = cfg_entry;
dcdg_cond1.tag     = 'cond1';
dcdg_cond1.name    = 'First condition';
dcdg_cond1.help    = {'Enter the name of the first condition you want to decode (at least 2 letters, but has to be the same orthography as your Betas).'};
dcdg_cond1.strtype = 's';
dcdg_cond1.val     = {''};

dcdg_cond2         = cfg_entry;
dcdg_cond2.tag     = 'cond2';
dcdg_cond2.name    = 'Second condition';
dcdg_cond2.help    = {'Enter the name of the second condition you want to decode (at least 2 letters, but has to be the same orthography as your Betas).'};
dcdg_cond2.strtype = 's';
dcdg_cond2.val     = {''};


dcdg_conds      = cfg_branch;
dcdg_conds.tag  = 'conds';
dcdg_conds.name = 'Conditions';
dcdg_conds.val  = { dcdg_cond1 dcdg_cond2 };
dcdg_conds.help = {'Conditions to decode.'};

%--------------------------------------------------------------------------
% subj Subject
%--------------------------------------------------------------------------

dcdg_subj      = cfg_branch;
dcdg_subj.tag  = 'subj';
dcdg_subj.name = 'Subject';
dcdg_subj.val  = {dcdg_betaloc dcdg_conds};
dcdg_subj.help = {'Data for this subject. The same parameters are used within subject.'};

%--------------------------------------------------------------------------
% wsubjs Data
%--------------------------------------------------------------------------
dcdg_dsubjs        = cfg_repeat;
dcdg_dsubjs.tag    = 'wsubjs';
dcdg_dsubjs.name   = 'Data';
dcdg_dsubjs.help   = {'List of subjects.'};
dcdg_dsubjs.values = {dcdg_subj};
dcdg_dsubjs.num    = [1 Inf];


%--------------------------------------------------------------------------
% Decoding
%--------------------------------------------------------------------------
dcdg      = cfg_exbranch;
dcdg.tag  = 'decod';
dcdg.name = 'Decoding';
dcdg.val  = {dcdg_dsubjs dcdg_options};
dcdg.help = {
    'Decoding performed via the decoding toolbox.'
    }';

dcdg.prog = @prog_dcdg;
dcdg.vout = @vout_dcdg;

%% Make permutations
%--------------------------------------------------------------------------
% Perm_number
%--------------------------------------------------------------------------
perm_num_all        = cfg_menu;
perm_num_all.tag    = 'all_perm';
perm_num_all.name   = 'All permutations';
perm_num_all.help   = {}';
perm_num_all.labels = {
    'All'
    }';
perm_num_all.values = {'all'};
perm_num_all.val     = {'all'};


perm_num_not_all         = cfg_entry;
perm_num_not_all.tag     = 'not_all_perm';
perm_num_not_all.name    = 'Number of permutations';
perm_num_not_all.help    = {
    'If you want less permutations than maximum possible, specify how many you want.'
    };
perm_num_not_all.strtype = 'r';
perm_num_not_all.num     = [1  1];
perm_num_not_all.val     = {1};



perm_options        = cfg_choice;
perm_options.tag    = 'options';
perm_options.name   = 'Number of permutations';
perm_options.help   = {
    'You may specify the number of permutations you want. If you want less permutations than maximum possible, specify how many you want.'
    }';
perm_options.values = {
    perm_num_all
    perm_num_not_all
    }';
perm_options.val    = {perm_num_all};

%--------------------------------------------------------------------------
% suffix_dir_res
%--------------------------------------------------------------------------
suffix_res_dir         = cfg_entry;
suffix_res_dir.tag     = 'suffix_res_dir';
suffix_res_dir.name    = 'Results directory name';
suffix_res_dir.help    = {'Enter the name of the results folder, which will be created within the directory you selected.'};
suffix_res_dir.strtype = 's';
suffix_res_dir.val     = {'perm'};

%--------------------------------------------------------------------------
% Perm_dir_res
%--------------------------------------------------------------------------
perm_dir_res         = cfg_files;
perm_dir_res.tag     = 'res_dir';
perm_dir_res.name    = 'Results directory path';
perm_dir_res.help    = {'Select a directory where you want to write the permutation results.'};
perm_dir_res.filter  = 'dir';
perm_dir_res.ufilter = '.*';
perm_dir_res.num     = [1 1];

%--------------------------------------------------------------------------
% Perm_dir
%--------------------------------------------------------------------------
res_cfg         = cfg_files;
res_cfg.tag     = 'res_cfg';
res_cfg.name    = 'CFG resulting from the decoding';
res_cfg.help    = {'Select the res_cfg.mat resulting from the decoding.'};
res_cfg.filter  = 'mat';
res_cfg.ufilter = '.*';
res_cfg.num     = [1 1];

%--------------------------------------------------------------------------
% Permutations
%--------------------------------------------------------------------------
perm = cfg_exbranch;
perm.tag = 'perm';
perm.name = 'Permutations';
perm.val ={ res_cfg perm_dir_res suffix_res_dir perm_options }; %perm_dir perm_num
perm.help = { 
    'Number of permutations you want to perform, if maximum possible, set "all".'
    }';

perm.prog = @prog_perm;
perm.vout = @vout_perm;

%% T-tests on your permutations
%--------------------------------------------------------------------------
% ttest
%--------------------------------------------------------------------------
ttest_options        = cfg_menu;
ttest_options.tag    = 'options';
ttest_options.name   = 'T-test tail';
ttest_options.help   = {}';
ttest_options.labels = {
    'Right'
    'Left'
    'Both'
    }';
ttest_options.values = {
    'right'
    'left'
    'both'
    }';
ttest_options.val    = {'right'};


ttest_perm_cfg         = cfg_files;
ttest_perm_cfg.tag     = 'perm_dir';
ttest_perm_cfg.name    = 'Permutation directory';
ttest_perm_cfg.help    = {'Select the directory where your permutation cfg and res_AUC/accuracy are stored (the one with mislabelled conditions).'};
ttest_perm_cfg.filter  = 'dir';
ttest_perm_cfg.ufilter = '.*';
ttest_perm_cfg.num     = [1 1];


ttest_correct_cfg         = cfg_files;
ttest_correct_cfg.tag     = 'dcdg_dir';
ttest_correct_cfg.name    = 'Decoding directory';
ttest_correct_cfg.help    = {'Select the directory where your decoding cfg is stored (the first with right labelled conditions).'};
ttest_correct_cfg.filter  = 'dir';
ttest_correct_cfg.ufilter = '.*';
ttest_correct_cfg.num     = [1 1];


ttest = cfg_exbranch;
ttest.tag = 'ttest';
ttest.name = 'T-test';
ttest.val ={ ttest_correct_cfg ttest_perm_cfg ttest_options}; %perm_dir perm_num
ttest.help = { 
    'To perform a t-test on your data.'
    }';

ttest.prog = @prog_ttest;
ttest.vout = @vout_ttest;

%% Nifti writing of the pvalue.mat
%--------------------------------------------------------------------------
% Nifti writing
%--------------------------------------------------------------------------
nft_pmat         = cfg_files;
nft_pmat.tag     = 'pmat';
nft_pmat.name    = 'p_value .mat files';
nft_pmat.help    = {'Select the .mat file with p_values and/or 1-p_value stored.'};
nft_pmat.filter  = 'mat';
nft_pmat.ufilter = '.*';
nft_pmat.num     = [1 2];


nft_ref         = cfg_files;
nft_ref.tag     = 'dir';
nft_ref.name    = 'Directory';
nft_ref.help    = {'Select the directory where your decoding cfg is stored (the first with right labelled conditions). Nifti headers will be taken from the beta.nii stored inside.'};
nft_ref.filter  = 'dir';
nft_ref.ufilter = '.*';
nft_ref.num     = [1 1];


nft = cfg_exbranch;
nft.tag = 'nft';
nft.name = 'Nifti writing';
nft.val ={ nft_ref nft_pmat }; % 
nft.help = { 
    'To write nifti map from the p_value/1-p_value.mat file.'
    }';

nft.prog = @prog_nft;
nft.vout = @vout_nft;

%% Main : extension entry point

%--------------------------------------------------------------------------
% TDT : extension entry point
%--------------------------------------------------------------------------
% This is the menue on the batch editor : SPM > Tools > The Decoding
% Toolbox

tdt_jobs        = cfg_choice;
tdt_jobs.tag    = 'tdt';
tdt_jobs.name   = 'The Decoding Toolbox';
tdt_jobs.help   = {
    'This extension is an implementation of https://sites.google.com/site/tdtdecodingtoolbox/'
    };
tdt_jobs.values  = { dcdg perm ttest nft };%nft

end

%==========================================================================
% dcdg
%==========================================================================

function out = prog_dcdg( job )

fname = tdt_generate_output_fname( job, 'dcdg' );

job.fname = fname;
res_dir = tdt_run_decoding(job);

fname_cfg = fullfile(res_dir, fname);
fname_res_dir = res_dir;

% This output is for the Dependency system
out       = struct;
out.files = {fname_cfg fname_res_dir}; % <= this is the "target" of the Dependency
% out.dir = {fname_res_dir}; % <= this is the "target" of the Dependency
end % function

function dep = vout_dcdg( ~ )

dep            = cfg_dep;
dep(1).sname      = 'Decoding results';
dep(1).src_output = substruct('.','files', '()', {1});
dep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});


dep(2).sname      = 'Result directory';
dep(2).src_output = substruct('.','files', '()', {2}); %le pb semble venir de la fonction run des permutations, qui a besoin de certains champs dans son objet...
dep(2).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});
end % function

%==========================================================================
% perm
%==========================================================================

function out = prog_perm( job )

fname = tdt_generate_output_fname( job, 'perm' );
job.fname = fname;

perm_res_dir = tdt_run_permutations(job);
fname_cfg_perm = fullfile(perm_res_dir, fname);
fname_res_dir_perm = perm_res_dir;

% This output is for the Dependency system
out       = struct;
out.files = {fname fname_res_dir_perm}; % <= this is the "target" of the Dependency
% out.dir = {fname_res_dir_perm}; % <= this is the "target" of the Dependency
end % function

function dep = vout_perm( ~ )

dep            = cfg_dep;
dep(1).sname      = 'Permutation results CFG';
dep(1).src_output = substruct('.','files', '()', {1});
dep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

dep(2).sname      = 'Result directory';
dep(2).src_output = substruct('.','files', '()', {2});
dep(2).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

end % function

%==========================================================================
% ttest
%==========================================================================

function out = prog_ttest( job )

fname_pvalue = tdt_generate_output_fname( job, 'ttest', 'p_value' );
fname_inv_pvalue = tdt_generate_output_fname( job, 'ttest', '1-p_value' );

job.fname_pvalue        = fname_pvalue;
job.fname_inv_pvalue    = fname_inv_pvalue;

pmat_dir = tdt_run_ttest(job);


fname_pvalue            = fullfile(pmat_dir, fname_pvalue);
fname_inv_pvalue        = fullfile(pmat_dir, fname_inv_pvalue);
% This output is for the Dependency system
out                     = struct;
out.files               = {fname_pvalue fname_inv_pvalue}; % <= this is the "target" of the Dependency

end % function

function dep = vout_ttest( ~ )

dep            = cfg_dep;
dep(1).sname      = 'T-test results';
dep(1).src_output = substruct('.','files');
dep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

dep(2).sname      = '1 - T-test results';
dep(2).src_output = substruct('.','files', '()', {2});
dep(2).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

end % function

%==========================================================================
% nft
%==========================================================================

function out = prog_nft( job )

fname = tdt_generate_output_fname( job, 'nft', 'p_value' );

job.fname = fname;
[p_nifti one_minus_p_nifti] = tdt_run_nft(job);

% This output is for the Dependency system
out       = struct;
out.files = {p_nifti one_minus_p_nifti}; % <= this is the "target" of the Dependency

end % function

function dep = vout_nft( ~ )

dep            = cfg_dep;
dep(1).sname      = 'Nifti of p value';
dep(1).src_output = substruct('.','files');
dep(1).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep            = cfg_dep;
dep(2).sname      = 'Nifti of 1-p value';
dep(2).src_output = substruct('.','files');
dep(2).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

end % function
