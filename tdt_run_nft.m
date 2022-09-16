function [p_nifti one_minus_p_nifti] = tdt_run_nft(nft)
%tdt_run_ttest Executable job that does ttests on permutations of decoding between 2 conditions (useful when only one subject to perform statistics).
%
% The core code of this function is an implementation of https://sites.google.com/site/tdtdecodingtoolbox/'
%
% SYNTAX
%       tdt_run_nft(nft)
%
% INPUTS
%       nft.fname                   (char) : name of the output file
%       nft.ref                     (char) : path of the directory with cfg resulting from decoding, nifti headers will be taken from the beta.nii stored there.
%       nft.pmat                    (char) : name of the directory to write the results

if nargin==0, help(mfilename('fullpath')); return; end

fname = nft.fname;

load(nft.pmat{1});
load(nft.pmat{2});

fprintf('[%s]: Final output = %s \n', mfilename, fname)

load(fullfile(nft.dir{1},'res_cfg.mat'))

outputname = cfg.results.output{1};
output_type = strsplit(outputname, '_');
output_type = output_type{1};
load(fullfile(nft.dir{1}, sprintf('res_%s_minus_chance.mat',output_type)))

resultsvol_hdr = read_header(cfg.software,cfg.files.name{1}); % choose canonical hdr from first classification image
resultsvol_hdr = resultsvol_hdr(1); % in case we are dealing with a 4D volume
resultsvol_hdr2 = read_header(cfg.software,cfg.files.name{1}); % choose canonical hdr from first classification image
resultsvol_hdr2 = resultsvol_hdr2(1); % in case we are dealing with a 4D volume

% check that rotation matrices agree
if isfield(cfg.datainfo, 'mat')
    if isfield(resultsvol_hdr, 'mat')
        mat_diff = abs(cfg.datainfo.mat(:)-resultsvol_hdr.mat(:));
        tolerance = 32*eps(max(cfg.datainfo.mat(:)-resultsvol_hdr.mat(:)));
        if any(mat_diff > tolerance) % like isequal, but allows for rounding errors
            warningv('decoding_write_results:rotation_matrices_different', 'Rotation & translation matrix of image in file \n %s \n is different from rotation & translation matrix in cfg.\n The .mat entry defines rotation & translation of the image.\n That both differ means that at least one of both has been rotated.\n Please use reslicing (e.g. from SPM) to have all images in the same position.', resultsvol_hdr.fname)
            warningv('decoding_write_results:rotation_matrices_differentTODO', 'TODO: This should be fixed')
        end
    end
end

[pth,nam,~] = spm_fileparts(nft.pmat{1});
res_dir = pth;

n_outputs = length(cfg.results.output);
mask_index = results.mask_index;
for i_output = 1:n_outputs
    fname = sprintf('%s_%s',cfg.results.resultsname{i_output},'p_value.nii');
    fname2 = sprintf('%s_%s',cfg.results.resultsname{i_output},'1-p_value.nii');
    resultsvol_hdr.fname = fullfile(res_dir,fname);
    resultsvol_hdr2.fname =fullfile(res_dir,fname2);
    resultsvol_hdr.descrip = sprintf('%s decoding p value map',outputname);
    
    resultsvol = cfg.results.backgroundvalue * ones(resultsvol_hdr.dim(1:3));
    resultsvol(mask_index) = p;
    resultsvol2 = cfg.results.backgroundvalue * ones(resultsvol_hdr2.dim(1:3));
    resultsvol2(mask_index) = one_minus_p;
    
    if exist(resultsvol_hdr.fname,'file')
        if cfg.results.overwrite
            % simply overwrite the file
            warning('decoding_write_results:overwrite_results', 'Resultfile %s already existed. Overwriting it (because cfg.results.overwrite = 1). \n',resultsvol_hdr.fname)
        else
            % dont overwrite file, copy it
            [old_results_path, old_results_file, dummy_fext] = fileparts(resultsvol_hdr.fname);
            old_fname = fullfile(old_results_path, old_results_file);
            backup_fname = fullfile(old_results_path, [old_results_file, '_old_before_', datestr(now, 'yyyymmddTHHMMSS')]);
            warning('decoding_write_results:overwrite_results', 'Resultfile %s already existed. Copying old files %s to %s (because cfg.results.overwrite = 0)',resultsvol_hdr.fname, old_fname, backup_fname);
            
            for fext = {'.hdr', '.img', '.nii', '.BRIK', '.HEAD'}
                source = [old_fname, fext{1}];
                if ~exist(source,'file'), continue, end
                target = [backup_fname, fext{1}];
                dispv(1, 'Copying %s to %s', source, target)
                ignore = copyfile(source, target); %#ok<*NASGU> % output needed for linux bug
            end
        end
    end
    
    dispv(1,'Saving %s results to %s', cfg.decoding.method, resultsvol_hdr.fname)
    write_image(cfg.software,resultsvol_hdr,resultsvol);
    p_nifti = resultsvol_hdr.fname;
    dispv(1,'Saving %s results to %s', cfg.decoding.method, resultsvol_hdr2.fname)
    one_minus_p_nifti = resultsvol_hdr2.fname;
    write_image(cfg.software,resultsvol_hdr2,resultsvol2);
end

end
