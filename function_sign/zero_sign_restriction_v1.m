function [P, sign_P, sign_chk,A0_t] = zero_sign_restriction_v1(amOmsq,nk, t, nl,nlen,mbs,svar_type)

A0_t   = zeros(nk,nk);

  sign_P=ones(nk,1);

switch svar_type
      case 'both_zero_sign'    
            type_of_restriction = 'Zero_Restriction';     % ゼロ制約と符号制約の２重制約を行う
      case 'just_sign'
            type_of_restriction = 'Just_Sign_Restriction';  % 符号制約のみ行う
  end
  

%====================================================
%  Make Matrix Q and S for Zero and Sign Restrictions
%====================================================

definition_matrix_Q_S_v1; 

IR_0=[];
IR_inf=[];

for i = 1:nk 
 my(nl+1, :) = amOmsq(:,i,t)' ;  % 1期目の制約付きレスポンス

%  2期以降の　インパルス応答
  for j = nl+2 : nl+nlen
       my(j, :) = mbs(t+j-nl-1,:) * fXt(my(j-nl:j-1,:), 0)';
  end
  
  IR_0 = [IR_0;  my(nl+1, :) ];       % 短期のインパルス応答
  IR_inf = [IR_inf; my(nl+nlen,:)];  % 長期のインパルス応答 (RWT,2010, P670)
end

%disp('短期と長期のインパルス応答　関数 F');
  A0 = inv(amOmsq(:,:,t)'); 
  
% F = [IR_0'; IR_inf'];
 F = [A0; IR_0'; IR_inf' ];

P=[];

%====================================================
%  Zero Restriction
%====================================================

switch type_of_restriction
case 'Zero_Restriction'

 for i = 1:(nk-1)

   Q_bar = abs(orth(squeeze(Q(:,:,i))')); 
   
   if isempty(Q_bar) == 1
         x1 = randn(nk-i,nk); % 制約iをダミーで処理
         Q_til = [x1; P'];
         [QQ,T]=qr(Q_til');
   else    
         % 制約 i の処理 
           Q_til = [Q_bar' * F; P'];
         % QR decomposition
           [QQ,T]=qr(Q_til');
   end
         col_P = QQ(:,nk); % 直交行列 Pのi列目
         P=[P col_P ]; 
 end    
   
   Q_til = P';
   [QQ,T]=qr(Q_til');
   col_P = QQ(:,nk); % 直交行列 Pの最終列目
   P=[P col_P ]; 
   
case 'Just_Sign_Restriction'
     
    xx = randn(nk,nk);
    
    [P, T] = qr(xx);
end
       
    
%====================================================
%  Sign Restriction
%====================================================

sign_OK = 0;  FP =0; MP=0; BC=0;
%  sign_OK = 1;  FP =1; MP=1; BC=1;
% 

% method ='element' ;  % 'matrix';
method = 'matrix';

switch method
        
case 'matrix'
    
for i = 1:size(S,3)
    S_bar0 = (squeeze(S(:,:,i))');
    S_bar=[];
    for  k = 1:5
         if  any(S_bar0(:,k)~=0);  
             S_bar=[S_bar, S_bar0(:,k)]; 
         end
    end     
    
 
    
%     if i==2
%          disp(S_bar);
%     end    
        
 if isempty(S_bar)== 0 % S_barは空ではない   
    Sign_Res = S_bar'*F*P(:,i); 

    if  all(Sign_Res >= 0)
        sign_P(i) = 1; 
        sign_OK = 1;       

    elseif   all(Sign_Res <= 0)
          sign_P(i) = -1;
          sign_OK = 1;
    else   
       sign_OK = 0; % Sign Restriction fail
       break;
    end
 end
   
    if i==1  %  MPショック    
        A0_temp=sign_P(i)*F*P(:,i);
        A0_t(:,1)=A0_temp(1:nk,1);
    elseif i==2
         A0_temp=sign_P(i)*F*P(:,i);
        A0_t(:,2)=A0_temp(1:nk,1);
    else
          A0_temp=sign_P(i)*F*P(:,i);
        A0_t(:,i)=A0_temp(1:nk,1);
    end
    
end

    
%*
case 'element'

for i = 1:4 % 
%     S_bar = orth(squeeze(S(:,:,i))');
    
    S = F*P(:,i);
    
    if i==1 %  MPショック    
        A0_t=F*P(:,i); 
    end
    
    if i == 1  %  MPショック              
      if (S(4)<0)&&(S(5)>0)
         sign_P(i) = 1; 
         sign_OK = 1;       
      elseif  (S(4)>0)&&(S(5)<0)
          sign_P(i) = -1;
          sign_OK = 1;
      else   
       sign_OK = 0; % Sign Restriction fail
        break;
      end
      
    elseif i ==2  % Gov ショック
      if (S(1)>0)&&(S(3)>0)
         sign_P(i) = 1; 
         sign_OK = 1;       
      elseif   (S(1)<0)&&(S(3)<0)
          sign_P(i) = -1;
          sign_OK = 1;
      else   
       sign_OK = 0; % Sign Restriction fail
        break;
      end
        
 elseif i ==3  %  debtショック
      if (S(3)>0)
         sign_P(i) = 1; 
         sign_OK = 1;       
      elseif   (S(3)<0)
          sign_P(i) = -1;
          sign_OK = 1;
      else   
       sign_OK = 0; % Sign Restriction fail
        break;
      end
   
    elseif  i ==4  % demand ショック
      if (S(2)>0)&&(S(3)<0)&&(S(4)>0)&&(S(5)>0)
         sign_P(i) = 1; 
         sign_OK = 1;       
      elseif   (S(2)<0)&&(S(3)>0)&&(S(4)<0)&&(S(5)<0)
          sign_P(i) = -1;
          sign_OK = 1;
      else   
       sign_OK = 0; % Sign Restriction fail
        break;
      end
 end
   
end

end % switch

%===============================

if sign_OK == 1;
     sign_chk = 1; % Sign Restriction Pass
else
     sign_chk = 0;  % Sign Restriction fail    
end

end % end of function
