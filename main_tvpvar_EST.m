%%--------------------------------------------------------%%
%%                     tvpvar_ex1.m                       %%
%%--------------------------------------------------------%%

%%
%%  MCMC estimation for Time-Varying Parameter VAR model
%%  with stochastic volatility
%%
%%  tvpvar_ex*.m illustrates MCMC estimation
%%  using TVP-VAR Package
%%  (Data: "tvpvar_ex.xls/.mat")
%%

clear all;
close all;
clc

warning('off','all')


global method_type policy_type svar_type;

addpath('./data')
addpath('./function')
addpath('./function_zero_sign')
addpath('./output')

% my=xlsread('./data/data_7vars_qdt','sheet1','B2:H266');
%my=csvread('./data/data_5vars_ldt.csv',1,1);
my=xlsread('./data/DATA_HF2019_Rndt','DATA','B2:F265');

%% =====================================================
   method_type = 'Arias_et_al'

   policy_type = 'bench_mark' 
%  policy_type = 'Choleski' 

   svar_type = 'both_zero_sign'  % Caldara and Kamp (2017)

%% =====================================================

asvar = {'g';'y';'dbt';'pi';'int'};    % variable names
nlag = 4;                   % lags

setvar('data', my, asvar, nlag);  % set data

%setvar('ranseed', 5);       % set ranseed
setvar('intercept', 0);     % set time-varying intercept
setvar('SigB', 1);          % set digaonal for Sig_beta
setvar('impulse', 40);      % set maximum length of impulse
                            % (smaller, calculation faster)
                            
%setvar('prior','b',20, 1e-4);   % set prior of var of b_t 
setvar('prior','b',10, 8*1e-4);   % set prior of var of b_t 
setvar('prior','a',10, 4*1e-4);  % set prior of var of a_t 
 %setvar('prior','a',10, 1*1e-4);  % set prior of var of a_t 
 % setvar('prior','h',50, 1e-4);  % set prior of var of h_t 
setvar('prior','h',10, 1);  % set prior of var of h_t 
%setvar('prior','h',60, 4);  % set prior of var of h_t 
 setvar('fastimp', 0);       % fast computing of response
                         % 0:各サンプルからインパルスを計算し、インパルスの平均値を計算
                         % 1: サンプルの平均値からインパルスを計算　%  Aug/10/2013 追加                         
 change_global;

% plot_data;   
pause(0.5);

%% MCMC
% tic
% 
    ncores = 8;
%    delete(gcp('nocreate')) %   
%    parpool('local', ncores)
%   
 jj = 1;
  parfor jj = 1:ncores
         mcmc_zero_sign(50000, 20000, jj,m, 1000);   %　thining(間引き数)はなし  
%          mcmc_zero_sign(500, 200, jj,m, 10);   %　thining(間引き数)はなし  
   end                 
%  
% toc
%%

 integrate_save_files       

%%      
% %%   Check of Convergence
% 
% F          = zeros(m_nk*m_nl,m_nk*m_nl);
% load('./output/para_save_1.mat');
% 
% disp(' Coeffi_s of reduced VAR = ')
% coef_B = reshape( mean(msampb(nl+2:end,:),1), m_nk*m_nl, m_nk)'
% F(1:m_nk,1:m_nk*m_nl)= coef_B;
% 
%      eigen           = max(eig(F(:,1:m_nk*m_nl)));
%      eigen           = max(eigen);
%      largeeig     = abs(eigen);
%      disp([' eig = ', num2str(largeeig)    ]);
% 
%      
%%  Make Graph 
filename=('./output/'); 
    drawimp_3d;  
   pause(5)
% %  
       drawimp_68band_mp;
       drawimp_68band_g;
       drawimp_68band_d;
       drawimp_68band_s;
     pause(5)
%     
      draw_Fiscal_Mult
%%
 if svar_type == 'both_zero_sign'
     draw_a0
elseif svar_type == 'Caldala_Kamps_tax'
    draw_a0_tax
end

%%  save result 
 filename=('./output/'); 
mimpm = load([ filename '/tvpvar_imp_',char(policy_type),'-' ,char(svar_type),'.xls']);     % posterior means of IRF
mimpms = load( [ filename '/tvpvar_imps_',char(policy_type),'-' ,char(svar_type),'.xls' ] );   % Standard Deviation of IRF
 accept_rate = load( [ filename '/accept_rate_',char(policy_type),'-' ,char(svar_type),'.xls' ] );
 save(['./save_output/tvpvar_imp_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'mimpm',  '-ascii', '-tabs');
save(['./save_output/tvpvar_imps_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'mimpms',  '-ascii', '-tabs');
 save(['./save_output/accept_rate_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'accept_rate',  '-ascii', '-tabs');  
 save(['./save_output/a0_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'a0_mean',  '-ascii', '-tabs');                      

save(['./save_output/phi_pi_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'phi_pi',  '-ascii', '-tabs');                                  
                    
save(['./save_output/phi_pi_se_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'phi_pi_se',  '-ascii', '-tabs');
                    
save(['./save_output/phi_y_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'phi_y',  '-ascii', '-tabs');                                  
                    
save(['./save_output/phi_y_se_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'phi_y_se',  '-ascii', '-tabs');
                    
save(['./save_output/psi_d_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'psi_d',  '-ascii', '-tabs');                                  

save(['./save_output/psi_d_se_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'psi_d_se',  '-ascii', '-tabs');                                  
                    
save(['./save_output/psi_y_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'psi_y',  '-ascii', '-tabs');                                  

save(['./save_output/psi_y_se_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'psi_y_se',  '-ascii', '-tabs');                                  
