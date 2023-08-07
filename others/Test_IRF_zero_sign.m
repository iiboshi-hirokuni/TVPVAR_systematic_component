% =============================================================
% 
%  
% 
% =============================================================
clc
clear all

global VAR_model_type;

VAR_model_type= 'zero_sign'
%   VAR_model_type= 'only_sign'

my=xlsread('DATA_6var_closed1952');

asvar = {'g';'y';'cons';'dbt';'pi';'int'};    % variable names
nlag = 4;                   % lags

setvar('data', my, asvar, nlag);  % set data

%setvar('ranseed', 5);       % set ranseed
setvar('intercept', 0);     % set time-varying intercept
setvar('SigB', 0);          % set digaonal for Sig_beta
setvar('impulse', 20);      % set maximum length of impulse
                            % (smaller, calculation faster)

load('para_save.mat')

 [mimpm_temp, sign_chk] = impulse_zero_sign_v2(nl, m_nimp, msampb/nsim, msampa,...
                    msamph);

 mimpm = [];            
 for i = 1:size(mimpm_temp,3)
   if sign_chk(i)==1  
      mimpm = [mimpm; mimpm_temp(:,:,i) ] ;
   else
      mimpm = [mimpm; mimpm_temp(:,:,i) ] ;
   end
 end
   


save('tvpvar_imp.xls', 'mimpm',  '-ascii', '-tabs');

 drawimp_3d;  