% =============================================================
% 
%  
% 
% =============================================================
clc
clear all

my=xlsread('DATA_6var_closed1952')

asvar = {'g';'y';'cons';'dbt';'pi';'int'};    % variable names
nlag = 4;                   % lags

setvar('data', my, asvar, nlag);  % set data

%setvar('ranseed', 5);       % set ranseed
setvar('intercept', 0);     % set time-varying intercept
setvar('SigB', 0);          % set digaonal for Sig_beta
setvar('impulse', 20);      % set maximum length of impulse
                            % (smaller, calculation faster)

setvar('fastimp', 0);       % fast computing of response
                         % 0:各サンプルからインパルスを計算し、インパルスの平均値を計算
                         % 1: サンプルの平均値からインパルスを計算　%  Aug/10/2013 追加

load('para_save.mat')

 mimpm = impulse(nl, m_nimp, msampb/nsim, msampa,...
                    msamph);
% else
%     %     mimpm = mimpm / nsim;
%     mimpm = mimpm / (nsim / nthin) ; % Aug/10/2013　追加
% end

save('tvpvar_imp.xls', 'mimpm',  '-ascii', '-tabs');

 drawimp_3d;  