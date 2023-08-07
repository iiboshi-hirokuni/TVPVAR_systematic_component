
%  ncores=1;

% global m_my m_asvar m_nl m_ns m_nk m_fli m_flSb m_nimp m_flfi ...
%        m_iseed m_dvb0 m_dVb0 m_dva0 m_dVa0 m_dvh0 m_dVh0 m_k;
%    
% global policy_type svar_type; 

ns = m.ns;

nk = m.nk;

 mimpm_total = zeros(m.nimp*ns, nk^2);
 mimpms_total = zeros(m.nimp*ns, nk^2);
 a0_total    =  zeros(ns*2,nk); 
 a0s_total    =  zeros(ns*2,nk);
 n_IRF_total = zeros(ns,1);
 
 mimph2_total = zeros(ns, 2*nk);
 mimph2s_total = zeros(ns, 2*nk);
 

for i = 1:ncores
   mimpm = load(['./output/tvpvar_imp_',  num2str(i), '_' , num2str(date) , '.xls']);     % posterior means of IRF
   mimpm_total = mimpm_total + mimpm;
   
   mimpms = load(['./output/tvpvar_imps_',   num2str(i), '_' , num2str(date) ,'.xls']);     % posterior means of IRF
   mimpms_total = mimpms_total + mimpms;
   
   a0 = load(['./output/tvpvar_a0_',   num2str(i), '_' , num2str(date) ,'.xls']);     % posterior means of IRF
   a0_total = a0_total + a0;
   
    a0s = load(['./output/tvpvar_a0s_',   num2str(i),'_' , num2str(date) ,'.xls']);     % posterior means of IRF
   a0s_total = a0s_total + a0s;
   
   load(['./output/para_save_',  num2str(i) '_' , num2str(date) , '.mat']);
      n_IRF_total =  n_IRF_total+ n_IRF;   
      
      mimph2 = load(['./output/tvpvar_sv_',  num2str(i), '_' , num2str(date), '.xls']);     % posterior means of IRF
   mimph2_total = mimph2_total + mimph2;
   
%    mimpms = load(['./output/tvpvar_svs_',   num2str(i),'.xls']);     % posterior means of IRF
%    mimpms_total = mimpms_total + mimpms;  
      
   
end   

% for mean
 a0_total =  [a0_total(1:264,:)  a0_total(265:528,:)];
 a0_mean=zeros(264,nk*2);%20210926

 % for variance
 a0s_total =  [a0s_total(1:264,:)  a0s_total(265:528,:)];
 a0s_mean=zeros(264,nk*2);%20210926

mimpm_mean = zeros(m.nimp*ns, nk^2);
mimpms_std = zeros(m.nimp*ns, nk^2);

for i = 1:ns
   mimpm_mean((i-1)*m.nimp+1:m.nimp*i,:) = mimpm_total((i-1)*m.nimp+1:m.nimp*i,:)/n_IRF_total(i)  ;
   
   mimpms_std((i-1)*m.nimp+1:m.nimp*i,:) = sqrt( mimpms_total((i-1)*m.nimp+1:m.nimp*i,:)/n_IRF_total(i)...
                                            -mimpm_mean((i-1)*m.nimp+1:m.nimp*i,:).^2 ); 
                                        
   a0_mean(i,:) = a0_total(i,:)/  n_IRF_total(i)  ;            
   a0s_mean(i,:) = a0s_total(i,:)/  n_IRF_total(i)  ;     
   
    mimph2_total(i,:) =  mimph2_total(i,:)/  n_IRF_total(i)  ;            
   
end   

accept_rate = n_IRF_total(nl+1:ns)/nsim/ncores*100;

save(['./output/tvpvar_imp_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'mimpm_mean',  '-ascii', '-tabs');
save(['./output/tvpvar_imps_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'mimpms_std',  '-ascii', '-tabs');
save(['./output/accept_rate_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'accept_rate',  '-ascii', '-tabs');            
save(['./output/a0_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'a0_mean',  '-ascii', '-tabs');            
save(['./output/a0s_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'a0s_mean',  '-ascii', '-tabs');          
  
save(['./output/tvpvar_sv_',char(policy_type),'-' ,char(svar_type),'.xls'],...
                        'mimph2_total',  '-ascii', '-tabs');                    

figure(1000)
 ti=1953:0.25:1953+(ns-nl-1)/4;
 plot(ti, n_IRF_total(nl+1:ns)/nsim/ncores*100);
  title('Accepted Rates for Sign Restiction')
%   ylabel("%")

% mimpms = load('./output/tvpvar_imps.xls');   % Standard Deviation of IRF
