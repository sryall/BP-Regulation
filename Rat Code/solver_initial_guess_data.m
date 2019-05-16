% Baseline steady state data for the variables is given by Jessica's code
% in folder 01_ang_inf. Copy those data files to the folder Data in this 
% directory. Then run this script.
% 
% This script reodrders the variables in the data to fit the order of the
% variables in the code in this directory. It then saves it with a suitable
% name.

function solver_initial_guess_data

gender = {'male', 'female'};

for gg = 1:1 % gender

% Scaling factor
% Rat flow = Human flow x SF
if     strcmp(gender{gg}, 'male')
    SF = 4.5*10^(-3)*10^(3);
elseif strcmp(gender{gg}, 'female')
    SF = 2/3 * 4.5*10^(-3)*10^(3);
end

%% Manual entry of values
rsna          = 1; 
alpha_map     = 100; 
alpha_rap     = 1; 
R_r           = 18.58; 
beta_rsna     = 1; 
Phi_rb        = 5.495; 
% Phi_gfilt     = 0.6274; 
Phi_gfilt     = 1.22; 
P_f           = 16; 
P_gh          = 62; 
Sigma_tgf     = 3.859 * SF; 

Phi_filsod    = Phi_gfilt * 143; 
Phi_ptsodreab = Phi_filsod * 0.93; 
eta_ptsodreab = 0.93; 
gamma_filsod  = 14 * SF; 
gamma_at      = 1; 
gamma_rsna    = 1; 
Phi_mdsod     = Phi_filsod - Phi_ptsodreab; 
Phi_dtsodreab = Phi_mdsod * 0.77; 
eta_dtsodreab = 0.77; 
psi_al        = 1; 
Phi_dtsod     = Phi_mdsod - Phi_dtsodreab; 
Phi_cdsodreab = Phi_dtsod * 0.15; 
eta_cdsodreab = 0.15; 
lambda_dt     = 2.03 * SF; 
lambda_anp    = 1;

lambda_al     = 1;

% Phi_usod      = 1.2278; 
Phi_usod      = 2.3875; 

% Phi_win       = 0.0086; 
Phi_win       = 0.0150;
V_ecf         = 61; 
V_b           = 21; 
P_mf          = 7; 
Phi_vr        = 21; 
Phi_co        = 21; 
P_ra          = 0; 
vas           = 1; 
vas_f         = 1.14e-05; 
vas_d         = 1.14e-05; 
R_a           = 4; 
R_ba          = 3.2; 
R_vr          = 0.32; 
R_tp          = 4.7; 
P_ma          = 100; 
epsilon_aum   = 1; 
a_auto        = 0.011; 
a_chemo       = 0.24; 
a_baro        = 1; 
C_adh         = 4.2; 
N_adh         = 1; 
N_adhs        = 141; 
delta_ra      = 0; 

Phi_ptwreab   = Phi_gfilt * 0.86; 
eta_ptwreab   = 0.86; 
mu_ptsodreab  = 1; 
Phi_mdu       = Phi_gfilt - Phi_ptwreab; 
Phi_dtwreab   = Phi_mdu * 0.60; 
eta_dtwreab   = 0.60; 
mu_dtsodreab  = 1; 
Phi_dtu       = Phi_mdu - Phi_dtwreab; 
Phi_cdwreab   = Phi_dtu * 0.78; 
eta_cdwreab   = 0.78; 
mu_cdsodreab  = 1; 
mu_adh        = 0.46; 
% Phi_u         = 0.0086; 
Phi_u         = 0.0150;

M_sod         = 8818; 
C_sod         = 143; 
nu_mdsod      = 1.731 * SF; 
nu_rsna       = 1; 
C_al          = 110; 
N_al          = 1; 
N_als         = 1; 
xi_ksod       = 23.6; 
xi_map        = 1; 
xi_at         = 1; 
hatC_anp      = 1; 
AGT           = 576005; 
nu_AT1        = 1; 
R_sec         = 1; 
PRC           = 17; 
PRA           = 135; 
AngI          = 90; 
AngII         = 6; 
AT1R          = 20; 
AT2R          = 7; 
Ang17         = 50; 
AngIV         = 1.3; 
R_aa          = 7; 
R_ea          = 11; 
Sigma_myo     = 62; 
Psi_AT1RAA    = 1; 
Psi_AT1REA    = 1; 
Psi_AT2RAA    = 1; 
Psi_AT2REA    = 1; 
%%

% Order
x  = [rsna; alpha_map; alpha_rap; R_r; beta_rsna; Phi_rb; Phi_gfilt; ...
      P_f; P_gh; Sigma_tgf; Phi_filsod; Phi_ptsodreab; eta_ptsodreab; ...
      gamma_filsod; gamma_at; gamma_rsna; Phi_mdsod; Phi_dtsodreab; ...
      eta_dtsodreab; psi_al; Phi_dtsod; Phi_cdsodreab; eta_cdsodreab; ...
      lambda_dt; lambda_anp; lambda_al; Phi_usod; Phi_win; V_ecf; V_b; ...
      P_mf; Phi_vr; Phi_co; P_ra; vas; vas_f; vas_d; R_a; R_ba; R_vr; ...
      R_tp; P_ma; epsilon_aum; a_auto; a_chemo; a_baro; C_adh; N_adh; ...
      N_adhs; delta_ra; Phi_ptwreab; eta_ptwreab; mu_ptsodreab; ...
      Phi_mdu; Phi_dtwreab; eta_dtwreab; mu_dtsodreab; Phi_dtu; ...
      Phi_cdwreab; eta_cdwreab; mu_cdsodreab; mu_adh; Phi_u; M_sod; ...
      C_sod; nu_mdsod; nu_rsna; C_al; N_al; N_als; xi_ksod; xi_map; ...
      xi_at; hatC_anp; AGT; nu_AT1; R_sec; PRC; PRA; AngI; AngII; ...
      AT1R; AT2R; Ang17; AngIV; R_aa; R_ea; Sigma_myo; Psi_AT1RAA; ...
      Psi_AT1REA; Psi_AT2RAA; Psi_AT2REA];

SSdataIG = x;

save_data_name = sprintf('%s_ss_data_IG.mat', gender{gg});
save_data_name = strcat('Data/', save_data_name);
save(save_data_name, 'SSdataIG')

end % gender

end
























