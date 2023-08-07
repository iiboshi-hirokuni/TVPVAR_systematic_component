

global m_ns m_nk m_nl m_asvar m_vpd policy_type;

ns = m_ns;  
nk = m_nk; 
nl = m_nl; 

%    svar_type = 'both_zero_sign'  % Caldara and Kamp (2017)

       %   Y/G         C/G     Tax/G  G/G   Inv/G  int/G  inf/g
%ratio_g =[ 4.77476,  3.017358,  1/1,   1/1,   1.5,   1,     1    ];

us_bc=csvread('./data/US_BC.csv',1);
%ti = 1954:0.25:1954+(ns-nl-1)/4;

a0 = load(['./output/a0_',char(policy_type),'-' ,char(svar_type),'.xls']);
a0s = load(['./output/a0s_',char(policy_type),'-' ,char(svar_type),'.xls']);

a0var=(a0s-a0.^2);

%phi_pi_var =a0var(:,4)./a0(:,5).^2+a0var(:,5).*a0(:,4).^2./a0(:,5).^4;
phi_y_var =a0var(:,2)./a0(:,5).^2+a0var(:,5).*a0(:,2).^2./a0(:,5).^4;
phi_pi_var =a0var(:,4)./a0(:,5).^2+a0var(:,5).*a0(:,4).^2./a0(:,5).^4;

%phi_pi = -a0(:,4)./a0(:,5);
%phi_pi_se =sqrt(phi_pi_var); 
phi_y = -a0(:,2)./a0(:,5);
phi_y_se = sqrt(phi_y_var); 
phi_pi = -a0(:,4)./a0(:,5);
phi_pi_se = sqrt(phi_pi_var); 

ti = 1952+2+(m_nl+4+1)/4:0.25:1952+(m_ns)/4+2;

figure('File','A0_MP_rule');

h=area(ti, [ -100*ones(m_ns-(m_nl+4),1) 500*us_bc(m_nl+1:end-1,type)] , 'LineStyle','non') ;
%h=area(ti, [ -100*ones(260,1), 500*us_bc(2:end,2)] , 'LineStyle','non') ;
      set(h(1),'FaceColor',[1 1 1])  
      set(h(2),'FaceColor',[0.5,1,1])  % blue

% set(hd,'FontSize',14)
hold on
%l1=plot(ti,phi_pi(nl+1:end),'b-','LineWidth',2);
%l1=plot(ti,phi_pi(nl+1+4:ns),'b-','LineWidth',2);
l1= plot(ti,phi_pi(nl+1+4:end),'b-','LineWidth',2);
  
%l11=plot(ti,phi_pi(nl+1:end)+phi_pi_se(nl+1:end),'b:','LineWidth',2);
 %l12=plot(ti,phi_pi(nl+1:end)-phi_pi_se(nl+1:end),'b:','LineWidth',2);
 %l11=plot(ti,phi_pi(nl+1+4:end)+phi_pi_se(nl+1+4:end),'b:','LineWidth',2);
 %l12=plot(ti,phi_pi(nl+1+4:end)-phi_pi_se(nl+1+4:end),'b:','LineWidth',2);
 l11=plot(ti,phi_pi(nl+1+4:end)+phi_pi_se(nl+1+4:end),'b:','LineWidth',2);
 l12=plot(ti,phi_pi(nl+1+4:end)-phi_pi_se(nl+1+4:end),'b:','LineWidth',2);
 
%l2= plot(ti,phi_y(nl+1:end),'r-.','LineWidth',2);
 l2= plot(ti,phi_y(nl+1+4:end),'r-.','LineWidth',2);
  
 %l21=plot(ti,phi_y(nl+1:end)+phi_y_se(nl+1:end),'r:','LineWidth',2);
 %l22=plot(ti,phi_y(nl+1:end)-phi_y_se(nl+1:end),'r:','LineWidth',2);
 l21=plot(ti,phi_y(nl+1+4:end)+phi_y_se(nl+1+4:end),'r:','LineWidth',2);
 l22=plot(ti,phi_y(nl+1+4:end)-phi_y_se(nl+1+4:end),'r:','LineWidth',2);
 
hold off
set(gca,'FontSize',12)
title('Monetary Policy Rule','FontSize',14)
  %legend([l1,l2],{'\phi_\pi','\psi_{y}','\psi_c','\psi_i'},'FontSize',14)
  legend([l1,l2],{'\phi_\pi','\phi_{y}'},'FontSize',14)
  ylim([-1 2.5])
  xlim([1955 2020])
%%
psi_y_var =a0var(:,7)./a0(:,6).^2+a0var(:,6).*a0(:,7).^2./a0(:,6).^4;
psi_d_var =a0var(:,8)./a0(:,6).^2+a0var(:,6).*a0(:,8).^2./a0(:,6).^4;

psi_y = -a0(:,7)./a0(:,6);
psi_y_se = sqrt(psi_y_var); 
psi_d = -a0(:,8)./a0(:,6);
psi_d_se = sqrt(psi_d_var); 
 
%psi_y = -a0(:,7)./a0(:,6);
%psi_d = -a0(:,8)./a0(:,6);
%psi_y_var =a0var(:,7)./a0(:,6).^2+a0var(:,6).*a0(:,7).^2./a0(:,6).^4;
%psi_d_var =a0var(:,8)./a0(:,6).^2+a0var(:,6).*a0(:,8).^2./a0(:,6).^4;
%psi_y_var =a0var(:,8)./a0(:,7).^2+a0var(:,7).*a0(:,8).^2./a0(:,7).^4;
%psi_d_var =a0var(:,9)./a0(:,7).^2+a0var(:,7).*a0(:,9).^2./a0(:,7).^4;
%psi_y_se =sqrt(psi_y_var);
%psi_d_se =sqrt(psi_d_var);

figure('File','A0_FP_rule');
 %h=area(ti, [ -100*ones(ns-nl,1), 500*us_bc(1+1:end,2)] , 'LineStyle','non') ;
 h=area(ti, [ -100*ones(m_ns-(m_nl+4),1) 500*us_bc(m_nl+1:end-1,type)] , 'LineStyle','non') ;
     set(h(1),'FaceColor',[1 1 1])  ;
     set(h(2),'FaceColor',[0.5,1,1]);  % blue

hold on

l1= plot(ti,psi_y(nl+1+4:end),'b-','LineWidth',2);
 
 l11=plot(ti,psi_y(nl+1+4:end)+psi_y_se(nl+1+4:end),'b:','LineWidth',2);
 l12=plot(ti,psi_y(nl+1+4:end)-psi_y_se(nl+1+4:end),'b:','LineWidth',2);

l2= plot(ti,psi_d(nl+1+4:end),'r-.','LineWidth',2);
 
 l21=plot(ti,psi_d(nl+1+4:end)+psi_d_se(nl+1+4:end),'r:','LineWidth',2);
 l22=plot(ti,psi_d(nl+1+4:end)-psi_d_se(nl+1+4:end),'r:','LineWidth',2);


%l1=plot(ti,psi_y(nl+1:end),'b-','LineWidth',2);
%l1=plot(ti,psi_y(nl+1+4:end),'b-','LineWidth',2);
    %l11=plot(ti,psi_y(nl+1:end)+psi_y_se(nl+1:end),'b:','LineWidth',2);
    %l12=plot(ti,psi_y(nl+1:end)-psi_y_se(nl+1:end),'b:','LineWidth',2);
    %l11=plot(ti,psi_y(nl+1+4:end)+psi_y_se(nl+1+4:end),'b:','LineWidth',2);
    %l12=plot(ti,psi_y(nl+1+4:end)-psi_y_se(nl+1+4:end),'b:','LineWidth',2);
    
%l2=plot(ti,psi_d(nl+1:end),'r-.','LineWidth',2);
%l2=plot(ti,psi_d(nl+1+4:end),'r-.','LineWidth',2);
   %l21=plot(ti,psi_d(nl+1:end)+psi_d_se(nl+1:end),'r:','LineWidth',2);
   %l22=plot(ti,psi_d(nl+1:end)-psi_d_se(nl+1:end),'r:','LineWidth',2);
 %l21=plot(ti,psi_d(nl+1+4:end)+psi_d_se(nl+1+4:end),'r:','LineWidth',2);
 %l22=plot(ti,psi_d(nl+1+4:end)-psi_d_se(nl+1+4:end),'r:','LineWidth',2);
   
   hold off

set(gca,'FontSize',12)

legend([l1, l2],{'\psi_y', '\psi_d'},'FontSize',14)
title('Fiscal Policy Rule','FontSize',14)
   ylim([-2.5 1])
   xlim([1955 2020])