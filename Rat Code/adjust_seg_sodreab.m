% This is the nephron submodel for segmented sodium reabsorption. This 
% script is used to adjust different fractional sodium reabsorption in the 
% proximal tubule, distal tubule, and collecting duct, after inputting the
% glomerular filtration rate and sodium concentration. Baseline fractional 
% sodium reabsorption in each segment for males is given by 
% Karaaslan - 2005. Females is given by adjust_frac_sodreab.m.

% Fixed quantities
% GFR, [Sod], Frac-PT-Sodreab, Frac-DT-Sodreab, Frac-CD-Sodreab

% Computed quantities
% PT-Sodreab, DT-Sodreab, CD-Sodreab
% MD-SodF, DT-SodF; U-SodF

function adjust_seg_sodreab

% Gender.
gender = {'male','female'};

for gg = 1:2 % gender

% Input GFR ml/min. Data from Munger - 1988.
if     strcmp(gender{gg},   'male')
    Phi_gfilt = 1.22;
elseif strcmp(gender{gg}, 'female')
    Phi_gfilt = 0.84;
end
% Input [Sod] micro Eq/ml.
C_sod = 143;

% Fractional sodium reabsorption in each segment. Values from Layton - 2016.
if     strcmp(gender{gg},   'male')
    eta_ptsodreab = 0.93;
    eta_dtsodreab = 0.77;
    eta_cdsodreab = 0.15;
elseif strcmp(gender{gg}, 'female')
    eta_ptsodreab = 0.500;
    eta_dtsodreab = 0.500;
    eta_cdsodreab = 0.972;
end

% Compute varying quantities.
Phi_filsod = Phi_gfilt * C_sod;
Phi_ptsodreab = Phi_filsod * eta_ptsodreab;
Phi_mdsod = Phi_filsod - Phi_ptsodreab;
Phi_dtsodreab = Phi_mdsod * eta_dtsodreab;
Phi_dtsod = Phi_mdsod - Phi_dtsodreab;
Phi_cdsodreab = Phi_dtsod * eta_cdsodreab;
Phi_usod = Phi_dtsod - Phi_cdsodreab;

vars = [eta_ptsodreab; eta_dtsodreab; eta_cdsodreab; ...
        Phi_ptsodreab; Phi_dtsodreab; Phi_cdsodreab; ...
        Phi_gfilt    ; Phi_filsod   ; Phi_mdsod    ; Phi_dtsod; Phi_usod];

save_data_name = sprintf('%s_seg_sodreab_vars.mat', gender{gg});
% save_data_name = strcat('Data/', save_data_name);
save(save_data_name, 'vars')

end % gender

end

























