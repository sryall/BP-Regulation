% This script calculates the steady state solution to the system using
% fsolve. Some previous values are used as an initial guess. These are
% taken from Jessica, which are taken in part from some paper (Karaaslan
% 2005?).

function [exitflag,imag] = solve_ss_numerical(human,gg,IG,varargin)
species = {'rat','human'};
gender     = {'male', 'female'};

%% Define default imputs
AA = 1;
ACEI = 0;
furosemide = 0;
NSAID = 0;
myo_ind = 0;
water_ind = 0;

%% Read and assign optional variables
for i = 1:2:length(varargin)
    if strcmp(varargin{i},'ACEI')
        ACEI = varargin{i + 1}; %ACEI indicator
    elseif strcmp(varargin{i},'furosemide')
        furosemide = varargin{i + 1}; %furosemide indicator
    elseif strcmp(varargin{i},'NSAID')
        NSAID = varargin{i+1}; %indicator
   elseif strcmp(varargin{i},'Myogenic Response')
        myo_ind = varargin{i+1}; %indicator 0 for normal, 1 for impaired
   elseif strcmp(varargin{i},'Water Intake')
        water_ind = varargin{i+1};%indicator 0 for normal, 1 for low
    elseif strcmp(varargin{i},'RSNA')
        AA = varargin{i+1}; %multiply N_rsna by to simulate hypertension
    end
end

%% Parameters
pars = get_pars(species{human+1},gender{gg},'',AA);

%% Drug Treatments
kappa_ACEI = 0;
kappa_f = 0;
kappa_f_md = 0;

if ACEI == 1
    kappa_ACEI = 0.76;
elseif ACEI > 1
    kappa_ACEI = 0.90;
end
if furosemide == 1
    kappa_f = 0.15;
    kappa_f_md = 0.4;
elseif furosemide ==2
    kappa_f = 0.3;
    kappa_f_md = 0.5;
end 

%% Variables initial guess

SS_data_struct = load(IG,'SSdata');
SS_data_IG = SS_data_struct.SSdata;

  if length(SS_data_IG) ==83
       SS_data_IG(84) = 0.126;
  end

% Order
% x  = [rsna; alpha_map; alpha_rap; R_r; beta_rsna; Phi_rb; Phi_gfilt; ...
%       P_f; P_gh; Sigma_tgf; Phi_filsod; Phi_ptsodreab; eta_ptsodreab; ...
%       gamma_filsod; gamma_at; gamma_rsna; Phi_mdsod; Phi_dtsodreab; ...
%       eta_dtsodreab; psi_al; Phi_dtsod; Phi_cdsodreab; eta_cdsodreab; ...
%       lambda_al; lambda_dt; lambda_anp; Phi_usod; Phi_win; V_ecf; V_b; P_mf; ...
%       Phi_vr; Phi_co; P_ra; vas; vas_f; vas_d; R_a; R_ba; R_vr; R_tp; ...
%       P_ma; epsilon_aum; a_auto; a_chemo; a_baro; C_adh; N_adh; ...
%       N_adhs; delta_ra; ; Phi_u; M_sod; ...
%       C_sod; nu_mdsod; nu_rsna; C_al; N_al; N_als; xi_ksod; xi_map; ...
%       xi_at; hatC_anp; AGT; nu_AT1; R_sec; PRC; PRA; AngI; AngII; ...
%       AT1R; AT2R; Ang17; AngIV; R_aa; R_ea; Sigma_myo; Psi_AT1RAA; ...
%       Psi_AT1REA; Psi_AT2RAA; Psi_AT2REA;...
%       Phi_sodin; Phi_twreab; mu_adh; mu_Na];

% Initial guess for the variables.
% Find the steady state solution, so the derivative is 0.
% Arbitrary value for time to input. (needs to be bigger than tchange + 30)
x0 = SS_data_IG; x_p0 = zeros(84,1); t = 2000;

%% Find steady state solution
tchange=0;
% 
%options = optimset(); options = optimset('Display','off');
options = optimset('Display','off','MaxFunEvals',8200+10000);
[SSdata, residual, ...
 exitflag, output] = fsolve(@(x) bp_reg_mod(t,x,x_p0,pars,tchange,...
                                            'ACEI',kappa_ACEI,'furosemide',[kappa_f,kappa_f_md],'NSAID',NSAID',...
                                            'Myogenic Response',myo_ind,'Water Intake',water_ind), ...
                            x0, options);


% %Check for imaginary solution.
if not (isreal(SSdata))
    %disp('Imaginary number returned.')
    imag = 1;
else
    imag = 0;
end

% Set any values that are within machine precision of 0 equal to 0.
for i = 1:length(SSdata)
    if abs(SSdata(i)) < eps*100
        SSdata(i) = 0;
    end
end

save_name_ending = '';
if water_ind
    save_name_ending = strcat(save_name_ending,'_lowwaterintake');
end
if myo_ind
    save_name_ending = strcat(save_name_ending,'_impairedmyo');
end


save_data_name = sprintf('%s_%s_ss_%s_%s_%s_rsna%s%s.mat', species{human+1},gender{gg},num2str(ACEI),num2str(furosemide),num2str(NSAID),num2str(AA),save_name_ending);
save_data_name = strcat('Data/', save_data_name);
save(save_data_name, 'SSdata', 'residual', 'exitflag', 'output')


end






























