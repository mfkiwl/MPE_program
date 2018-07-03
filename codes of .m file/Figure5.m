close all;
clear all;
clc

format long;


for i =1:31
s = strcat('gps-',num2str(i),'.txt');
DATA_SATE = load(s);
sat_x(i) = DATA_SATE(60,1)*1000;
sat_y(i) = DATA_SATE(60,2)*1000;
sat_z(i) = DATA_SATE(60,3)*1000;

end
user = load('UAV_350km.txt');   

[a,b] = size(user);

PL_N = 31;
%------------------------UAV_flight-------------------------------
pseudo = [1348613.08566989 4703173.8053762 4077986.5722003];   %pseudite location
SAT_N = 31;

%------------------simulation--------------------
for t = 1:a    %400     %600
    
   user_posx = user(t,2);
   user_posy = user(t,3);
   user_posz = user(t,4);
   
   record_userx(t) = user_posx;
   record_usery(t) = user_posy;
   record_userz(t) = user_posz;
   %--------------------------sat_ele-----------------------------

angle_ele = ENU(sat_x,sat_y,sat_z,user_posx,user_posy,user_posz);

 test_record_angle(:,t) = angle_ele;
 
  for kk=1:100, 
flag_num = 0;
for ii = 1:SAT_N
   if angle_ele(ii) > 10
       flag_num = flag_num+1;
       satx(flag_num) = sat_x(ii);
       saty(flag_num) = sat_y(ii);
       satz(flag_num) = sat_z(ii);  
       sat_err = 7.3*randn;
       sat_err_record(flag_num,t) = sat_err;
       pr_measure(flag_num) = sqrt((sat_x(ii)-user_posx)^2+(sat_y(ii)-user_posy)^2+(sat_z(ii)-user_posz)^2)+sat_err; 
   end
end
       record_num(t) = flag_num;   %the number of visible satellites

       satx(flag_num+1) = pseudo(1);
       saty(flag_num+1) = pseudo(2);
       satz(flag_num+1) = pseudo(3); 
       pse_err = sqrt(7.3^2+7.75^2)*randn;
       sat_err_record(flag_num+1,t) = pse_err;
       pr_measure(flag_num+1) = sqrt((satx(flag_num+1)-user_posx)^2+(saty(flag_num+1)-user_posy)^2+(satz(flag_num+1)-user_posz)^2)+pse_err; 


   clk = 0;
   ux = 0;
   uy = 0;
   uz = 0;   
   A=[];
   r=[];
   dp=[];

    for n = 1:100
    for k = 1:flag_num+0
         r(k) = sqrt((satx(k)-ux)^2+(saty(k)-uy)^2+(satz(k)-uz)^2);
          A(k,1) = (ux - satx(k))/r(k);
          A(k,2) = (uy - saty(k))/r(k);
          A(k,3) = (uz - satz(k))/r(k);
          A(k,4) = 1.0;
          dp(k) = -(r(k) - (pr_measure(k) - clk)); 
    end
     delta = (inv(A'*A))*(A')*(dp');
   
         ux = ux +delta(1);
         uy = uy +delta(2);
         uz = uz+delta(3);
         clk = clk +delta(4);
    
         err = sqrt(delta(1)^2+delta(2)^2+delta(3)^2);
       
         if(err<1e-5)
           break;
         end
         
    end
    
    posx0(t) = ux;
    posy0(t) = uy;
    posz0(t) = uz;
    
    users0(t,2)=ux;
    users0(t,3)=uy;
    users0(t,4)=uz;
  
%     poserr_kk0(kk) = sqrt((user_posx - ux)^2+(user_posy - uy)^2+(user_posz - uz)^2);
     poserr_kk0 = sqrt((user_posx - ux)^2+(user_posy - uy)^2+(user_posz - uz)^2);
  end;

%     poserr0(t) = std(poserr_kk0);
    poserr0(t) = poserr_kk0;
    B = inv(A'*A);
   
    H_ENU = ENU_DOP( B, ux, uy, uz );
      
   hdop0(t) = sqrt(B(1,1)+B(2,2));
   vdop0(t) = sqrt(B(3,3));
   pdop0(t) = sqrt(B(1,1)+B(2,2)+B(3,3));
   gdop0(t) = sqrt(B(1,1)+B(2,2)+B(3,3)+B(4,4));
    
   hdop_enu0(t) = sqrt(H_ENU(1,1)+H_ENU(2,2));
   vdop_enu0(t) = sqrt(H_ENU(3,3));
   pdop_enu0(t) = sqrt(H_ENU(1,1)+H_ENU(2,2)+H_ENU(3,3));
   gdop_enu0(t) = sqrt(H_ENU(1,1)+H_ENU(2,2)+H_ENU(3,3)+H_ENU(4,4));
   
    %------------test--------------
%     xdop(t) = sqrt(B(1,1));
%     ydop(t) = sqrt(B(2,2));
    
    %-----------test_end-----------
    
end









%------------------simlation--------------------


for t = 1:a    %400     %600
    
   user_posx = user(t,2);
   user_posy = user(t,3);
   user_posz = user(t,4);
   
   record_userx(t) = user_posx;
   record_usery(t) = user_posy;
   record_userz(t) = user_posz;
   %--------------------------sat_ele-----------------------------

angle_ele = ENU(sat_x,sat_y,sat_z,user_posx,user_posy,user_posz);

 test_record_angle(:,t) = angle_ele;
 
  for kk=1:100, 
flag_num = 0;
for ii = 1:SAT_N
   if angle_ele(ii) > 10
       flag_num = flag_num+1;
       satx(flag_num) = sat_x(ii);
       saty(flag_num) = sat_y(ii);
       satz(flag_num) = sat_z(ii);  
       sat_err = 7.3*randn;
       sat_err_record(flag_num,t) = sat_err;
       pr_measure(flag_num) = sqrt((sat_x(ii)-user_posx)^2+(sat_y(ii)-user_posy)^2+(sat_z(ii)-user_posz)^2)+sat_err; 
   end
end
       record_num(t) = flag_num;   %the number of visible satellites

       satx(flag_num+1) = pseudo(1);
       saty(flag_num+1) = pseudo(2);
       satz(flag_num+1) = pseudo(3); 
%        pse_err = sqrt(2.4^2+7^2)*randn;
       pse_err = sqrt(7.3^2+7.75^2)*randn;
       sat_err_record(flag_num+1,t) = pse_err;
       pr_measure(flag_num+1) = sqrt((satx(flag_num+1)-user_posx)^2+(saty(flag_num+1)-user_posy)^2+(satz(flag_num+1)-user_posz)^2)+pse_err; 

   clk = 0;
   ux = 0;
   uy = 0;
   uz = 0;   
   A=[];
   r=[];
   dp=[];

    for n = 1:100
    for k = 1:flag_num+1
         r(k) = sqrt((satx(k)-ux)^2+(saty(k)-uy)^2+(satz(k)-uz)^2);
          A(k,1) = (ux - satx(k))/r(k);
          A(k,2) = (uy - saty(k))/r(k);
          A(k,3) = (uz - satz(k))/r(k);
          A(k,4) = 1.0;
          dp(k) = -(r(k) - (pr_measure(k) - clk)); 
    end
     delta = (inv(A'*A))*(A')*(dp');
   
         ux = ux +delta(1);
         uy = uy +delta(2);
         uz = uz+delta(3);
         clk = clk +delta(4);
    
         err = sqrt(delta(1)^2+delta(2)^2+delta(3)^2);
       
         if(err<1e-5)
           break;
         end
         
    end
    
    posx(t) = ux;
    posy(t) = uy;
    posz(t) = uz;
    
    users(t,2)=ux;
    users(t,3)=uy;
    users(t,4)=uz;
  
%     poserr_kk(kk) = sqrt((user_posx - ux)^2+(user_posy - uy)^2+(user_posz - uz)^2);
     poserr_kk = sqrt((user_posx - ux)^2+(user_posy - uy)^2+(user_posz - uz)^2);
  end;

%     poserr(t) = std(poserr_kk);
    poserr(t) = poserr_kk;
    B = inv(A'*A);
   
    H_ENU = ENU_DOP( B, ux, uy, uz );
      
   hdop(t) = sqrt(B(1,1)+B(2,2));
   vdop(t) = sqrt(B(3,3));
   pdop(t) = sqrt(B(1,1)+B(2,2)+B(3,3));
   gdop(t) = sqrt(B(1,1)+B(2,2)+B(3,3)+B(4,4));
    
   hdop_enu(t) = sqrt(H_ENU(1,1)+H_ENU(2,2));
   vdop_enu(t) = sqrt(H_ENU(3,3));
   pdop_enu(t) = sqrt(H_ENU(1,1)+H_ENU(2,2)+H_ENU(3,3));
   gdop_enu(t) = sqrt(H_ENU(1,1)+H_ENU(2,2)+H_ENU(3,3)+H_ENU(4,4));
   
    %------------test--------------
%     xdop(t) = sqrt(B(1,1));
%     ydop(t) = sqrt(B(2,2));
%     
    %-----------test_end-----------
    
%   POS_ERR(t) = poserr(t) - poserr0(t);
%   POS_3D_ERR(t) = sqrt((posx(t) - posx0(t))^2+(posy(t) - posy0(t))^2+(posz(t) - posz0(t))^2);
%   user_posx-posx(t)
  

end
%   POS_ERR_AA(AA) = mean(POS_ERR);
%   POS_3D_ERR_AA(AA) = mean(POS_3D_ERR);
% % end


figure(1);
set(gcf,'unit','centimeters','position',[2,2,12.9,13]);

subplot(2,1,1);

plot((1:a)*1.7766,poserr0,'b');
% text(300,100,num2str(mean(poserr0)));
hold on;
plot((1:a)*1.7766,poserr,'r');
str0 = strcat('positioning error without pseudolite mean: ',num2str(mean(poserr0)),' m');
str1 = strcat('positioning error with a pseudolite mean: ',num2str(mean(poserr)),' m');
grid on;

ylabel('positioning error��m��','fontsize',10);
legend(str0,str1,'location','best');


subplot(2,1,2);
plot3(user(:,2), user(:,3), user(:,4));hold on; 
plot3(pseudo(1),pseudo(2),pseudo(3),'ro');hold on; 
xlabel('x��m��','fontsize',10);
ylabel('y��m��','fontsize',10);
zlabel('z��m��','fontsize',10);
legend('The target trajectory','Pseudolite position','location','best');
grid on;


