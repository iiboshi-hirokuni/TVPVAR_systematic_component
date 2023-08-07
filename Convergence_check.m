
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
my=xlsread('./data/DATA_HF2019_Rndt','DATA','B2:G265');

%% =====================================================
   method_type = 'Arias_et_al'

   policy_type = 'bench_mark' 
%  policy_type = 'Choleski' 

   svar_type = 'both_zero_sign'  % Caldara and Kamp (2017)

%% =====================================================

asvar = {'g';'y';'dbt';'pi';'int'; 'cons'};    % variable names
nlag = 4;                   % lags

setvar('data', my, asvar, nlag);  % set data

%setvar('ranseed', 5);       % set ranseed
setvar('intercept', 0);     % set time-varying intercept
setvar('SigB', 1);          % set digaonal for Sig_beta
setvar('impulse', 40);      % set maximum length of impulse
                            % (smaller, calculation faster)
                            
%setvar('prior','b',20, 1e-4);   % set prior of var of b_t 
%setvar('prior','a',10, 1*1e-4);  % set prior of var of a_t 
%setvar('prior','h',50, 1e-4);  % set prior of var of h_t 
  
setvar('prior','b',40, 8*1e-4);   % set prior of var of b_t 
setvar('prior','a',40, 8*1e-3);  % set prior of var of a_t 
setvar('prior','h',20, 2);  % set prior of var of h_t 
  
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

npmt = 15;                   % # of parameter to store
nchain= 8;
 
sum_msamp= zeros(1,npmt);
sum_vsamp= zeros(1,npmt);
total_msamp       = [ ];


date_est='25-Mar-2022'


for i = 1:8
    
    load(  ['./output/para_save_'  num2str(i)  '_'  num2str(date_est) '.mat']  )
         
         eval( [ 'vsamp_'  num2str(i)  '= var(msamp);']  );
         
         sum_vsamp =  sum_vsamp+  var(msamp);
    
         eval( [ 'msamp_'  num2str(i)  '= mean(msamp);' ] );        
         
         mean_msamp(i,:) = mean(msamp);
         total_msamp = [ total_msamp; msamp   ];
         
end   

    %%
     n= size(msamp(:,1),1);
     B = var(mean_msamp)*nchain ;
      W = 1/(nchain-1) *sum_vsamp ;
      
      V = ( (n-1)/n)*W + (1/n)*B;
      
      disp('R=')
      Rubin_Gelman = sqrt(V./W)'; 
      
      %%
       disp('mean=')
      Mean=mean(total_msamp)';
      
       disp('St Dev=')
      StDev=std(total_msamp)';
      
     %% 
     name=[ "beta  1"; "beta  2"; "beta  3";  "beta  4";  "beta  5"; ...
                   "alpha  1"; "alpha  2";   "alpha  3";   "alpha  4";   "alpha  5"; ...
                    "h  1";    "h  2";    "h  3";    "h  4";    "h  5"    ];
               
     T= table(name, Mean, StDev,Rubin_Gelman);
     
     
     writetable(T,'convergence_var5.xlsx')
     
     
     