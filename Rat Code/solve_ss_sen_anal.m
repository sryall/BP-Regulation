% This script performs local sensitivty analysis by calculating the steady 
% state solution to the system using fsolve. 
% Some previous values are used as an initial guess

% function SSdata = solve_ss
function solve_ss_sen_anal

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Begin user input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input of interest
% N_rsna     - par 1 ; -30%, +30%
% N_als      - par 18; -30%, +30%
% N_rs       - par 21; -30%, +30%
% R_aass     - par 2 ; -50%, +250%
% R_eass     - par 3 ; -50%, +250%
% c_ACE      - par 32; -50%, +50%
% c_AT1R     - par 37; -50%, +50%
% c_AT2R     - par 38; -50%, +50%
% % Psi_AT2RAA - par 41; -50%, +50%
% % Psi_AT2REA - par 42; -50%, +50%
in_ind      = [1;18;21;2;3;32;37;38];
range_lower = [30;30;30;50 ;50 ;50;50;50];
range_upper = [30;30;30;250;250;50;50;50];
par_iter    = length(in_ind);
% Parameter labels for bar graph
in_label = flip({'RSNA\newline-30% to +30%', ...
                 'Aldosterone Secretion\newline-30% to +30%', ...
                 'Renin Secretion\newline-30% to +30%', ...
                 'Afferent Arteriole Resistance\newline-50% to +250%', ...
                 'Efferent Arteriole Resistance\newline-50% to +250%', ...
                 'ACE Reaction Rate\newline-50% to +50%', ...
                 'AT1R Binding Rate\newline-50% to +50%', ...
                 'AT2R Binding Rate\newline-50% to +50%'});
% in_label = flip({'RSNA\newline-30% to +30%', 'Aldosterone Secretion\newline-30% to +30%', 'Renin Secretion\newline-30% to +30%', ...
%                  'Afferent Arteriole Resistance\newline-50% to +250%', 'Efferent Arteriole Resistance\newline-50% to +250%', ...
%                  'ACE Reaction Rate\newline-50% to +50%', 'AT1R Binding Rate\newline-50% to +50%', 'AT2R Binding Rate\newline-50% to +50%', ...
%                  'Effect of [AT2R] on AAR\newline-50% to +50%', 'Effect of AT2R on EAR\newline-50% to +50%'});
% ycat = flip({'N_{rsna} -30% to +30%', 'N_{als} -30% to +30%', 'N_{rs} -30% to +30%', ...
%         'R_{aa} -50% to +250%', 'R_{ea} -50% to +250%', ...
%         'c_{ACE} -50% to +50%', 'c_{AT1R} -50% to +50%', 'c_{AT2R} -50% to +50%', ...
%         '\Psi_{AT2R-AA} -50% to +50%','\Psi_{AT2R-EA} -50% to +50%'});

% Output of interest
% Phi_gfilt         - var 7
% P_ma              - var 42
% % M_sod             - var 65
% % Phi_win           - var 28
% Phi_u             - var 63
% R_aa              - var 86
% R_ea              - var 87
% eta_alpha-sodreab - var 13, 19, 23 (alpha = pt, dt, cd)
% eta_alpha-wreab   - var 52, 56, 60 (alpha = pt, dt, cd)
out_ind = [7;42;63;86;87;13;19;23;52;56;60];
out_num = length(out_ind);
% Variable labels for bar graph
out_label = {'GFR', 'MAP', 'UF', 'R_{AA}', 'R_{EA}', ...
             'F_{Na}^{pt}', 'F_{Na}^{dt}', 'F_{Na}^{cd}', ...
             'F_{W}^{pt}', 'F_{W}^{dt}', 'F_{W}^{cd}'};

% Scenarios
% Normal - Normal
% AngII  - Ang II infusion
% ACEi   - Angiotensin convernting enzyme inhibitor
% ARB    - Angiotensin receptor blocker
% AT2R-  - Block AT2R through decay
% RHyp   - Renal hypertension due to increased afferent arteriolar resistance
scenario = {'Normal', 'AngII', 'ACEi', 'ARB', 'AT2R-', 'RHyp'};
ss = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           End user input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of variables
num_vars = 92;

% Initialize variables.
% X = (variable, parameter, change, gender)
X = zeros(num_vars,par_iter,2,2);

gender = {'male'    , 'female'  };
change = {'decrease', 'increase'};

for iter = 1:par_iter % par
for cc   = 1:2        % change
for gg   = 1:2        % gender

%% Parameters

if     strcmp(gender{gg}, 'male')
    gen = 1;
elseif strcmp(gender{gg}, 'female')
    gen = 0;
end

% Scaling factor
% Rat sodium flow = Human sodium flow x SF
% Note: This includes conversion from mEq to microEq.
if     strcmp(gender{gg}, 'male')
    SF_S = 9.69; % karaaslan
elseif strcmp(gender{gg}, 'female')
    SF_S = 9.69; % karaaslan
end
% Rat resistance = Human resistance x SF
% Note: This includes conversion from l to ml.
if     strcmp(gender{gg}, 'male')
    SF_R = 0.343;
elseif strcmp(gender{gg}, 'female')
    SF_R = 0.537;
end
% Rat volume = Human volume x SF
% Note: This includes conversion from l to ml.
if     strcmp(gender{gg}, 'male')
    SF_V = 3;
elseif strcmp(gender{gg}, 'female')
    SF_V = 2.4;
end

N_rsna    = 1.00;
if     strcmp(gender{gg}, 'male')
R_aass    = 10.87;   % mmHg min / ml
R_eass    = 17.74;   % mmHg min / ml
elseif strcmp(gender{gg}, 'female')
R_aass    = 17.02;   % mmHg min / ml
R_eass    = 27.76;   % mmHg min / ml
end
if     strcmp(scenario{ss}, 'RHyp') %|| strcmp(scenario{ss}, 'ACEi') || strcmp(scenario{ss}, 'ARB')
    R_aass = R_aass*3.5;
end
P_B       = 18;           % mmHg
P_go      = 28;           % mmHg
if     strcmp(gender{gg}, 'male')
C_gcf     = 0.068;
elseif strcmp(gender{gg}, 'female')
C_gcf     = 0.047;
end
if     strcmp(gender{gg}, 'male')
    eta_ptsodreab_eq = 0.8; % karaaslan
    eta_dtsodreab_eq = 0.5; 
    eta_cdsodreab_eq = 0.93;
elseif strcmp(gender{gg}, 'female')
    eta_ptsodreab_eq = 0.5; % calibrated
    eta_dtsodreab_eq = 0.5; 
    eta_cdsodreab_eq = 0.96;
end
if     strcmp(gender{gg}, 'male')
    eta_ptwreab_eq = 0.86; % layton 2016
    eta_dtwreab_eq = 0.60; 
    eta_cdwreab_eq = 0.78;
elseif strcmp(gender{gg}, 'female')
    eta_ptwreab_eq = 0.5; % calibrated
    eta_dtwreab_eq = 0.6; 
    eta_cdwreab_eq = 0.91;
end
K_vd      = 0.01;
K_bar     = 16.6 * SF_R; % mmHg min / ml
R_bv      = 3.4 * SF_R;  % mmHg min / ml
T_adh     = 6;           % min
Phi_sodin = 1.2212;      % microEq / min % karaaslan
N_als_eq  = 1;
C_K       = 5;           % microEq / ml 
T_al      = 30;          % min LISTED AS 30 IN TABLE %listed as 60 in text will only change dN_al
N_rs      = 1;           % ng / ml / min

% RAS
h_renin   = 12;      % min
h_AGT     = 10*60;   % min
h_AngI    = 0.5;     % min
h_AngII   = 0.66;    % min
h_Ang17   = 30;      % min
h_AngIV   = 0.5;     % min
h_AT1R    = 12;      % min
h_AT2R    = 12;      % min

% Male and female different parameters for RAS
if     strcmp(gender{gg}, 'male')
    X_PRCPRA = 135.59/17.312;
    k_AGT    = 801.02;
    c_ACE    = 0.096833;
    c_Chym   = 0.010833;
    c_NEP    = 0.012667;
    c_ACE2   = 0.0026667;
    c_IIIV   = 0.29800;
    c_AT1R   = 0.19700;
    c_AT2R   = 0.065667;
    AT1R_eq  = 20.4807902818665;
    AT2R_eq  = 6.82696474842298;
elseif strcmp(gender{gg}, 'female')
    X_PRCPRA = 114.22/17.312;
    k_AGT    = 779.63;
    c_ACE    = 0.11600;
    c_Chym   = 0.012833;
    c_NEP    = 0.0076667;
    c_ACE2   = 0.00043333;
    c_IIIV   = 0.29800;
    c_AT1R   = 0.19700;
    c_AT2R   = 0.065667;
    AT1R_eq  = 20.4538920068419;
    AT2R_eq  = 6.81799861123497;
end

Psi_AT2RAA_eq = 1;
Psi_AT2REA_eq = 1;

pars = [N_rsna; R_aass; R_eass; P_B; P_go; C_gcf; eta_ptsodreab_eq; ...
        eta_dtsodreab_eq; eta_cdsodreab_eq; eta_ptwreab_eq; ...
        eta_dtwreab_eq; eta_cdwreab_eq; K_vd; K_bar; R_bv; T_adh; ...
        Phi_sodin; N_als_eq; C_K; T_al; N_rs; X_PRCPRA; h_renin; ...
        h_AGT; h_AngI; h_AngII; h_Ang17; h_AngIV; h_AT1R; h_AT2R; ...
        k_AGT; c_ACE; c_Chym; c_NEP; c_ACE2; c_IIIV; c_AT1R; c_AT2R; ...
        AT1R_eq; AT2R_eq; Psi_AT2RAA_eq; Psi_AT2REA_eq; ...
        gen; SF_S; SF_R; SF_V];

if     strcmp(change{cc}, 'decrease')
    pars(in_ind(iter)) = pars(in_ind(iter)) * (1 - range_lower(iter)/100);
elseif strcmp(change{cc}, 'increase')
    pars(in_ind(iter)) = pars(in_ind(iter)) * (1 + range_upper(iter)/100);
end

%% Drugs

% drugs = [Ang II inf rate fmol/(ml min), ACEi target level, ARB target level, AT2R decay rate]
if     strcmp(scenario{ss}, 'Normal') || strcmp(scenario{ss}, 'RHyp')
    drugs = [0, 0, 0, 0];
elseif strcmp(scenario{ss}, 'AngII')
    if     strcmp(gender{gg}, 'male')
        drugs = [2022, 0, 0, 0]; % Sampson 2008
    elseif strcmp(gender{gg}, 'female')
        drugs = [2060, 0, 0, 0]; % Sampson 2008
    end
elseif strcmp(scenario{ss}, 'ACEi')
%     drugs = [0, 1, 0, 0 ]; % Hall 1980
    drugs = [0, 0.78, 0, 0]; % Leete 2018
elseif strcmp(scenario{ss}, 'ARB')
    drugs = [0, 0, 0.67, 0]; % Leete 2018
elseif strcmp(scenario{ss}, 'AT2R-')
    drugs = [0, 0, 0, 10];
end

%% Variables initial guess

% Add directory containing data.
mypath = pwd;
mypath = strcat(mypath, '/Data');
addpath(genpath(mypath))

% Load data for steady state initial value. 
if     strcmp(gender{gg}, 'male')
    load(  'male_ss_data_scenario_Normal.mat', 'SSdata');
elseif strcmp(gender{gg}, 'female')
    load('female_ss_data_scenario_Normal.mat', 'SSdata');
end

% Retrieve and replace parameters in fixed variable equations.
fixed_ind = [2, 10, 14, 24, 44, 49, 66, 71, 88];
fixed_var_pars = SSdata(fixed_ind);
phicophico = SSdata(33);
cadhcadh   = SSdata(47);
fixed_var_pars = [fixed_var_pars; cadhcadh; phicophico];
SSdata(fixed_ind) = 1;
SSdataIG = SSdata;
clear SSdata

% Ang II infusion steady state value is sensitive to such a huge change.
% Thus it is done incrementally and iteratively.
if     strcmp(scenario{ss}, 'AngII')
    if     strcmp(gender{gg}, 'male')
        load(  'male_ss_data_scenario_AngII.mat', 'SSdata');
        SSdataIG = SSdata;
        clear SSdata;
    elseif strcmp(gender{gg}, 'female')
        load('female_ss_data_scenario_AngII.mat', 'SSdata');
        SSdataIG = SSdata;
        clear SSdata;
    end
end

names  = {'rsna'; '\alpha_{map}'; '\alpha_{rap}'; 'R_{r}'; ...
          '\beta_{rsna}'; '\Phi_{rb}'; '\Phi_{gfilt}'; 'P_{f}'; ...
          'P_{gh}'; '\Sigma_{tgf}'; '\Phi_{filsod}'; ...
          '\Phi_{pt-sodreab}'; '\eta_{pt-sodreab}'; ...
          '\gamma_{filsod}'; '\gamma_{at}'; '\gamma_{rsna}'; ...
          '\Phi_{md-sod}'; '\Phi_{dt-sodreab}'; ...
          '\eta_{dt-sodreab}'; '\psi_{al}'; '\Phi_{dt-sod}'; ...
          '\Phi_{cd-sodreab}'; '\eta_{cd-sodreab}'; ...
          '\lambda_{dt}'; '\lambda_{anp}'; '\lambda_{al}'; ...
          '\Phi_{u-sod}'; '\Phi_{win}'; 'V_{ecf}'; 'V_{b}'; ...
          'P_{mf}'; '\Phi_{vr}'; '\Phi_{co}'; 'P_{ra}'; ...
          'vas'; 'vas_{f}'; 'vas_{d}'; 'R_{a}'; 'R_{ba}'; ...
          'R_{vr}'; 'R_{tp}'; 'P_{ma}'; '\epsilon_{aum}'; ...
          'a_{auto}'; 'a_{chemo}'; 'a_{baro}'; 'C_{adh}'; ...
          'N_{adh}'; 'N_{adhs}'; '\delta_{ra}'; ...
          '\Phi_{pt-wreab}'; '\eta_{pt-wreab}'; ...
          '\mu_{pt-sodreab}'; '\Phi_{md-u}'; '\Phi_{dt-wreab}'; ...
          '\eta_{dt-wreab}'; '\mu_{dt-sodreab}'; '\Phi_{dt-u}'; ...
          '\Phi_{cd-wreab}'; '\eta_{cd-wreab}'; ...
          '\mu_{cd-sodreab}'; '\mu_{adh}'; '\Phi_{u}'; ...
          'M_{sod}'; 'C_{sod}'; '\nu_{md-sod}'; '\nu_{rsna}'; ...
          'C_{al}'; 'N_{al}'; 'N_{als}'; '\xi_{k/sod}'; ...
          '\xi_{map}'; '\xi_{at}'; '\hat{C}_{anp}'; 'AGT'; ...
          '\nu_{AT1}'; 'R_{sec}'; 'PRC'; 'PRA'; 'Ang I'; ...
          'Ang II'; 'Ang II_{AT1R-bound}'; 'Ang II_{AT2R-bound}'; ...
          'Ang (1-7)'; 'Ang IV'; 'R_{aa}'; 'R_{ea}'; ...
          '\Sigma_{myo}'; '\Psi_{AT1R-AA}'; '\Psi_{AT1R-EA}'; ...
          '\Psi_{AT2R-AA}'; '\Psi_{AT2R-EA}'};

% Initial guess for the variables.
% Find the steady state solution, so the derivative is 0.
% Arbitrary value for time to input.
x0 = SSdataIG; x_p0 = zeros(num_vars,1); t = 0;

%% Find steady state solution

% options = optimset(); %options = optimset('MaxFunEvals',num_vars*100+10000);
options = optimset('Display','off');
[SSdata, residual, ...
 exitflag, output] = fsolve(@(x) bp_reg_solve_sen_anal(t,x,x_p0,pars, ...
                                                       fixed_var_pars, ...
                                                       drugs), ...
                            x0, options);

% Check for solver convergence.
if exitflag == 0
    disp('Solver did not converge.')
    disp(output)
end

% Check for imaginary solution.
if not (isreal(SSdata))
    disp('Imaginary number returned.')
end

% Set any values that are within machine precision of 0 equal to 0.
for i = 1:length(SSdata)
    if abs(SSdata(i)) < eps*100
        SSdata(i) = 0;
    end
end

% Relative percent change
SSdata = (SSdata - SSdataIG) ./ SSdataIG * 100;

% Store solution.
X(:,iter,cc,gg) = SSdata;

% % Sanity check to see script's progress. Also a check for where to
% % troubleshoot in case the solver does not converge.
% if     strcmp(gender{gg}, 'male')
%     fprintf('  male %s iteration = %s out of %s \n', ...
%             change{cc},num2str(iter),num2str(par_iter))
% elseif strcmp(gender{gg}, 'female')
%     fprintf('female %s iteration = %s out of %s \n', ...
%             change{cc},num2str(iter),num2str(par_iter))
% end

end % gender
end % change
end % par

% Retrieve male/female decrease/increase. 
% X_m/f_dec/inc = (variable, parameter)
% X_m_dec = X(:,:,1,1); X_m_inc = X(:,:,2,1);
% X_f_dec = X(:,:,1,2); X_f_inc = X(:,:,2,2);

% X_m/f = (variable, parameter, change)
X_m = X(:,:,:,1);
X_f = X(:,:,:,2);

% out_ind = [7;42;63;86;87;13;19;23;52;56;60];
% pars(in_ind(iter))
f = gobjects(out_num,1);
for i = 1:out_num
    f(i) = figure('DefaultAxesFontSize',20, 'pos',[550 450 700 560]);
    bdec = barh([par_iter:-1:1], [X_m(out_ind(i),:,1)',X_f(out_ind(i),:,1)']);
    hold on
    binc = barh([par_iter:-1:1], [X_m(out_ind(i),:,2)',X_f(out_ind(i),:,2)']);
    
%     set(gca,'yticklabel',ycat)
    yticklabels(in_label)
%     ytickangle(45)
    ylim([1-0.5,par_iter+0.5])


    bdec(1).FaceColor = [0.203, 0.592, 0.835]; bdec(2).FaceColor = [0.835, 0.203, 0.576]; 
    binc(1).FaceColor = [0.203, 0.592, 0.835]; binc(2).FaceColor = [0.835, 0.203, 0.576];
    bdec(1).FaceAlpha = 0.5; bdec(2).FaceAlpha = 0.5;
    
    xlabel(strcat(out_label(i),' Percent change'))
    
    bars = get(gca, 'Children');
    legend(bars([4,2,3,1]), {'Male Dec','Male Inc','Female Dec','Female Inc'}, ...
           'FontSize',15,'Location','Southeast');

end

% Save figures
savefig(f, 'all_vars_sen_anal.fig' )

end

% close all
% u = [1 2 3]; v = [1 2; 
%                   1 2; 
%                   1 2];
% bar(u,v(:,1),v(:,2))


























