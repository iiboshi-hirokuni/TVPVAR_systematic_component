%====================================================
%  Make Matrix Q and S for Zero and Sign Restrictions
%====================================================

%@Rubio-Ramirez, Waggoner, and Zha (2010) RES, p665-696
%  p.679  Sec.5.3. Impulse Response 


%==============================================
% Zero Restrictions
%==============================================

% {'g';'y';'dbt';'pi';'int'}; 

%@Monetary Policy shock
% number of zero restriction for short and long runs = 4  
% --> # of element "1" = 4  
Q1 =  [ 1 0 0 0 0; ...   % contemporaneous g
        0 0 0 0 0; ...   % y    
        0 1 0 0 0;...     % dbt
        0 0 0 0  0; ...  % pi
        0 0 0 0  0; ...  % int
        0 0 0 0  0; ...   % short run g
        0 0 0 0  0; ...   % y    
        0 0 0 0  0;...     % dbt
        0 0 0 0  0; ...  % pi
        0 0 0 0  0; ...  % int
        0 0 1 0  0; ...   % long run  g
        0 0 0 1  0; ...   % y      
        0 0 0 0  0;...     % dbt
        0 0 0 0  0; ...  % pi
        0 0 0 0  0  ]' ;     % int% 
  

% Gov shock
% number of zero restriction for short and long runs = 3  
% --> # of element "1" = 3  
Q2 = [0 0 0 0 0 ; ...   % contemporaneous g
      0 0 0 0 0 ; ...   % y
      0 0 0 0 0 ;...     % dbt
      1 0 0 0 0 ; ...  % pi
      0 1 0 0 0 ; ...  % int
      0 0 0 0 0 ; ...   % short run g
      0 0 0 0 0 ; ...   % y
      0 0 0 0 0 ;...     % dbt
      0 0 0 0 0 ; ...  % pi
      0 0 0 0 0 ; ...  % int
      0 0 0 0 0 ; ...   % long run  g
      0 0 1 0 0 ; ...   % y
      0 0 0 0 0 ;...     % dbt
      0 0 0 0 0; ...  % pi
      0 0 0 0 0   ]' ;     % int

 
 % Demand shock 
% number of zero restriction for short and long runs = 2  
% --> # of element "1" = 2  
Q3 =[0 0 0 0 0 ; ...   % contemporaneous g
          0 0 0 0 0 ; ...   % y
          0 0 0 0 0 ;...     % dbt
          0 0 0 0 0 ; ...  % pi
          0 0 0 0 0 ; ...  % int
          0 0 0 0  0; ...   % short run g
          0 0 0 0  0; ...   % y     
          0 0 0 0  0;...     % dbt
          0 0 0 0  0; ...  % pi
          0 0 0 0  0; ...  % int
          1 0 0 0  0; ...   % long run  g
          0 1 0 0  0; ...   % y    
          0 0 0 0  0;...     % dbt
         0 0 0 0 0; ...  % pi
         0 0 0 0  0  ]' ;     % int

   % Supply shock
   % number of zero restriction for short and long runs = 1  
% --> # of element "1" = 1 
Q4 = [0 0 0 0 0 ; ...   % contemporaneous g
          0 0 0 0 0 ; ...   % y
          0 0 0 0 0 ;...     % dbt
          0 0 0 0 0 ; ...  % pi
          0 0 0 0 0 ; ...  % int
          0 0 0 0  0; ...   % short run g
          0 0 0 0  0; ...   % y      
          0 0 0 0  0;...     % dbt
          0 0 0 0  0; ...  % pi
          0 0 0 0 0; ...  % int
          1 0 0 0 0; ...   % long run  g
          0 0 0 0 0; ...   % y    
       0 0 0 0  0;...     % dbt
       0 0 0 0  0; ...  % pi
       0 0 0 0  0  ]' ;     % int   

Q=zeros(nk,3*nk,4);
Q(:,:,1) = Q1;
Q(:,:,2) = Q2;
Q(:,:,3) = Q3;
Q(:,:,4) = Q4;
% Q(:,:,5) = Q5;


%---------------------------
%  Sign Restrictions 
%---------------------------
  % MP shock
 S1 =[0 0 0 0 0 ; ...   % contemporaneous g
          -1 0 0 0 0 ; ...   % y
          0 0 0 0 0 ;...     % dbt
          0 -1 0 0 0 ; ...  % pi
          0 0 1 0 0 ; ...  % int
         0 0  0 0 0; ...   % short run g
          0 0 0 0 0; ...   % y    
          0 0 0  0 0;...     % dbt
         0 0 0  -1 0; ...  % pi
          0  0 0  0 1; ...  % int
          0 0 0  0 0; ...   % long run  g
        0 0 0  0 0; ...   % y
       0 0 0  0 0;...     % dbt
       0 0 0  0 0; ...  % pi
       0 0 0  0 0  ]' ;     % int

% Government policy shock
% Gov >0 and GDP>0
S2 = [1 0 0 0 0 ; ...   % contemporaneous g
      0 0 0 0 0 ; ...   % y
      0 0 0 0 0 ;...     % dbt
      0 0 0 0 0 ; ...  % pi
          0 0 0 0 0 ; ...  % int
          0 0 1 0 0 ; ...   % short run g
         0 0 0 0 0 ; ...   % y    
        0 0 0 1 0 ;...     % dbt
        0 0 0 0 0 ; ...  % pi
       0 0 0 0 0 ; ...  % int
       0 0 0 0 0; ...   % long run  g
      0 0 0 0 0 ; ...   % y 
      0 0 0 0 0 ;...     % dbt
      0 0 0 0 0 ; ...  % pi
      0 0 0 0 0  ]' ;     % int

  % Demand shock 
  % r >0 & Pi < 0 & Y<0
S3 = [0 0 0 0 0 ; ...   % contemporaneous g
          1 0 0 0 0 ; ...   % y
          0 0 0 0 0 ;...     % dbt
          0 0 0 0 0 ; ...  % pi
          0 0 0 0 0 ; ...  % int
          0 0 0 0 0; ...   % short run g
        0 1 0  0 0; ...   % y      
      0 0 0  0 0;...     % dbt
      0 0  1  0 0; ...  % pi
      0 0 0  1 0; ...  % int
      0 0 0  0 0; ...   % long run  g
      0 0 0  0 0; ...   % y
      0 0 0 0 0;...     % dbt
      0 0 0  0 0; ...  % pi
      0 0 0  0 0  ]' ;     % int 

  % Supply shock 
S4 = [0 0 0 0 0 ; ...   % contemporaneous g
          0 0 0 0 0 ; ...   % y
          0 0 0 0 0 ;...     % dbt
          -1 0 0 0 0 ; ...  % pi
          0 0 0 0 0 ; ...  % int
          0 0 0 0 0; ...   % short run g
         0 1 0 0  0; ...   % y   >0
         0 0 0  0  0;...     % dbt <0
         0 0 -1 0 0; ...  % pi >0
         0 0 0  0  0 ; ...  % int >0
        0 0 0  0 0; ...   % long run  g
        0 0 0  0 0; ...   % y
       0 0 0  0 0;...     % dbt
       0 0 0 0 0; ...  % pi
       0 0 0 0 0  ]' ;     % int
% S=zeros(nk,2*nk,nk);
S=zeros(nk,3*nk,4);
 S(:,:,1) = S1;
 S(:,:,2) = S2;
 S(:,:,3) = S3;
  S(:,:,4) = S4;

% ----------------------------======================================
%  End of setting Matrix
% ==================================================================
