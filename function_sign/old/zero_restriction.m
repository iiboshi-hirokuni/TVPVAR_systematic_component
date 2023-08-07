function [P, FP, MP, BC] = zero_restriction(amOmsq,nk, t, nl,nlen,mbs)

%  2014/Dec/23 作成

%　Rubio-Ramirez, Waggoner, and Zha (2010) RES, p665-696
%  
%  p.679  Sec.5.3. Impulse Response 

% 制約条件の設定
% 短期と長期のインパルス応答の制約 1 --> 1の数は5つ (インパルス応答が0となる制約)
% 財政政策ショック
Q1 = [0 0 0 0 0 0; ...   % short run g
      0 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 0 0 0 0 0; ...  % pi
      0 0 0 0 1 0; ...  % int
      1 0 0 0 0 0; ...   % long run  g
      0 1 0 0 0 0; ...   % y
      0 0 1 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 0 0 1 0 0; ...  % pi
      0 0 0 0 0 0  ]' ;     % int
  
% 短期と長期のインパルス応答の制約 2  --> 1の数は4つ
% 景気循環
Q2 =  [0 0 0 0 0 0; ...   % short run g
       0 0 0 0 0 0; ...   % y
       0 0 0 0 0 0; ...  % cons
       0 0 0 0 0 0;...     % dbt
       0 0 0 0 0 0; ...  % pi
       0 0 0 0 0 0; ...  % int
       0 0 0 0 0 0; ...   % long run  g
       1 0 0 0 0 0; ...   % y
       0 1 0 0 0 0; ...  % cons
       0 0 0 0 0 0;...     % dbt
       0 0 1 0 0 0; ...  % pi
       0 0 0 1 0 0  ]' ;     % int

 % 短期と長期のインパルス応答の制約 3 --> 1の数は3つ
 % 金融政策 
Q3 = [0 0 1 0 0 0; ...   % short run g
      0 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 0 0 0 0 0; ...  % pi
      0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0; ...   % long run  g
      0 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 1 0 0 0 0; ...  % pi
      1 0 0 0 0 0  ]' ;     % int
 
  % 短期と長期のインパルス応答の制約 4 --> 1の数は2つ
  %　実物ショック
Q4 =  [0 0 0 0 0 0; ...   % short run g
       0 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      1 0 0 0 0 0; ...  % pi
      0 1 0 0 0 0; ...  % int
      0 0 0 0 0 0; ...   % long run  g
      0 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 0 0 0 0 0; ...  % pi
      0 0 0 0 0 0  ]' ;     % intt

 % 短期と長期のインパルス応答の制約 5 --> 1の数は1つ
 % 需要ショック
Q5  =  [0 0 0 0 0 0; ...   % short run g
       0 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 0 0 0 0 0; ...  % pi
      0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0; ...   % long run  g
      1 0 0 0 0 0; ...   % y
      0 0 0 0 0 0; ...  % cons
      0 0 0 0 0 0;...     % dbt
      0 0 0 0 0 0; ...  % pi
      0 0 0 0 0 0  ]' ;     % int

% 誘導系VARモデルの分散共分散行列
%sigma = [1   0.5  1  ;...
%         0.5 4.25 2.5;...
%         1   2.5  3  ];
% invsig = inv(sigma);
% A0 = chol(invsig);
% inv(A0'*A0);
% invA0 = inv(A0');
% invA0'*invA0*A0'*A0; %
% invA0'*invA0;
% chol(sigma)'*chol(sigma);

%---------------------------

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
F = [IR_0'; IR_inf'];

% 行が0だけのものを削除
Q1_bar = abs(orth(Q1'));
Q2_bar = abs(orth(Q2'));
Q3_bar = abs(orth(Q3'));
Q4_bar = abs(orth(Q4'));
Q5_bar = abs(orth(Q5'));

% 制約 1 の処理 
Q1_til = (Q1_bar' * F);
% QR decomposition
[Q,T]=qr(Q1_til');
P1 = Q(:,6)'; % 直交行列 Pの1列目

% 制約 2 の処理 
Q2_til = [ Q2_bar'*F; P1];
% QR decomposition
[Q,T]=qr(Q2_til');
P2 = Q(:,6)';  % 直交行列 Pの2列目

% 制約 3 の処理 
Q3_til = [ Q3_bar'*F; P1; P2];
% QR decomposition
[Q,T]=qr(Q3_til');
P3 = Q(:,6)';  % 直交行列 Pの2列目

% 制約 4 の処理 
Q4_til = [ Q4_bar'*F; P1; P2; P3];
% QR decomposition
[Q,T]=qr(Q4_til');
P4 = Q(:,6)';  % 直交行列 Pの2列目

% 制約 5 の処理 
Q5_til = [ Q5_bar'*F; P1; P2; P3; P4];
% QR decomposition
[Q,T]=qr(Q5_til');
P5 = Q(:,6)';  % 直交行列 Pの2列目

% 制約 6 の処理
Q6_til = [P1; P2; P3; P4; P5] ;
% QR decomposition
[Q,T]=qr(Q6_til');
P6 = Q(:,6)'; % 直交行列 Pの3列目

%disp('直交行列(ユニタリ行列) i.e.,　P*P = I');
P=[P1' P2' P3' P4' P5' P6'];  % 直交行列、ユニタリ行列　P'*P = I

i = 1;    % 財政政策(政府ショック)ショックを起こす係数のorder
 my(nl+1, :) = (  amOmsq(:,:,t)*P(:,i) )' ;
 Imp_FP =  my(nl+1, :);
 
if( Imp_FP(1)>0)  % Gov >0
    FP = 1;      
elseif (-1*Imp_FP(1)>0 )
    FP = -1;     
end    

i = 2;    % 景気循環ショックを起こす係数のorder 
  my(nl+1, :) = (  amOmsq(:,:,t)*P(:,i) )' ;
 Imp_BC =  my(nl+1, :);
 
if( Imp_BC(2)>0)  % Y >0
    BC = 1;      
elseif (-1*Imp_BC(2)>0 )
    BC = -1;     
end    

 i = 3;    % 金融政策ショックを起こす係数のorder 
   my(nl+1, :) = (  amOmsq(:,:,t)*P(:,i) )' ;
 Imp_MP =  my(nl+1, :);
 
if( Imp_MP(6)>0)   % r >0
    MP = 1;      
elseif (-1*Imp_MP(6)>0 )
    MP = -1;     
end   

 


%========================================================== 
%  ゼロ制約の試験の実施
% =========================================================

test = 0;  % yes--> 1 no--> 0

if test == 1

if t== 15 
disp('直交行列の検算 P^T * P = I');
 disp( P'*P );  %　直交行列の検算　単位行列になるか
% 
% % 制約１とショック1の検算 
 e1 = [1; 0; 0; 0; 0; 0 ]; % ショック1
disp('制約１とショック1の検算: Q1*F*P*e1, 直交行率 P あり ');
%   disp( Q1*F*P*e1 );  % 直交行率 P あり　すべての値が0に近くなるか
  disp( Q1*F*P(:,1) ); 
% % 制約2とショック2の検算 
 e2 = [0;1;0; 0; 0; 0]; % ショック2
disp('制約2とショック2の検算: Q2*F*P*e2, 直交行率 P あり ');
% disp( Q2*F*P*e2 );  % 直交行率 P あり
 disp( Q2*F*P(:,2) );  
% % 制約3とショック3の検算 
 e3 = [0;0;1; 0; 0; 0]; % ショック2
disp('制約3とショック3の検算: Q2*F*P*e3, 直交行率 P あり ');
% disp( Q3*F*P*e3 );   % 直交行率 P あり
  disp( Q3*F*P(:,3) );  
% % 制約4とショック4の検算 
 e4 = [0;0;0; 1; 0; 0]; % ショック2
disp('制約4とショック4の検算: Q4*F*P*e4, 直交行率 P あり ');
% disp( Q4*F*P*e4 );   % 直交行率 P あり
   disp( Q4*F*P(:,4) ); 
% % 制約5とショック5の検算 
 e5 = [0;0;0; 0; 1; 0]; % ショック2
disp('制約5とショック5の検算: Q2*F*P*e5, 直交行率 P あり ');
% disp( Q5*F*P*e5 );   % 直交行率 P あり
 disp( Q5*F*P(:,5) );   
end

end

end