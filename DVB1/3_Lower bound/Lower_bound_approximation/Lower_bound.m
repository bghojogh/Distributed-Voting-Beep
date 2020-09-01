%%
clc;
clear all;
close all;

%%
count=1;
n=100;
delta=(0.51:0.04:0.99);
n1range=floor(n*delta);
c=20;
p=0.5;
maxIter=2000;
for n1=n1range
    n2=n-n1;
    r=1:ceil(log2(c*n));
    T=c+ceil(log2(n)); %T=ceil(log2(c*n));  
    %plot(r,(1-p.^r).^n2.*(1-(1-p.^r).^n1));
%     LB2=(1-p.^ceil(log2(c*n2))).^n2.*(1-(1-p.^ceil(log2(c*n2))).^n1);
%     LB=max((1-p.^r).^n2.*(1-(1-p.^r).^n1));
    
    LB = max( ( ( 1 - ( (1-p.^r).^n1 + choose_y_from_x(n1, 1).*(p.^r).*(1-p.^r).^(n1-1) ) ) .* ...
         ( (1-p.^r).^n2 + choose_y_from_x(n2, 1).*p.^r.*(1-p.^r).^(n2-1) ) ) + ... 
         choose_y_from_x(n1, 1).*(p.^r).*(1-p.^r).^(n1-1).*(1-p.^r).^n2 );
    
    last_round = ceil(log2(c*n2));
    LB2 = ( ( 1 - ( (1-p.^last_round).^n1 + choose_y_from_x(n1, 1).*(p.^last_round).*(1-p.^last_round).^(n1-1) ) ) .* ...
          ( (1-p.^last_round).^n2 + choose_y_from_x(n2, 1).*p.^last_round.*(1-p.^last_round).^(n2-1) ) ) + ... 
          choose_y_from_x(n1, 1).*(p.^last_round).*(1-p.^last_round).^(n1-1).*(1-p.^last_round).^n2;
      
    LB3 = (1 - exp(-1 * sqrt(n1 / n2))) * exp(-1 * ((2-1)*n2) / (sqrt(n1 * n2) - 1));
     
%     succ=zeros(1,maxIter);
%     for i=1:maxIter
%         X1=ones(1,n1);
%         X2=ones(1,n2);
%         for t=1:T
%             X1=X1.*randsrc(1,n1,[0,1;p,1-p]);
%             X2=X2.*randsrc(1,n2,[0,1;p,1-p]);
%             if ~(sum(X1)==1 && sum(X2)==1)
%                 if sum(X1)>0 && (sum(X2)==0 || sum(X2)==1)
%                     succ(i)=1;
%                 end
%             end
%             %%%% if (sum(X1)==1 && sum(X2)==1) happens, then we wait again:
%             %%%% after more t's:
%             %%%% if they both become 0, we will have draw.
%             %%%% if one of them remains alive but the other one becomes
%             %%%% dead, then we enter the above "if" and the remained value wins.
%         end
%     end
    %actual(count)=mean(succ);
    lower_bound_Max(count)=LB;
    lower_bound_LastRound(count)=LB2;
    lower_bound_approximate(count)=LB3;
    count=count+1;
    disp(['n1: ', int2str(n1)])
end
%plot(delta,actual);
hold on;
plot(delta,lower_bound_Max);
plot(delta,lower_bound_LastRound);
plot(delta,lower_bound_approximate);

%%
cd('./saved_results/')
save delta.mat delta
%save actual.mat actual
save lower_bound_Max.mat lower_bound_Max
save lower_bound_LastRound.mat lower_bound_LastRound
save lower_bound_approximate.mat lower_bound_approximate
save workspace
cd('..')