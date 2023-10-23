i=1:288;


randd=interp1(1:4:288,rand(1,72),i); 
P=interp1(price(:,1),price(:,2),i)+randd*2; 