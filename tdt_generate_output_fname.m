function fname = tdt_dcdg_generate_output_fname(analysis, suffix )

if nargin < 2
    suffix = '';
end

if strcmpi(analysis ,'dcdg')
    fname = 'res_cfg.mat';
    
    % 2)
elseif strcmpi(analysis ,'perm')
    fname = 'res_cfg_perm.mat';
    
    % 3)
elseif strcmpi(analysis ,'ttest')
    fname = sprintf('%s.mat', suffix);
    
    % 4)
elseif strcmpi(analysis ,'nft')
    fname = sprintf('%s.nii', suffix);
    
end

end % function
