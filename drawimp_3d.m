%%--------------------------------------------------------%%
%%                    TVP-VAR package                     %%
%%--------------------------------------------------------%%
%%
%%  [] = drawimp(vt, fldraw)
%%
%%  "drawimp" draws time-varying impulse response
%%
%%  [input]
%%   (fldraw = 1)
%%     vt:   m*1 vector of horizons to draw impulse
%%   (fldraw = 0)
%%     vt:   m*1 vector of time points to draw impulse
%%

%  function [] = drawimp_3d

global m_ns m_nk m_nl m_asvar m_vpd policy_type;

ns = m_ns;  
nk = m_nk; 
nl = m_nl; 

% load('para_save.mat');
 filename=('./output/'); 
mimpm = load([ filename '/tvpvar_imp_',char(policy_type),'-' ,char(svar_type),'.xls']);     % posterior means of IRF
mimpms = load( [ filename '/tvpvar_imps_',char(policy_type),'-' ,char(svar_type),'.xls' ] );   % Standard Deviation of IRF
                      
%  mimpm = load('tvpvar_imp_lag4_5000.xls');

nimp = size(mimpm, 1) / m_ns;
mline = [1 0 0;  0 0 1; 0 .5 0;  0 .7 .7];
vline = {':.', '-', '--', ':'};
% nline = size(vt, 2);


asvar = {'g';'y';'dbt';'pi';'int'};    

var_seq = { 'Gov';'Y'; 'Debt'; 'Pi'; 'R' };

policy = 'FP'; 

switch policy
    case 'FP'
       
            var_Gov = 1;
            shock_gov = 2;
            shock_seq =[1 2 3 4];  % 1:FP shock 
           asshock = {'mp';'gov';'demand';'supply'};
             graph_start= 1;
             graph_end  = 4;     
               idx = 2;    
             shock_s =1;
             shock_e =1; 
     
         case 'Caldala_Kamps_tax' 
            var_Gov = 2;
            shock_gov = 3;
            shock_seq =[1 2 3 4];  % 1:FP shock 
            asshock = {'gov';' ';'Tax';'Demand';'non'};
             graph_start= 3;
             graph_end  = 3;     
               idx = 2;    
             shock_s =3;
             shock_e =3;   
    
    case 'Tax'
          var_Gov = 3;
          shock_gov = 4;
end          
 


% グラフの回転
view_index = zeros(nk,nk,2);
for i = 1:nk
  view_index(i,:,:) = [-40*ones(nk,1) 20*ones(nk,1)];
end    
for i = 1:nk
%   view_index(i,1,:) = [-50+180 , 20]; % view(3番目のショック,1番目の変数) = [XY軸の回転,z軸の回転]
%   view_index(i,2,:) = [-50+180 , 20]; 
%   view_index(i,3,:) = [-50+180 , 20]; 
end 
  

 %  インパルス応答の作成
 for i = graph_start : graph_end

  h_(2000+i-idx+1)=figure(2000+i-idx+1);
  for j = 1 : nk
     id = (i-1)*nk + j;
    mimp = reshape(mimpm(:, id), nimp, ns)';
    
     subplot(2,3, j);
     
     y = 1953:0.25:1953+(ns-nl-1)/4;
     x = 1:nimp;
    [X,Y]=meshgrid(x,y);
     z = mimp(nl+1:ns,:); 

       surface(X,Y,z, gradient(z));
    set(gca,'Ydir', 'reverse')
       rotate3d on;
       grid on;
       grid minor
     set(gca,  'GridAlpha', 0.5);
     

      xlabel('horizon');
      ylabel('time');
      xlim([1954 2020 ]);
      
%        view(30+180, 50);
       view(-20, 60);

%         view(view_index(i,j,1),view_index(i,j,2))

%     hold off
       set(gca,'Fontsize',11)
    title(['$\varepsilon_{', char(asshock(i)), ...
           '}\uparrow\ \rightarrow\ ', ...
           char(m_asvar(j)), '$'], 'interpreter', 'latex','FontSize',16);
    axis([0 20 1950 2015 min(min(mimp(nl+1:ns,1:20))) max(max(mimp(nl+1:ns,1:20))) ]);
        
    %colormap(jet);
         colormap('winter' );
         colorbar 

  end
  
  est_date = datestr(date);   
    name = ['./Fig/imp_3d_1_',num2str(nimp-1),'_',char(asshock(i)),'_',char(var_seq(j)),'_',est_date];
    saveas(h_(2000+i-idx+1),name,'fig');
  
  
 end
 
% end


 
 
