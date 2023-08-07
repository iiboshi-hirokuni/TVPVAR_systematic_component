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

clc
clear all;
% close all;

global method_type policy_type svar_type;

addpath('./data')
addpath('./function')
addpath('./function_zero_sign')
addpath('./output')

% my=xlsread('./data/data_7vars_qdt','sheet1','B2:H266');
%my=csvread('./data/data_5vars_ldt.csv',1,1);
my=xlsread('./data/DATA_HF2019_Rndt','DATA','A1:E264');

%% =====================================================
   method_type = 'Arias_et_al'

   policy_type = 'bench_mark' 
%  policy_type = 'Choleski' 

   svar_type = 'both_zero_sign'  % Caldara and Kamp (2017)

%% =====================================================
asvar = {'g';'y';'dbt';'pi';'int'};    % variable names
nlag = 2;                   % lags

setvar('data', my, asvar, nlag);  % set data

%setvar('ranseed', 5);       % set ranseed
setvar('intercept', 1);     % set time-varying intercept
setvar('SigB', 0);          % set digaonal for Sig_beta
setvar('impulse', 80);      % set maximum length of impulse
                            % (smaller, calculation faster)

setvar('fastimp', 0);       % fast computing of response
                         % 0:各サンプルからインパルスを計算し、インパルスの平均値を計算
                         % 1: サンプルの平均値からインパルスを計算　%  Aug/10/2013 追加                         
change_global;
%  plot_data;    
  
%%

   filename=('./output/'); 
%     filename=('./save_output/psi_r_pos/');
%  
     drawimp_68band; 
% %   
    drawimp_3d




%%  
   filename1=('./save_output/'); 
   filename2=('./save_output/psi_r_pos/'); 
%    filename2=('./save_output/psi_r_no_const/');
% %    filename1=('./save_output/'); 
     filename3=('./save_output/'); 
   
% % filename2=('./output/');
% %  
%     Fig_accept_rate;
%     draw_Fiscal_Mult_compare_model;



