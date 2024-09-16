function tdt_jobs = tdt_cfg_matlabbatch

%tdt_CFG_MATLABBATCH is the configurarion file for all jobs of the the decoding toolbox branch
% This file is executed by spm job/batch system
%
% See also spm_cfg tdt_matlabbatch_job_output 

addpath(spm_file(mfilename('fullpath'),'path'));

%% Make decoding

dcdg_overwrite         = cfg_menu;
dcdg_overwrite.tag     = 'overwrite';
dcdg_overwrite.name    = 'Overwrite';
dcdg_overwrite.help    = {
'If you want to overwrite your results, select 1.'
    };
dcdg_overwrite.labels = {'Yes', 'No'};
dcdg_overwrite.values = {1 0};
dcdg_overwrite.val    = {0};

%--------------------------------------------------------------------------
% nrun Number of run
%--------------------------------------------------------------------------
dcdg_nrun         = cfg_entry;
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
dcdg_rad.val     = {8};

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
dcdg_options.val  = {dcdg_nrun dcdg_anal dcdg_meth dcdg_out dcdg_disp dcdg_overwrite};
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
% path Path
%--------------------------------------------------------------------------
dcdg_resdir         = cfg_files;
dcdg_resdir.tag     = 'res_dir';
dcdg_resdir.name    = 'Results directory';
dcdg_resdir.help    = {'Select a directory where you want to write the results. Default will be the Beta directory.'};
dcdg_resdir.filter  = 'dir';
dcdg_resdir.ufilter = '.*';
dcdg_resdir.num     = [0 1];
dcdg_resdir.val     = {''};

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
dcdg_subj.val  = {dcdg_betaloc dcdg_resdir dcdg_conds};
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

%% Cross decoding
crossdcdg_overwrite         = cfg_menu;
crossdcdg_overwrite.tag     = 'overwrite';
crossdcdg_overwrite.name    = 'Overwrite';
crossdcdg_overwrite.help    = {
'If you want to overwrite your results, select 1.'
    };
crossdcdg_overwrite.labels = {'Yes', 'No'};
crossdcdg_overwrite.values = {1 0};
crossdcdg_overwrite.val    = {0};

%--------------------------------------------------------------------------
% nrun Number of run
%--------------------------------------------------------------------------
crossdcdg_nrun         = cfg_entry;
crossdcdg_nrun.tag     = 'nrun';
crossdcdg_nrun.name    = 'Number of run';
crossdcdg_nrun.help    = {
'How many run/chunks do you have in your experiment (the number of regressors you have for each condition, ex: Beta 1, Beta 6, Beta11, Beta16 for your first condition, in a experiment with 5 conditions and 4 runs).'
    };
crossdcdg_nrun.strtype = 'r';
crossdcdg_nrun.num     = [1  1];
crossdcdg_nrun.val     = {0};

%--------------------------------------------------------------------------
% wholebrain Wholebrain
%--------------------------------------------------------------------------
crossdcdg_mask_wholebrain         = cfg_files;
crossdcdg_mask_wholebrain.tag     = 'mask_wholebrain';
crossdcdg_mask_wholebrain.name    = 'Wholebrain Mask';
crossdcdg_mask_wholebrain.help    = {
    'Use mask in beta dir (e.g. SPM mask) as brain mask.'
    }';
crossdcdg_mask_wholebrain.filter  = 'nifti';
crossdcdg_mask_wholebrain.ufilter = '.*nii';
crossdcdg_mask_wholebrain.num     = [1 1];
crossdcdg_mask_wholebrain.preview = @(f) spm_check_registration(char(f));

crossdcdg_Wholebrain         = cfg_branch;
crossdcdg_Wholebrain.tag     = 'wholebrain';
crossdcdg_Wholebrain.name    = 'Wholebrain';
crossdcdg_Wholebrain.val     = {crossdcdg_mask_wholebrain};
crossdcdg_Wholebrain.help    = {
    'You must set a mask which will be used as a ROI'
    }';

%--------------------------------------------------------------------------
% roi ROI
%--------------------------------------------------------------------------
crossdcdg_mask_roi         = cfg_files;
crossdcdg_mask_roi.tag     = 'mask_roi';
crossdcdg_mask_roi.name    = 'ROI Mask';
crossdcdg_mask_roi.help    = {
    'This mask will be used as a ROI, and decoding will be done inside.'
    }';
crossdcdg_mask_roi.filter  = 'nifti';
crossdcdg_mask_roi.ufilter = '.*nii';
crossdcdg_mask_roi.num     = [1 1];
crossdcdg_mask_roi.preview = @(f) spm_check_registration(char(f));

crossdcdg_ROI         = cfg_branch;
crossdcdg_ROI.tag     = 'ROI';
crossdcdg_ROI.name    = 'ROI';
crossdcdg_ROI.val     = {crossdcdg_mask_roi};
crossdcdg_ROI.help    = {
    'You must set a mask which will be used as a ROI'
    }';

%--------------------------------------------------------------------------
% rad Radius of searchlight
%--------------------------------------------------------------------------
crossdcdg_unit         = cfg_menu;
crossdcdg_unit.tag     = 'unit';
crossdcdg_unit.name    = 'Unit';
crossdcdg_unit.help    = {'Units you want to use for your sphere: mm or vox.'};
crossdcdg_unit.labels = {
    'mm'
    'Voxel'
    }';
crossdcdg_unit.values = {
    'mm'
    'voxels'
    }';
crossdcdg_unit.val     = {'mm'};

%--------------------------------------------------------------------------
% crossdcdg Size of radius
%--------------------------------------------------------------------------

crossdcdg_rad         = cfg_entry;
crossdcdg_rad.tag     = 'rad';
crossdcdg_rad.name    = 'Radius';
crossdcdg_rad.help    = {'Radius size of the sphere within which you will decode.'};
crossdcdg_rad.strtype = 'r';
crossdcdg_rad.num     = [1  1];
crossdcdg_rad.val     = {8};

%--------------------------------------------------------------------------
% crossdcdg Mask for the searchlight decoding
%--------------------------------------------------------------------------

crossdcdg_mask         = cfg_files;
crossdcdg_mask.tag     = 'mask';
crossdcdg_mask.name    = 'Mask';
crossdcdg_mask.help    = {
    'This mask defines the volume in which you will perform decoding.'
    'Use mask in beta dir (e.g. SPM mask) as a mask.'
    }';
crossdcdg_mask.filter  = 'nifti';
crossdcdg_mask.ufilter = '.nii';
crossdcdg_mask.num     = [1 1];
crossdcdg_mask.preview = @(f) spm_check_registration(char(f));


crossdcdg_searchlight         = cfg_branch;
crossdcdg_searchlight.tag     = 'searchlight';
crossdcdg_searchlight.name    = 'Searchlight';
crossdcdg_searchlight.val     = {crossdcdg_unit crossdcdg_rad crossdcdg_mask};
crossdcdg_searchlight.help    = {
    'You may specify the radius of the searchlight (in voxels or mm).'
    }';

%--------------------------------------------------------------------------
% crossdcdg Analysis method
%--------------------------------------------------------------------------

crossdcdg_anal        = cfg_choice;
crossdcdg_anal.tag    = 'anal';
crossdcdg_anal.name   = 'Analysis method';
crossdcdg_anal.help   = {
    'Determines the type of analysis that is performed: searchlight, ROI or wholebrain (in this case, the whole brain will be considered as a "big" ROI.'
    ''
    'In the case of searchlight analysis, it will use a sphere of predefined radius, in which the searchlight will analyse the activation pattern'
    'ROI and wholebrain analyses will give you a variable, while searchlight analysis will give you a map of accuracy/AUC...'
    }';
crossdcdg_anal.values = { crossdcdg_searchlight crossdcdg_ROI crossdcdg_Wholebrain };
crossdcdg_anal.val    = {crossdcdg_searchlight};

%--------------------------------------------------------------------------
% crossdcdg Analysis method
%--------------------------------------------------------------------------

crossdcdg_meth        = cfg_menu;
crossdcdg_meth.tag    = 'meth';
crossdcdg_meth.name   = 'Decoding method';
crossdcdg_meth.help   = {
    'Choose the method you want to perform (classification or regression). If your classifier supports the kernel method (currently only libsvm), then you can also choose classification_kernel (our default).'
    'Classification kernel: this is our default anyway.'
    'Classification: this is slower, but sometimes necessary'
    'Regression: choose this for regression'
    }';
crossdcdg_meth.labels = {
    'Classification kernel'
    'Classification'
    'Regression'
    }';
crossdcdg_meth.values = {
    'kernel'
    'classif'
    'regression'
    }';
crossdcdg_meth.val    = {'kernel'};

%--------------------------------------------------------------------------
% crossdcdg Results output
%--------------------------------------------------------------------------

crossdcdg_out        = cfg_menu;
crossdcdg_out.tag    = 'analysis';
crossdcdg_out.name   = 'Analysis method';
crossdcdg_out.help   = {
    'Define which measures/transformations you like to get as ouput. You have the option to get different measures of the decoding. : you can get the accuracy for each voxel, the accuracy minus chance, or AUC minus chance.'
    }';
crossdcdg_out.labels = {
    'AUC minus chance'
    'Accuracy minus chance'
    }';
crossdcdg_out.values = {
    'auc'
    'accuracy'
    }';
crossdcdg_out.val    = {'auc'};

%--------------------------------------------------------------------------
% crossdcdg Display design
%--------------------------------------------------------------------------
crossdcdg_disp       = cfg_menu;
crossdcdg_disp.tag    = 'display';
crossdcdg_disp.name   = 'Display design';
crossdcdg_disp.help   = {
    }';
crossdcdg_disp.labels = {
    'Yes'
    'No'
    }';
crossdcdg_disp.values = {
    'yes'
    'no'
    }';
crossdcdg_disp.val    = {'no'};

%--------------------------------------------------------------------------
% doptions Decoding Options
%--------------------------------------------------------------------------
crossdcdg_options      = cfg_branch;
crossdcdg_options.tag  = 'options';
crossdcdg_options.name = 'Cross decoding Options';
crossdcdg_options.val  = {crossdcdg_nrun crossdcdg_anal crossdcdg_meth crossdcdg_out crossdcdg_disp crossdcdg_overwrite};
crossdcdg_options.help = {'Various settings for cross decoding.'};

%--------------------------------------------------------------------------
% path Path
%--------------------------------------------------------------------------
crossdcdg_betaloc         = cfg_files;
crossdcdg_betaloc.tag     = 'dir';
crossdcdg_betaloc.name    = 'Directory';
crossdcdg_betaloc.help    = {'Select a directory where you can find the Beta.'};
crossdcdg_betaloc.filter  = 'dir';
crossdcdg_betaloc.ufilter = '.*';
crossdcdg_betaloc.num     = [1 1];

%--------------------------------------------------------------------------
% path Path
%--------------------------------------------------------------------------
crossdcdg_resdir         = cfg_files;
crossdcdg_resdir.tag     = 'res_dir';
crossdcdg_resdir.name    = 'Results directory';
crossdcdg_resdir.help    = {'Select a directory where you want to write the results. Default will be the Beta directory.'};
crossdcdg_resdir.filter  = 'dir';
crossdcdg_resdir.ufilter = '.*';
crossdcdg_resdir.num     = [0 1];
crossdcdg_resdir.val     = {''};

%--------------------------------------------------------------------------
% conds Conditions to decode between
%--------------------------------------------------------------------------

crossdcdg_cond1         = cfg_entry;
crossdcdg_cond1.tag     = 'cond1';
crossdcdg_cond1.name    = 'First condition';
crossdcdg_cond1.help    = {'Enter the name of the first condition you want to decode (it has to be the same orthography as your Betas).'};
crossdcdg_cond1.strtype = 's';
crossdcdg_cond1.val     = {''};

crossdcdg_cond2         = cfg_entry;
crossdcdg_cond2.tag     = 'cond2';
crossdcdg_cond2.name    = 'Second condition';
crossdcdg_cond2.help    = {'Enter the name of the second condition you want to decode (it has to be the same orthography as your Betas).'};
crossdcdg_cond2.strtype = 's';
crossdcdg_cond2.val     = {''};

crossdcdg_cond3         = cfg_entry;
crossdcdg_cond3.tag     = 'cond3';
crossdcdg_cond3.name    = 'Third condition';
crossdcdg_cond3.help    = {'Enter the name of the second condition you want to decode (it has to be the same orthography as your Betas).'};
crossdcdg_cond3.strtype = 's';
crossdcdg_cond3.val     = {''};

crossdcdg_cond4         = cfg_entry;
crossdcdg_cond4.tag     = 'cond4';
crossdcdg_cond4.name    = 'Fourth condition';
crossdcdg_cond4.help    = {'Enter the name of the second condition you want to decode (it has to be the same orthography as your Betas).'};
crossdcdg_cond4.strtype = 's';
crossdcdg_cond4.val     = {''};


crossdcdg_conds      = cfg_branch;
crossdcdg_conds.tag  = 'conds';
crossdcdg_conds.name = 'Conditions';
crossdcdg_conds.val  = { crossdcdg_cond1 crossdcdg_cond2 crossdcdg_cond3 crossdcdg_cond4 };
crossdcdg_conds.help = {'Conditions to decode.'
    'You can order them in whatever order you want, you will have to specify the design of your cross decoding on "Xclass"'};

%--------------------------------------------------------------------------
% labels decoder design
%--------------------------------------------------------------------------
crossdcdg_cond_labels         = cfg_entry;
crossdcdg_cond_labels.tag     = 'labels';
crossdcdg_cond_labels.name    = 'Labels of the condition you want to classify';
crossdcdg_cond_labels.help    = {'Specify what conditions you want to classify.'
    'E.g. if you have conditions AX, BX, AY, BY, with the labels [1 -1 1 -1], you will classify cond. A vs cond. B.'};
crossdcdg_cond_labels.strtype = 'r';

%--------------------------------------------------------------------------
% xclass Xclass design
%--------------------------------------------------------------------------
crossdcdg_cond_xclass         = cfg_entry;
crossdcdg_cond_xclass.tag     = 'xclass';
crossdcdg_cond_xclass.name    = 'Design of the cross-validation';
crossdcdg_cond_xclass.help    = {'This variable is used to distinguish training and test data. Cross classification is performed from the lower to the higher number (e.g. from 1 to 2).'
    'For example, if you have 4 conditions AX, BX, AY, BY and want to classify A vs B in modality X and generalize (cross classify) in modality Y, enter [1 1 2 2].'};
crossdcdg_cond_xclass.strtype = 'r';
crossdcdg_cond_xclass.num     = [1 4];

%--------------------------------------------------------------------------
% subj Subject
%--------------------------------------------------------------------------

crossdcdg_subj      = cfg_branch;
crossdcdg_subj.tag  = 'subj';
crossdcdg_subj.name = 'Subject';
crossdcdg_subj.val  = {crossdcdg_betaloc crossdcdg_resdir crossdcdg_conds crossdcdg_cond_labels crossdcdg_cond_xclass};
crossdcdg_subj.help = {'Data for this subject. The same parameters are used within subject.'};

%--------------------------------------------------------------------------
% wsubjs Data
%--------------------------------------------------------------------------
crossdcdg_dsubjs        = cfg_repeat;
crossdcdg_dsubjs.tag    = 'wsubjs';
crossdcdg_dsubjs.name   = 'Data';
crossdcdg_dsubjs.help   = {'List of subjects.'};
crossdcdg_dsubjs.values = {crossdcdg_subj};
crossdcdg_dsubjs.num    = [1 Inf];


%--------------------------------------------------------------------------
% Cross decoding
%--------------------------------------------------------------------------
crossdcdg      = cfg_exbranch;
crossdcdg.tag  = 'crossdecod';
crossdcdg.name = 'Cross decoding';
crossdcdg.val  = {crossdcdg_dsubjs crossdcdg_options};
crossdcdg.help = {
    'Cross decoding performed via the decoding toolbox.'
    'If you want to perform cross decoding, select 1. For example, if you want to train  your decoder on conditions AX and BX, then decode on AY and BY.'
    }';

crossdcdg.prog = @prog_crossdcdg;
crossdcdg.vout = @vout_crossdcdg;

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
tdt_jobs.values  = { dcdg crossdcdg perm ttest nft };%nft

end

%==========================================================================
% dcdg
%==========================================================================

function out = prog_dcdg( job )

fname = tdt_generate_output_fname('dcdg' );

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
% crossdcdg
%==========================================================================

function out = prog_crossdcdg( job )

fname = tdt_generate_output_fname('crossdcdg' );

job.fname = fname;
res_dir = tdt_run_crossdecoding(job);

fname_cfg = fullfile(res_dir, fname);
fname_res_dir = res_dir;

% This output is for the Dependency system
out       = struct;
out.files = {fname_cfg fname_res_dir}; % <= this is the "target" of the Dependency
end % function

function dep = vout_crossdcdg( ~ )

dep                 = cfg_dep;
dep(1).sname        = 'Cross decoding results';
dep(1).src_output   = substruct('.','files', '()', {1});
dep(1).tgt_spec     = cfg_findspec({{'filter','mat','strtype','e'}});


dep(2).sname      = 'Result directory';
dep(2).src_output = substruct('.','files', '()', {2});
dep(2).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});
end % function

%==========================================================================
% perm
%==========================================================================

function out = prog_perm( job )

fname = tdt_generate_output_fname('perm' );
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

fname_pvalue = tdt_generate_output_fname('ttest', 'p_value' );
fname_inv_pvalue = tdt_generate_output_fname( 'ttest', '1-p_value' );

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
dep(1).src_output = substruct('.','files', '()', {1});
dep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

dep(2).sname      = '1 - T-test results';
dep(2).src_output = substruct('.','files', '()', {2});
dep(2).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

end % function

%==========================================================================
% nft
%==========================================================================

function out = prog_nft( job )

fname = tdt_generate_output_fname('nft', 'p_value' );

job.fname = fname;
[p_nifti one_minus_p_nifti] = tdt_run_nft(job);

% This output is for the Dependency system
out       = struct;
out.files = {p_nifti one_minus_p_nifti}; % <= this is the "target" of the Dependency

end % function

function dep = vout_nft( ~ )

dep            = cfg_dep;
dep(1).sname      = 'Nifti of p value';
dep(1).src_output = substruct('.','files', '()', {1});
dep(1).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep            = cfg_dep;
dep(2).sname      = 'Nifti of 1-p value';
dep(2).src_output = substruct('.','files', '()', {2});
dep(2).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

end % function
