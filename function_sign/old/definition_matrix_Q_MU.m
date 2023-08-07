
% 制約条件の設定
% 短期と長期のインパルス応答の制約 1 --> 1の数は6つ (インパルス応答が0となる制約)
Q1 = [0 0 0 0 0 0 0; ...   % short run y
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0; ...  %  pi
      0 0 0 0 0 0 0; ...   % long run  y    
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0 ]' ;  % pi
  
% 短期と長期のインパルス応答の制約 2  --> 1の数は5つ
Q2 =  [0 0 0 0 0 0 0; ...   % short run y
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0; ...  %  pi
      0 0 0 0 0 0 0; ...   % long run  y    
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0 ]' ;  % pi

 % 短期と長期のインパルス応答の制約 3 --> 1の数は4つ
 
Q3 = [0 0 0 0 0 0 0; ...   % short run y
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0; ...  %  pi
      1 0 0 0 0 0 0; ...   % long run  y    
      0 1 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 1 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0 ]' ;  % pi
 
  % 短期と長期のインパルス応答の制約 4 --> 1の数は3つ
  % Tax Rule
  Q4 =  [0 0 0 0 0 0 0; ...   % short run y
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0; ...  %  pi
      0 0 0 0 0 0 0; ...   % long run  y    
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0 ]' ;  % pi

 % 短期と長期のインパルス応答の制約 5 --> 1の数は2つ
 % Gov Rule 
Q5  =  [0 0 0 0 0 0 0; ...   % short run y
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0; ...  %  pi
      0 0 0 0 0 0 0; ...   % long run  y    
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0 ]' ;  % pi
  
 % 短期と長期のインパルス応答の制約 6 --> 1の数は1つ
 
Q6  =  [0 0 0 0 0 0 0; ...   % short run y
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0; ...  %  pi
      0 0 0 0 0 0 0; ...   % long run  y    
      0 0 0 0 0 0 0; ...   % c
      0 0 0 0 0 0 0; ...   % tax
      0 0 0 0 0 0 0;...    % g
      0 0 0 0 0 0 0; ...  % inv
      0 0 0 0 0 0 0; ...  % int
      0 0 0 0 0 0 0 ]' ;  % pi 
  
  Q=zeros(nk,2*nk,6);
Q(:,:,1) = Q1;
Q(:,:,2) = Q2;
Q(:,:,3) = Q3;
Q(:,:,4) = Q4;
Q(:,:,5) = Q5;
 Q(:,:,6) = Q6; 
  
