%%--------------------------------------------------------%%
%%                    TVP-VAR package                     %%
%%--------------------------------------------------------%%
%%
%%  [] = mcmc(nsim)
%%
%%  "mcmc" implements MCMC estimation for TVP-VAR model
%%
%%  [input]
%%      nsim:  # of MCMC iterations
%%

function mcmc_zero_sign(nsim, nburn, jj,m,div_k)     % Aug/10/2013   nburnを追加

% global m.my m_asvar m_nl m_ns m_nk m_fli m_flSb m_nimp m_flfi ...
%        m_iseed m_dvb0 m_dVb0 m_dva0 m_dVa0 m_dvh0 m_dVh0 m_k;
%    
% global policy_type svar_type; 

warning('off','all')

method_type = m.method_type;
policy_type = m.policy_type;
svar_type   = m.svar_type;
   
tic;

 nthin=1;

%%--- set default options ---%%

if isempty(m.fli) == 1
    m.fli = 0;
end
if isempty(m.flSb) == 1
    m.flSb = 1;
end
if isempty(m.nimp) == 1
    m.nimp = 12 + 1;
end
 if isempty(m.flfi) == 1
     m.flfi = 1;
end
if isempty(m.iseed) == 1
    m.iseed = jj*1100;
end

rand('state', m.iseed);



%%--- set variables ---%%

nimp = m.nimp;
ns = m.ns;  % # of time periods
nk = m.nk ; % # of series
nl = m.nl;  % # of lags
nb = nk * (nk*nl + m.fli);  % # of coefficients in beta
na = nk * (nk-1) / 2;       % # of parameters in a

if m.fli == 1
    vym = zeros(1, nk);
else
    vym = mean(m.my);
end
m.my = m.my - ones(ns, 1) * vym;

myh = zeros(ns, nk);
mya = zeros(ns, nk);
amX = zeros(nk, nb, ns);
amXh = zeros(nk, na, ns);
amG2 = zeros(nk, nk, ns);
mai = zeros(ns, na);
for i = nl+1 : ns
    amX(:, :, i) = fXt(m.my(i-nl:i-1, :), m.fli);
end

mb = zeros(ns, nb);
ma = zeros(ns, na);
mh = zeros(ns, nk);

mSigb = eye(nb) *1e-1;
mSiga = eye(na) * 1e-1;
%mSigh = eye(nk) * 0.1;
mSigh = eye(nk) * 0.1;

vidb = 1 : nb;
if m.fli == 1
    vidi = (0 : nk-1) * (nk*nl+1) + 1;
	vidb(vidi) = [];
end
[v1, v2] = find(triu(reshape(1:nk^2, nk, nk)', 1));
vida = (v1-1)*nk + v2;

%%--- prior ---%%

if isempty(m.dvb0) == 1
  if m.flSb == 1
    m.dvb0 = 25;          % Sigma ~ IW(vb0, I*Vb0)
    m.dVb0 = 1e-4;
  else
    m.dvb0 = 40;          % sigb_i^2 ~ IG(va0/2, Va0/2) 
    m.dVb0 = 2*1e-4;
  end
elseif m.flSb == 0
    m.dvb0 = m.dvb0*2;
    m.dVb0 = m.dVb0*2;
end   
if isempty(m.dva0) == 1
  m.dva0 = 8;             % siga_i^2 ~ IG(va0/2, Va0/2)
  m.dVa0 = 2*1e-4;    
end
if isempty(m.dvh0) == 1
  m.dvh0 = 8;             % sigh_i^2 ~ IG(vh0/2, Vh0/2)
 % m.dVh0 = 10;  %2*1e-4;    
  m.dVh0=10;
end

if nl == 1
  prior_b=reshape([zeros(nk,m.fli), eye(nk), zeros(nk,nk*(nl-1))]',nk*(nk*nl+m.fli),1);
elseif nl == 2 
   prior_b=reshape([zeros(nk,m.fli), eye(nk)/2,eye(nk)/2, zeros(nk,nk*(nl-2))]',nk*(nk*nl+m.fli),1);
else
    prior_b=reshape([zeros(nk,m.fli), eye(nk)/3,eye(nk)/3,eye(nk)/3, zeros(nk,nk*(nl-3))]',nk*(nk*nl+m.fli),1);
end    
vb0 = prior_b; %zeros(nb, 1);       % b_1 ~ N(b0, Sb0)
mSb0 = eye(nb) * 1e1;
va0 = zeros(na, 1);       % a_1 ~ N(a0, Sa0)
mSa0 = eye(na) * 1e1;
vh0 = zeros(nk, 1);       % h_1 ~ N(h0, Sh0)
%mSh0 = eye(nk) * 50;
mSh0 = eye(nk) * 50;
mS0 = eye(nb) * m.dVb0;
dnub = m.dvb0 + ns - nl - 1;
dnua = m.dva0 + ns - nl - 1;
dnuh = m.dvh0 + ns - nl - 1;

    
%%--- set sampling option ---%%

% nburn = 0.1 * nsim;         % burn-in period  % Aug/10/2013 停止
npmt = 15;                   % # of parameter to store
msamp    = zeros(nsim, npmt);  % sample box
msamph   = zeros(ns, nk);
msamphs  = zeros(ns, nk);

msamph2   = zeros(ns, nk);   % for SV of stractural shock  
msamph2s  = zeros(ns, nk); % for SV of stractural shock  

msampa   = zeros(ns, na);
msampas  = zeros(ns, na);
msampai  = zeros(ns, na);
msampais = zeros(ns, na);

 msampb = zeros(ns, length(vidb));
 msampbs = zeros(ns, length(vidb));
 mA0_t = zeros(ns,nk); 

if m.fli == 1
    msampi  = zeros(ns, nk);
    msampis = zeros(ns, nk);
end
if m.flfi == 1
  
else  % % Dec/30/2014 追加
    mimpm_temp = zeros(m.nimp, nk^2,ns);
    mimpms_temp = zeros(m.nimp, nk^2,ns);
    mA01_t = zeros(ns,nk);   mA02_t = zeros(ns,nk); 
    mA01s_t = zeros(ns,nk);  mA02s_t = zeros(ns,nk);
end

n_IRF = zeros(ns,1);
nK = floor(m.ns/30)-1;      % # of blocks for sampling h
F          = zeros(nk*nl,nk*nl+m.fli);

%%--- MCMC sampling ---%%
 
    fprintf('\nIteration:\n');
  
%%------------- S A M P L I N G   S T A R T --------------%%


for m_k = -nburn : nsim

  %%--- sampling beta ---%%

    for i = nl+1 : ns
        mAinv = finvm(fAt(ma(i, :), nk));
        amG2(:, :, i) = mAinv * diag(exp(mh(i,:))) * mAinv';
        mai(i, :) = mAinv(vida)';
    end
  
    mb(nl+1:end, :) ...
     = ssmooth(m.my(nl+1:end,:), amX(:,:,nl+1:end), ...
               amG2(:,:,nl+1:end), mSigb, vb0, mSb0)';
           
%        mb(nl+1:end, :) = 0.95*ones(size(mb,1)-nl,1).*(vb0+0.05*randn(nb,1))';       
    
%       y_temp= m.my(nl+1:end,:)-m.my(nl:end-1,:);  %% 2018/8/21追加
%     
%       mb(nl+1:end, :)  = ssmooth(y_temp, amX(:,:,nl+1:end), ...
%                        amG2(:,:,nl+1:end), mSigb, vb0, mSb0)';  %% 2018/8/21追加
%                    
%        prior_b=reshape([zeros(nk,m.fli), eye(nk), zeros(nk,nk*(nl-1))]',1,nk*(nk*nl+m.fli));
% %       mb(nl+1:end, :) = mb(nl+1:end, :) + ones(size(msampb,1)-nl,1).*prior_b;     
%        mb(nl+1:end, :) =  0.9*ones(size(msampb,1)-nl,1).*prior_b;  %% 2018/8/21追加
     

    
  %%--- sampling a ---%%
    
    for i = nl+1 : ns
       myh(i, :) = m.my(i, :) - mb(i, :) * amX(:, :, i)';
       amXh(:, :, i) = fXh(myh(i, :), nk, na);
       amG2(:, :, i) = diag(exp(mh(i, :)));     
    end
  
    ma(nl+1:end, :) ...
     = ssmooth(myh(nl+1:end,:), amXh(:,:,nl+1:end), ...
               amG2(:,:,nl+1:end), mSiga, va0, mSa0)';
  
  %%--- sampling h ---%%

    for i = nl+1 : ns
        mya(i, :) = myh(i, :) * fAt(ma(i, :), nk)';
    end
           
    for i = 1 : nk
        mh(nl+1:end, i) ...
         = svsamp(mya(nl+1:end,i), mh(nl+1:end,i), ...
                  mSigh(i,i), vh0(i), mSh0(i,i), nK);
    end


  %%--- sampling Sigma ---%%
  
    mdif = diff(mb(nl+1:end, :));
     
     if m.flSb == 1        
%        drD = rcond(mS0 + mdif'*mdif);
%        if isnan(drD) || (drD < eps*10^2)
            mSb = inv(mS0);
%        else        
%            mSb = inv(mS0 + mdif'*mdif);
%        end        
%       mSb = (mSb + mSb')/2;
%       [mL, p] = chol(mSb, 'lower');
%       if p > 0
%         mSb = diag(diag(mSb));
%       end
     
      mSigb = inv(wishrnd(mSb, dnub));     % 2021/12/08: comment out
      mSigb = 1*(mSigb + mSigb')/2;     %  2021/12/08: comment out
    else
      vSb = m.dVb0 + sum(mdif.^2);
      mSigb = diag(1 ./ gamrnd(dnub/2, 2./vSb));    % 2021/12/08: comment out
    end
    
   %   vSa = m.dVa0*ones(1,na) + sum(diff(ma(nl+1:end, :)).^2);
      vSa = m.dVa0*ones(1,na) ;
     mSiga = diag(1 ./ gamrnd(dnua/2, 2./vSa));     % 2021/12/08: comment out
    
   % vSh = m.dVh0 + sum(diff(mh(nl+1:end, :)).^2);
      vSh = m.dVh0 *ones(1,nk);
 %     mSigh = eye(nk) * (0.1+0.05*rand(1));
    mSigh = diag(1 ./ gamrnd(dnuh/2, 2./vSh));


%%--- storing sample ---%%
        if mod(m_k, div_k )==0 
             disp([num2str(jj) char('-th CPU :') num2str(m_k), char('-th iteration') ]);
        end        

    if m_k > 0             
        
        msamp(m_k, :) = [mSigb(1, 1) mSigb(2, 2) mSigb(3, 3) mSigb(4, 4) mSigb(5, 5)...
                         mSiga(1, 1) mSiga(2, 2)  mSiga(3, 3)  mSiga(4, 4) mSiga(5, 5) ...
                         mSigh(1, 1) mSigh(2, 2)   mSigh(3, 3) mSigh(4, 4)  mSigh(5, 5)  ];

        msamph   = msamph  + mh;
        msamphs  = msamphs + mh.^2;
        msampa   = msampa  + ma;
        msampas  = msampas + ma.^2;
        msampai  = msampai  + mai;
        msampais = msampais + mai.^2;

        msampb = msampb + mb(:, vidb);
        msampbs = msampbs + mb(:, vidb).^2;
        
        if m.fli == 1
            msampi  = msampi + mb(:, vidi);
            msampis = msampis + mb(:, vidi).^2;
        end
        if m.flfi == 1        
      %%--- impulse response ---%%      
        else
            
       % check of stationarity
%            F(1:nk,1:nk*nl+m.fli)= reshape( mean(mb(nl+1:end,:),1), nk*nl+m.fli, nk)';
%                eigen           = max(eig(F(:,1+m.fli:nk*nl+m.fli)));
%                largeeig     = abs(eigen);

%           if   largeeig < 1   % stationarity
               
               [mimpm_temp2, sign_chk,A0_t] = ...
                   impulse_zero_sign_v1(nl, m.nimp, mb(:, vidb), ma, mh,...
                                        method_type, policy_type,svar_type);
%               
                for t = 1:ns
                    if sign_chk(t)==1  
                       mimpm_temp(:,:,t) = mimpm_temp(:,:,t) + mimpm_temp2(:,:,t) ;                         
                       mimpms_temp(:,:,t) =mimpms_temp(:,:,t)+ mimpm_temp2(:,:,t).^2 ;
                       mA01_t(t,:) =    mA01_t(t,:) + A0_t(t,:,1);
                       mA01s_t(t,:) =  mA01s_t(t,:) + A0_t(t,:,1).^2;
                        mA02_t(t,:) =    mA02_t(t,:) + A0_t(t,:,2);
                       mA02s_t(t,:) =  mA02s_t(t,:) + A0_t(t,:,2).^2;                       
                       n_IRF(t)=n_IRF(t)+1;
                       
                       %% stractural shock 
                         mAinv = finvm(fAt(ma(t, :), nk));
                         amG2(:, :, t) = mAinv * diag(exp(mh(t,:))) * mAinv'; 
                         for i=1:4
%                              size(A0_t)
%                          size( squeeze(A0_t(t,:,1)) )
%                          size(squeeze(amG2(:, :, t)) )
%                          size(squeeze(A0_t(t,:,1))' )
                            msamph2(t,i) =  msamph2(t,i) +  log(A0_t(t,:,i)*amG2(:, :, t)*A0_t(t,:,i)');
                            msamph2s(t,i) =  msamph2s(t,i) + log(( A0_t(t,:,i)*amG2(:, :, t)*A0_t(t,:,i)'))^2;
                         end
                    end
                end                
              
%           end                     
            
            
        end
               
    if mod(m_k, div_k) == 0       % print counter
%         fprintf('%i \n', m_k, '-th iterations');
        
     disp(['Accept Rates = ' num2str(100*mean(n_IRF(nl+1:ns)/m_k)), ' (%)'  ] )
     disp(['Time = ' num2str( round(toc/6)/10 ), ' (min)' ])
     
        h =figure(999);
         plot(n_IRF(nl+1:ns)/m_k);
%         plot(n_IRF/m_k);
        title('Accept Rates of Sign Restrictons in each period')       
        pause(0.05);
    end
    
    if mod(m_k, div_k*100) == 0   
%          save_impulse;
    end
    
   end  
end


%%--------------- S A M P L I N G   E N D ----------------%%

%%--- output result ---%%

iBm = min([500, nsim/2]);   % bandwidth
iacf = iBm;

aspar = char('sb1  ', 'sb2',  'sb3', 'sb4', 'sb5',   'sa1', 'sa2', 'sa3', 'sa4', 'sa5', 'sh1', 'sh2',  'sh3', 'sh4', 'sh5'  );
aspar2 = char('  s_{b1}', '  s_{b2}', '  s_{a1}', ...
              '  s_{a2}', '  s_{h1}', '  s_{h2}');
    
est_date = datestr(date);   
result_name = ['./output/result', num2str(nsim), '_', est_date ,policy_type, svar_type, '.txt'];          
fileID = fopen(result_name,'w');
   
fprintf(fileID,'\n\n                        [ESTIMATION RESULT]');
fprintf(fileID,'\n----------------------------------');
fprintf(fileID,'------------------------------------');
fprintf(fileID,'\nParameter   Mean      Stdev       ');
fprintf(fileID,'95%%U       95%%L    Geweke     Inef.');
fprintf(fileID,'\n----------------------------------');
fprintf(fileID,'------------------------------------\n');

if nsim >= 50
msamp = sqrt(msamp);
for i = 1 : npmt
    vsamp = msamp(:, i);
    vsamp_s = sort(vsamp);
fprintf(fileID,'%s %10.4f %10.4f %10.4f %10.4f %9.3f %9.2f\n',...
        aspar(i, :), ...
        [mean(vsamp), std(vsamp), ...
         vsamp_s(floor(nsim*[0.1;0.9]))'], ...
          fGeweke(vsamp, iBm), ...
         ftsvar(vsamp, iBm)/var(vsamp));
end          
end

fprintf(fileID,'-----------------------------------');
fprintf(fileID,'-----------------------------------');
fprintf(fileID,'\nTVP-VAR model (Lag = %i', nl);
fprintf(fileID,')\nIteration: %i', nsim);
if m.flSb == 0
  fprintf(fileID,'\nSigma(b): Diagonal');
end

fclose(fileID);

%%--- output graphs ---%%

%% parameters %%

vacf = zeros(iacf, 1);
figure(101)
for i = 1 : npmt
    for j = 1 : iacf
        macf = corrcoef(msamp(j+1:end, i), ...
                           msamp(1:end-j, i));
        vacf(j) = macf(2, 1);
    end
%     subplot(3, npmt, i)        
%     sysh = stem(vacf);              % autocorrelation
%     set(sysh, 'Marker', 'none')
%     axis([0 iacf -1 1])
%     title(aspar2(i, :))
%     subplot(3, npmt, npmt+i);
%     plot(msamp(:, i))               % sample path
%     title(aspar2(i, :))
%     vax = axis;
%     axis([0 nsim vax(3:4)])
%     subplot(3, npmt, npmt*2+i)
%     hist(msamp(:, i), 15)           % posterior density
%     title(aspar2(i, :))
end

%% draw h %%
 
 msamph = msamph / nsim;   % posterior mean
 msamphs = sqrt(msamphs/nsim - msamph.^2);
                          % posterior standard deviation  

if m.fli == 1
    m.my = m.my + ones(ns, 1) * vym;
end

figure(102)
for i = 1 : nk
    subplot(2, nk, i);
    plot(m.my(nl+1:end, i))
    vax = axis;
    axis([0 ns-nl vax(3:4)])
    if vax(3) * vax(4) < 0
        line([0, ns], [0, 0], 'Color', ones(1, 3)*0.6)
    end
    if i == 1
      title(['Data: ', char(m.asvar(i))], ... 
            'interpreter', 'latex')
    else
      title(char(m.asvar(i)), 'interpreter', 'latex')
    end
end
for i = 1 : nk
    subplot(2, nk, i+nk);
    plot(exp(msamph(nl+1:end, i)))
    hold on
    plot(exp(msamph(nl+1:end, i) - msamphs(nl+1:end, i)), 'r:')
    plot(exp(msamph(nl+1:end, i) + msamphs(nl+1:end, i)), 'r:')
    hold off
    vax = axis;
    axis([1 ns-nl vax(3:4)])
    if i == 1
      legend('Posterior mean', '1SD bands')
    else
      title(char(m.asvar(i)), 'interpreter', 'latex')        
    end
end

mout = [msamph msamphs];
save(['./output/tvpvar_vol_' num2str(jj) '.xls'], 'mout', '-ascii', '-tabs');

mout = [msamph2 msamph2s];
save(['./output/tvpvar_sv_' num2str(jj)  '_' , num2str(date) '.xls'], 'mout', '-ascii', '-tabs');

%% draw b %%
  msampb = msampb / nsim;   % posterior mean
  msampbs = sqrt(msampbs/nsim - msampb.^2);
                         % posterior standard deviation  
  mout = [msampb msampbs];
  save(['./output/tvpvar_b_' num2str(jj) '_' , num2str(date)  '.xls'], 'mout', '-ascii', '-tabs');

%% draw a %%
 
 msampa = msampa / nsim;   % posterior mean
 msampas = sqrt(msampas/nsim - msampa.^2);
                          % posterior standard deviation  


mout = [msampa msampas];
save(['./output/tvpvar_a_' num2str(jj) '_' , num2str(date)  '.xls'], 'mout', '-ascii', '-tabs');

%% draw a-inverse %%

 msampai = msampai / nsim;   % posterior mean
 msampais = sqrt(msampais/nsim - msampai.^2);
                          % posterior standard deviation  


mout = [msampa msampas];
save(['./output/tvpvar_ai_' num2str(jj)  '_' , num2str(date)  '.xls'], 'mout', '-ascii', '-tabs');

if m.fli == 1
    
  %% draw intercept %%

  msampi = msampi / nsim;   % posterior mean
  msampis = sqrt(msampis/nsim - msampi.^2);
                          % posterior standard deviation  

  mout = [msampi msampis];
  save( ['./output/tvpvar_int_' num2str(jj) '_' , num2str(date)  '.xls'], 'mout', '-ascii', '-tabs');
end

%% save impulse response %%

if m.flfi == 1
    mimpm = impulse(nl, m.nimp, msampb, msampa,...
                    msamph);               
           
else
    
    mimpm = [];   
    mimpms = []; 
%      mA0 = [];
%      mA0s = [];
    for i = 1:size(mimpm_temp,3)
       
        mimpm = [mimpm; mimpm_temp(:,:,i) ] ;
        mimpms = [mimpms;  mimpms_temp(:,:,i) ] ;
        
%         mA0 = [mA0;mA0_t(i,:) ];
%         mA0s = [mA0s;mA0s_t(i,:) ];
        
    end 
    
                      
%     change_shock_size;  %  財政ショックのサイズの基準化   
       nimp = size(mimpm, 1) / ns;
       
     save(['./output/tvpvar_imps_' num2str(jj), '_' , num2str(date) ,  '.xls'], 'mimpms',  '-ascii', '-tabs');

end

save(['./output/tvpvar_imp_' num2str(jj), '_' , num2str(date) , '.xls'], 'mimpm',  '-ascii', '-tabs');
save(['./output/tvpvar_a0_' num2str(jj), '_' , num2str(date) ,  '.xls'], 'mA01_t',  'mA02_t', '-ascii', '-tabs');
save(['./output/tvpvar_a0s_' num2str(jj),  '_' , num2str(date) , '.xls'], 'mA01s_t', 'mA02s_t',  '-ascii', '-tabs');

% save_name_para = ['./output/para_save_', num2str(jj) ,'_' , num2str(nsim), '_',...
%                     est_date ,policy_type, svar_type, '.mat'];
save_name_para = ['./output/para_save_', num2str(jj), '_' , num2str(date) ,  '.mat'];                
save(save_name_para, 'nl','nimp', 'nsim', 'msampb', 'msampa', 'msamph','n_IRF', 'msamp' );  



fprintf('\n\nRanseed: %i', m.iseed);
fprintf('\nTime: %.2f', toc);
fprintf('\n\n')



