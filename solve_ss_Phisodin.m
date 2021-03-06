% This script vairies the sodium intake and then solves for the steady 
% state values of the blood pressure regulation model 
% bp_reg_solve_Phisodin.m for each inputted value. 
% 
% Steady state data for the intial guess is calculated by 
% solve_ss_baseline.m or solve_ss_scenario.m.
% 
% All variables are then plotted versus the relative change in input.

function solve_ss_Phisodin

close all

% Add directory containing data.
mypath = pwd;
mypath = strcat(mypath, '/Rat_Data');
addpath(genpath(mypath))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Begin user input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scenarios
% Normal - Normal conditions
% m_RSNA - male RSNA
% m_AT2R - male AT2R
% m_RAS  - male RAS pars
% m_Reab - male fractional sodium and water reabsorption
% ACEi   - Angiotensin convernting enzyme inhibitor
% AngII  - Ang II infusion
scenario = {'Normal', 'm_RSNA', 'm_AT2R', 'm_RAS', 'm_Reab', ...
            'ACEi', 'AngII'};
num_scen = length(scenario);
% Index of scenario to plot for all variables
fixed_ss = 1;

% Species
sp = 2;

% Number of iterations below/above baseline.
iteration = 51; % must be odd number for symmetry
% Fold decrease/increase.
lower = 1/5; upper = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           End user input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of variables.
num_vars = 93;

% Range for fold decrease/increase.
iter_range_l = linspace(lower, 1, iteration);
iter_range_u = linspace(1, upper, iteration);
% Delete overlapping baseline value.
iter_range_l(end) = '';
% Combine decrease/increase ranges into single vector.
iter_range   = [iter_range_l, iter_range_u];

% Initialize variables.
% X = (variable, iteration, sex, scenario)
X = zeros(num_vars,2*iteration-1,2,num_scen);
% Retrieve male/female. 
% X_m/f = (variable, iteration, scenario)
X_m = zeros(num_vars,2*iteration-1,num_scen);
X_f = zeros(num_vars,2*iteration-1,num_scen);

species = {'human'   , 'rat'     };
sex     = {'male'    , 'female'  };
change  = {'decrease', 'increase'};

for sce_ind = 1:num_scen % scenario
for sex_ind = 1:2        % sex
for cha_ind = 1:2        % change

varargin_input = {scenario{sce_ind},true};

% Parameter input
pars = get_pars(species{sp}, sex{sex_ind}, varargin_input{:});

% Set name for data file to be loaded based upon sex and scenario.    
load_data_name = sprintf('%s_%s_ss_data_scenario_%s.mat', ...
                         species{sp},sex{sex_ind},scenario{sce_ind});
load(load_data_name, 'SSdata');
SSdataIG     = SSdata;
clear SSdata;

for iter = 1:iteration % range

%% Parameters

% Baseline/range of sodium intake.
Phi_sodin_bl_m = 1.2212;
Phi_sodin_bl_f = 1.2212;
Phi_sodin_range_m = Phi_sodin_bl_m * iter_range;
Phi_sodin_range_f = Phi_sodin_bl_f * iter_range;

% Vary sodium intake.
if     strcmp(sex{sex_ind}, 'male')
    if     strcmp(change{cha_ind}, 'decrease')
        Phi_sodin = Phi_sodin_range_m(iteration-iter+1);
    elseif strcmp(change{cha_ind}, 'increase')
        Phi_sodin = Phi_sodin_range_m(iteration+iter-1);
    end
elseif strcmp(sex{sex_ind}, 'female')
    if     strcmp(change{cha_ind}, 'decrease')
        Phi_sodin = Phi_sodin_range_f(iteration-iter+1);
    elseif strcmp(change{cha_ind}, 'increase')
        Phi_sodin = Phi_sodin_range_f(iteration+iter-1);
    end
end
pars(17) = Phi_sodin;

%% Drugs

% drugs = [ACEi target level, Ang II inf rate fmol/(ml min)]
if     strcmp(scenario{sce_ind}, 'ACEi' )
        varargin_input = {'ACEi' ,1   }; % Hall 1980
elseif strcmp(scenario{sce_ind}, 'AngII')
    if     strcmp(sex{sex_ind}, 'male'  )
        varargin_input = {'AngII',2022}; % Sampson 2008
    elseif strcmp(sex{sex_ind}, 'female')
        varargin_input = {'AngII',2060}; % Sampson 2008
    end
end

%% Variables initial guess

% Variable names for plotting.
names  = {'$rsna$'; '$\alpha_{map}$'; '$\alpha_{rap}$'; '$R_{r}$'; ...
          '$\beta_{rsna}$'; '$\Phi_{rb}$'; '$\Phi_{gfilt}$'; '$P_{f}$'; ...
          '$P_{gh}$'; '$\Sigma_{tgf}$'; '$\Phi_{filsod}$'; ...
          '$\Phi_{pt-sodreab}$'; '$\eta_{pt-sodreab}$'; ...
          '$\gamma_{filsod}$'; '$\gamma_{at}$'; '$\gamma_{rsna}$'; ...
          '$\Phi_{md-sod}$'; '$\Phi_{dt-sodreab}$'; ...
          '$\eta_{dt-sodreab}$'; '$\psi_{al}$'; '$\Phi_{dt-sod}$'; ...
          '$\Phi_{cd-sodreab}$'; '$\eta_{cd-sodreab}$'; ...
          '$\lambda_{dt}$'; '$\lambda_{anp}$'; '$\lambda_{al}$'; ...
          '$\Phi_{u-sod}$'; '$\Phi_{sodin}$'; '$V_{ecf}$'; '$V_{b}$'; ...
          '$P_{mf}$'; '$\Phi_{vr}$'; '$\Phi_{co}$'; '$P_{ra}$'; ...
          '$vas$'; '$vas_{f}$'; '$vas_{d}$'; '$R_{a}$'; '$R_{ba}$'; ...
          '$R_{vr}$'; '$R_{tp}$'; '$P_{ma}$'; '$\epsilon_{aum}$'; ...
          '$a_{auto}$'; '$a_{chemo}$'; '$a_{baro}$'; '$C_{adh}$'; ...
          '$N_{adh}$'; '$N_{adhs}$'; '$\delta_{ra}$'; ...
          '$M_{sod}$'; '$C_{sod}$'; '$\nu_{md-sod}$'; '$\nu_{rsna}$'; ...
          '$C_{al}$'; '$N_{al}$'; '$N_{als}$'; '$\xi_{k/sod}$'; ...
          '$\xi_{map}$'; '$\xi_{at}$'; '$\hat{C}_{anp}$'; '$AGT$'; ...
          '$\nu_{AT1}$'; '$R_{sec}$'; '$PRC$'; '$PRA$'; '$Ang I$'; ...
          '$Ang II$'; '$Ang II_{AT1R-bound}$'; '$Ang II_{AT2R-bound}$'; ...
          '$Ang (1-7)$'; '$Ang IV$'; '$R_{aa}$'; '$R_{ea}$'; ...
          '$\Sigma_{myo}$'; '$\Psi_{AT1R-AA}$'; '$\Psi_{AT1R-EA}$'; ...
          '$\Psi_{AT2R-AA}$'; '$\Psi_{AT2R-EA}$'; ...
          '$\Phi_{pt-wreab}$'; '$\eta_{pt-wreab}$'; ...
          '$\mu_{pt-sodreab}$'; '$\Phi_{md-u}$'; '$\Phi_{dt-wreab}$'; ...
          '$\eta_{dt-wreab}$'; '$\mu_{dt-sodreab}$'; '$\Phi_{dt-u}$'; ...
          '$\Phi_{cd-wreab}$'; '$\eta_{cd-wreab}$'; ...
          '$\mu_{cd-sodreab}$'; '$\mu_{adh}$'; ...
          '$\Phi_{u}$'; '$\Phi_{win}$'};

% Initial guess for the variables.
% Find the steady state solution, so the derivative is 0.
% Arbitrary value for time to input, greater than tchange + deltat.
x0 = SSdataIG; x_p0 = zeros(num_vars,1); t = 30;

% Time at which to change and place holder.
tchange = 0;

%% Find steady state solution

options = optimset('Display','off');
[SSdata, residual, ...
 exitflag, output] = fsolve(@(x) ...
                            bp_reg_mod(t,x,x_p0,pars,tchange,varargin_input{:}), ...
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

% Store solution.
if     strcmp(change{cha_ind}, 'decrease')
    X(:,iteration-iter+1,sex_ind,sce_ind) = SSdata;
elseif strcmp(change{cha_ind}, 'increase')
    X(:,iteration+iter-1,sex_ind,sce_ind) = SSdata;
end

% To avoid the solver not converging, the initial guess for solution to the
% system is taken as the previous solution value. That is, IG_i = SOL_i-1.
% Update next initial guess as current solution.
SSdataIG = SSdata;

% Sanity check to see script's progress. Also a check for where to
% troubleshoot in case the solver does not converge.
fprintf('%s %s %s iteration = %s out of %s \n', ...
        scenario{sce_ind},sex{sex_ind},change{cha_ind},num2str(iter),num2str(iteration))

end % change
end % range
end % sex

%% Retrieve data and visualize

X_m(:,:,sce_ind) = X(:,:,1,sce_ind); X_f(:,:,sce_ind) = X(:,:,2,sce_ind);

end % scenario

% x-axis
xscale = iter_range;

% y-axis limits
ylower = zeros(length(X_m(:,1,1)),1); yupper = ylower; 
for i = 1:length(ylower)
    ylower(i) = 0.9*min(min(X_m(i,:,1)), min(X_f(i,:,1)));
    yupper(i) = 1.1*max(max(X_m(i,:,1)), max(X_f(i,:,1)));
    if ylower(i) == yupper(i)
        ylower(i) = ylower(i) - 10^(-5); yupper(i) = yupper(i) + 10^(-5);
    end
    if ylower(i) == inf || yupper(i) == inf || isnan(ylower(i)) || isnan(yupper(i))
        ylower(i) = -1; yupper(i) = 1;
    end
end

% Interesting variables to plot.
var_ind = [33;41;42;9;73;74;6;7;27;92;93;29]; sub_var_num = length(var_ind);

% Plot all variables vs sodium intake. ------------------------------------

f = gobjects(7,1);
s = gobjects(7,15);
% Loop through each set of subplots.
for i = 1:7
    f(i) = figure('pos',[750 500 650 450]);
    % This is to avoid the empty plots in the last subplot set.
    if i == 7
        last_plot = mod(num_vars, 15);
    else
        last_plot = 15;
    end
    % Loop through each subplot within a set of subplots.
    for j = 1:last_plot
        s(i,j) = subplot(3,5,j);

        plot(s(i,j), xscale,X_m((i-1)*15 + j,:,fixed_ss),'b', ...
                     xscale,X_f((i-1)*15 + j,:,fixed_ss),'r');
        
        xlim([lower, upper])
        ylim([ylower((i-1)*15 + j), yupper((i-1)*15 + j)])
        
        xlabel('$\Phi_{sodin}$', 'Interpreter','latex', 'FontSize',15)
        title(names((i-1)*15 + j), 'Interpreter','latex', 'FontSize',15)
%         legend('Male', 'Female')
    end
end

% Plot interesting variables. ---------------------------------------------

f2 = figure('pos',[000 000 600 600], 'DefaultAxesFontSize',12);
s2 = gobjects(1,sub_var_num);
% Loop through each subplot within a set of subplots.
for j = 1:sub_var_num
    s2(j) = subplot(4,3,j);
    if     mod(j,3) == 1
        hshift = -0.05;
    elseif mod(j,3) == 0
        hshift = 0.05;
    else
        hshift = 0;
    end
    s2(j).Position = s2(j).Position + [hshift 0 0.01 0.01];

    plot(s2(j), xscale,X_m(var_ind(j),:,fixed_ss), 'Color',[0.203, 0.592, 0.835], 'LineWidth',2.5);
    hold(s2(j), 'on')
    plot(s2(j), xscale,X_f(var_ind(j),:,fixed_ss), 'Color',[0.835, 0.203, 0.576], 'LineWidth',2.5);
    hold(s2(j), 'off')

    xlim([lower, upper])
    ylim([ylower(var_ind(j)), yupper(var_ind(j))])

    ylabel(names(var_ind(j)), 'Interpreter','latex', 'FontSize',16)
end
legend(s2(1),'Male','Female', 'Location','east')
xlh = xlabel(s2(11),'$\Phi_{sodin}$', 'Interpreter','latex', 'FontSize',16);
xlh.Position(2) = xlh.Position(2) - 0.005;

% Plot Sodium Intake vs Mean Arterial Pressure. ---------------------------

g(1) = figure('DefaultAxesFontSize',14);
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 3.5, 3.5]);
plot(X_m(42,:,fixed_ss),xscale,'-', 'Color',[0.203, 0.592, 0.835], 'LineWidth',3);
xlim([90, 120])
ylim([lower, upper])
ax = gca;
% ax.XTick = (80 : 10 : 120);
xlabel('MAP (mmHg)')
ylabel({'Fold change in'; 'sodium excretion'})
hold on
plot(X_f(42,:,fixed_ss),xscale,'-', 'Color',[0.835, 0.203, 0.576], 'LineWidth',3)
legend('Male','Female', 'Location','Southeast')
hold off
% ---
% Convert from micro eq/min to m eq/day
Phi_sodin_range_m = Phi_sodin_range_m * (1/1000) * (60*24/1);

g(2) = figure('DefaultAxesFontSize',14);
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 3.5, 3.5]);
plot(X_m(42,:,fixed_ss),Phi_sodin_range_m,'-', 'Color',[0.203, 0.592, 0.835], 'LineWidth',3);
% xlim([80, 120])
% ylim([lower, upper])
ax = gca;
% ax.XTick = (80 : 10 : 120);
xlabel('MAP (mmHg)')
ylabel({'Sodium excretion (\mu eq/min)'})
hold on
plot(X_f(42,:,fixed_ss),Phi_sodin_range_m,'-', 'Color',[0.835, 0.203, 0.576], 'LineWidth',3)
legend('Male','Female', 'Location','Northwest')
hold off

% Plot all other quantities of interest. ----------------------------------

% CSOD; CADH; BV; for each sex and all scenarios.
% X_m/f = (variable, iteration, scenario)
CSOD_m = reshape(X_m(52,:,:), [2*iteration-1,num_scen]);
CSOD_f = reshape(X_f(52,:,:), [2*iteration-1,num_scen]);
CADH_m = reshape(X_m(47,:,:), [2*iteration-1,num_scen]);
CADH_f = reshape(X_f(47,:,:), [2*iteration-1,num_scen]);
BV_m   = reshape(X_m(30,:,:), [2*iteration-1,num_scen]);
BV_f   = reshape(X_f(30,:,:), [2*iteration-1,num_scen]);
% Plot as relative change in order to compare male and female.
CSOD_m = CSOD_m ./ CSOD_m(iteration,:);
CSOD_f = CSOD_f ./ CSOD_f(iteration,:);
CADH_m = CADH_m ./ CADH_m(iteration,:);
CADH_f = CADH_f ./ CADH_f(iteration,:);
BV_m   = BV_m   ./ BV_m  (iteration,:);
BV_f   = BV_f   ./ BV_f  (iteration,:);

% Filtration fraction for sodium and urine for each sex and all scenarios.
FRNA_m = reshape((X_m(11,:,:) - X_m(27,:,:)) ./ X_m(11,:,:), [2*iteration-1,num_scen]) * 100;
FRNA_f = reshape((X_f(11,:,:) - X_f(27,:,:)) ./ X_f(11,:,:), [2*iteration-1,num_scen]) * 100;
FRW_m  = reshape((X_m( 7,:,:) - X_m(92,:,:)) ./ X_m( 7,:,:), [2*iteration-1,num_scen]) * 100;
FRW_f  = reshape((X_f( 7,:,:) - X_f(92,:,:)) ./ X_f( 7,:,:), [2*iteration-1,num_scen]) * 100;
% Plot as relative change in order to compare male and female.
FRNA_m = FRNA_m ./ FRNA_m(iteration,:);
FRNA_f = FRNA_f ./ FRNA_f(iteration,:);
FRW_m  = FRW_m  ./ FRW_m (iteration,:);
FRW_f  = FRW_f  ./ FRW_f (iteration,:);

g(3) = figure('DefaultAxesFontSize',14);
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 7.15, 5]);
s_main(1) = subplot(2,2,1); 
s_main(2) = subplot(2,2,2); 
s_main(3) = subplot(2,2,3);
s_main(4) = subplot(2,2,4); 

plot(s_main(1), xscale,CSOD_m(:,fixed_ss), '-' , 'Color',[0.203, 0.592, 0.835], 'LineWidth',3,'MarkerSize',8);
xlim(s_main(1), [lower, upper]);
set(s_main(1), 'XTick', [1/5, 1, 2, 3, 4, 5]);
set(s_main(1), 'XTickLabel', {'^{1}/_{5}','1','2','3','4','5'});
ylim(s_main(1), [0.99,1.03])
xlabel(s_main(1), 'Na^+ Intake (relative)'); ylabel(s_main(1), 'C_{Na^+} (relative)');
hold(s_main(1), 'on')
plot(s_main(1), xscale,CSOD_f(:,fixed_ss), '-' , 'Color',[0.835, 0.203, 0.576], 'LineWidth',3, 'MarkerSize',8);
hold(s_main(1), 'off')
[~, hobj, ~, ~] = legend(s_main(1), {'Male','Female'}, 'FontSize',7,'Location','Southeast');
hl = findobj(hobj,'type','line');
set(hl,'LineWidth',1.5);
title(s_main(1), 'A')

plot(s_main(2), xscale,CADH_m(:,fixed_ss), '-' , 'Color',[0.203, 0.592, 0.835], 'LineWidth',3,'MarkerSize',8);
xlim(s_main(2), [lower, upper]);
set(s_main(2), 'XTick', [1/5, 1, 2, 3, 4, 5]);
set(s_main(2), 'XTickLabel', {'^{1}/_{5}','1','2','3','4','5'});
ylim(s_main(2), [0.6,2.2])
xlabel(s_main(2), 'Na^+ Intake (relative)'); ylabel(s_main(2), 'C_{ADH} (relative)');
hold(s_main(2), 'on')
plot(s_main(2), xscale,CADH_f(:,fixed_ss), '-' , 'Color',[0.835, 0.203, 0.576], 'LineWidth',3, 'MarkerSize',8);
hold(s_main(2), 'off')
title(s_main(2), 'B')

plot(s_main(3), xscale,BV_m  (:,fixed_ss), '-' , 'Color',[0.203, 0.592, 0.835], 'LineWidth',3,'MarkerSize',8);
xlim(s_main(3), [lower, upper]);
set(s_main(3), 'XTick', [1/5, 1, 2, 3, 4, 5]);
set(s_main(3), 'XTickLabel', {'^{1}/_{5}','1','2','3','4','5'});
ylim(s_main(3), [0.97,1.03])
xlabel(s_main(3), 'Na^+ Intake (relative)'); ylabel(s_main(3), 'BV (relative)');
hold(s_main(3), 'on')
plot(s_main(3), xscale,BV_f  (:,fixed_ss), '-' , 'Color',[0.835, 0.203, 0.576], 'LineWidth',3, 'MarkerSize',8);
hold(s_main(3), 'off')
title(s_main(3), 'C')

plot(s_main(4), xscale,FRNA_m(:,fixed_ss) ,'-' , 'Color',[0.203, 0.592, 0.835], 'LineWidth',3,'MarkerSize',8);
xlim(s_main(4), [lower, upper]);
set(s_main(4), 'XTick', [1/5, 1, 2, 3, 4, 5]);
set(s_main(4), 'XTickLabel', {'^{1}/_{5}','1','2','3','4','5'});
ylim(s_main(4), [0.95,1.02])
xlabel(s_main(4), 'Na^+ Intake (relative)'); ylabel(s_main(4), 'FR (relative)');
hold(s_main(4), 'on')
plot(s_main(4), xscale,FRW_m (:,fixed_ss), '--', 'Color',[0.203, 0.592, 0.835], 'LineWidth',3, 'MarkerSize',8);
plot(s_main(4), xscale,FRNA_f(:,fixed_ss), '-' , 'Color',[0.835, 0.203, 0.576], 'LineWidth',3, 'MarkerSize',8);
plot(s_main(4), xscale,FRW_f (:,fixed_ss), '--', 'Color',[0.835, 0.203, 0.576], 'LineWidth',3, 'MarkerSize',8);
fakeplot = zeros(2, 1);
fakeplot(1) = plot(s_main(4), NaN,NaN, 'k-' );
fakeplot(2) = plot(s_main(4), NaN,NaN, 'k--');
[~, hobj, ~, ~] = legend(fakeplot, {'FR_{Na^+}','FR_{U}'}, 'FontSize',7,'Location','Southwest');
hl = findobj(hobj,'type','line');
set(hl,'LineWidth',1.5);
hold(s_main(4), 'off')
title(s_main(4), 'D')

% Plot with different scenarios. ------------------------------------------

h(1) = figure('pos',[100 100 675 450]);
plot(X_m(42,:,1),xscale,'b-' , 'LineWidth',3, 'DisplayName','M Normal')
% xlim([80, 160])
ylim([lower, upper])
set(gca,'FontSize',14)
xlabel(names(42)       , 'Interpreter','latex', 'FontSize',22, 'FontWeight','bold')
ylabel('$\Phi_{sodin}$', 'Interpreter','latex', 'FontSize',22, 'FontWeight','bold')
legend('-DynamicLegend');
hold all
plot(X_f(42,:,1),xscale,'r-', 'LineWidth',3, 'DisplayName','F Normal')
legend('-DynamicLegend');

scen_linestyle_m = {'b-x', 'b-o', 'b-+', 'b-*',};
scen_linestyle_f = {'r-x', 'r-o', 'r-+', 'r-*',};
scen_legend = {'RSNA', 'AT2R', 'RAS', 'Reab'};
for sce_ind = 2:num_scen-2
    hold all
    plot(X_m(42,:,sce_ind),xscale,scen_linestyle_m{sce_ind-1}, 'LineWidth',3, 'DisplayName',scen_legend{sce_ind-1})
    legend('-DynamicLegend');
    hold all
    plot(X_f(42,:,sce_ind),xscale,scen_linestyle_f{sce_ind-1}, 'LineWidth',3, 'DisplayName',scen_legend{sce_ind-1})
    legend('-DynamicLegend');
end

h(2) = figure('pos',[100 100 675 450]);
plot(X_m(42,:,1),xscale,'b-' , 'LineWidth',3, 'DisplayName','M Normal')
% xlim([80, 160])
ylim([lower, upper])
set(gca,'FontSize',14)
xlabel(names(42)       , 'Interpreter','latex', 'FontSize',22, 'FontWeight','bold')
ylabel('$\Phi_{sodin}$', 'Interpreter','latex', 'FontSize',22, 'FontWeight','bold')
legend('-DynamicLegend');
hold all
plot(X_f(42,:,1),xscale,'r-', 'LineWidth',3, 'DisplayName','F Normal')
legend('-DynamicLegend');

scen_linestyle_m = {'b--', 'b:'};
scen_linestyle_f = {'r--', 'r:'};
scen_legend = {'ACEi', 'Ang II'};
for sce_ind = num_scen-1:num_scen
    hold all
    plot(X_m(42,:,sce_ind),xscale,scen_linestyle_m{sce_ind-(num_scen-2)}, 'LineWidth',3, 'DisplayName',scen_legend{sce_ind-(num_scen-2)})
    legend('-DynamicLegend');
    hold all
    plot(X_f(42,:,sce_ind),xscale,scen_linestyle_f{sce_ind-(num_scen-2)}, 'LineWidth',3, 'DisplayName',scen_legend{sce_ind-(num_scen-2)})
    legend('-DynamicLegend');
end

% Plot male - female bar graph for each scenario. -------------------------

% X_m/f = (variable, iteration, scenario)
deltaMAP_m = reshape(X_m(42,end,1:end-2) - X_m(42,iteration,1:end-2), [1,num_scen-2]);
deltaMAP_f = reshape(X_f(42,end,1:end-2) - X_f(42,iteration,1:end-2), [1,num_scen-2]);
MAP_comp = deltaMAP_m(1) - [deltaMAP_m(1), deltaMAP_f];
scen_comp = categorical({'M - M'       , 'M - F'       , ...
                         'M - F M RSNA', 'M - F M AT2R', ...
                         'M - F M RAS' , 'M - F M Reab'});
scen_comp = reordercats(scen_comp,{'M - M'       , 'M - F'       , ...
                                   'M - F M RSNA', 'M - F M AT2R', ...
                                   'M - F M RAS' , 'M - F M Reab'});

k = figure('DefaultAxesFontSize',10);
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 7.15, 3.5]);
s1(1) = subplot(1,2,1); 
s1(2) = subplot(1,2,2); 

plot(s1(1), X_m(42,:,fixed_ss),xscale,'-', 'Color',[0.203, 0.592, 0.835], 'LineWidth',3);
xlim(s1(1), [90, 120]); 
% set(s1(1),'XTick', [80,100,120]);
ylim(s1(1), [lower, upper])
xlabel(s1(1), 'MAP (mmHg)', 'FontSize',14*1.1); ylabel(s1(1), {'Fold change in'; 'sodium excretion'}, 'FontSize',14);
hold(s1(1), 'on')
plot(s1(1), X_f(42,:,fixed_ss),xscale,'-', 'Color',[0.835, 0.203, 0.576], 'LineWidth',3)
legend(s1(1), {'Male','Female'}, 'Location','Southeast', 'FontSize',14)
hold(s1(1), 'off')
title(s1(1), 'A', 'FontSize',14)

bar(s1(2), scen_comp,MAP_comp,'k');
% set(gca,'xticklabel',scen_comp_text);
% xtickget = get(gca,'xticklabel');  
% set(gca,'xticklabel',xtickget,'fontsize',6)
% xtickangle(s1(2),90)
% xlim(s1(2), [1-1,6+1])
ylim(s1(2), [-2,5])
xlabel(s1(2), 'Scenario', 'FontSize',14); ylabel(s1(2), '\DeltaMAP (mmHg)', 'FontSize',14);
% hAxes.XAxis.FontSize = 6;
title(s1(2), 'B', 'FontSize',14)

% Save figures. -----------------------------------------------------------

save_data_name = sprintf('all_vars_vs_Phisodin.fig');
save_data_name = strcat('Rat_Figures/', save_data_name);
savefig([f',f2,g,h,k], save_data_name)

end


























