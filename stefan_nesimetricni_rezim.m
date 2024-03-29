% Komande u ovoj liniji brisu postojece promenljive iz radne memorije
% Matlab-a, zatvaraju sve slike i brisu sadrzaj komandnog prozora
close all; clear; clc

% Sve vrednosti bice izrazene u relativnim jedinicama, pri cemu ce biti
% usvojeno da su nominalni MEDJUFAZNI naponi primara i sekundara jednaki 1
% r.j.

function povratna_vrednost = odnos_transformacije( vektor)
  %% Ulazne velicine:
  % Sprega namotaja (0 - uzemljena zvezda (yn), 1 - neuzemljena zvezda (y), 2 - trougao (d))
  sprega_prim = vektor(1); % sprega primara
  sprega_sek = vektor(2); % sprega sekundara
  % Nominalni FAZNI naponi primara i sekundara (zavise od sprege):
  if sprega_prim == 0 || sprega_prim == 1
  U1fna = 1/sqrt(3);
  else
  U1fna = 1;
  end
  if sprega_sek == 0 || sprega_sek == 1
  U2fna = 1/sqrt(3);
  else
  U2fna = 1;
  end
   povratna_vrednost = [ U1fna; U2fna; U1fna/U2fna]; % Odnos transformacije transformatora
endfunction

%Moguce kombinacije Y= neuzemljena zvezda Yn= uzemljena zvezda Delta=trougao
%Prva kombinacija Yn-Yn
%Druga kombinacija Yn-y
%Treca kombinacija Yn-Delta
%Cetvrta kombinacija y-y
%Peta kombinacija y-yn
%Sesta kombinacija y-Delta
%Sedma kombinacija Delta - Yn
%Osma kombinacija Delta - Y
%Deveta kombinacija Delta - Delta

nazivi_sprega = [ "YnYn"; "Yn-Y"; "YnDe"; "Y-Yn"; "Y--Y"; "Y-De"; "DeYn"; "De-Y"; "DeDe";]
varijante_sprega = [0,0 ;0,1;0,2;1,0;1,1;1,2;2,0;2,1;2,2]

broj_redova = rows(varijante_sprega)
brojac=broj_redova


while (brojac > 0)
	disp("naziv sprege = ")
	disp(nazivi_sprega(brojac,1:4))
	povratni_vektor = ( odnos_transformacije (varijante_sprega(brojac,1:2)) );
	sprega_prim = varijante_sprega(brojac,1)
	sprega_sek = varijante_sprega(brojac,2)
	U1fn = povratni_vektor(1)
	U2fn = povratni_vektor(2)
	n = povratni_vektor(3) % Odnos transformacije transformatora
  
	 
	% Impedansa kratkog spoja:
	Zk = 0.02+1j*0.06 % ukupna impedansa kratkog spoja
	
	%% Fazni naponi napajanja primara U ODNOSU NA ZEMLJU:
	a = exp(1j*2*pi/3) % konstanta a = e^(j*2*pi/3)
	Ua1 = U1fn
	Ub1 = Ua1*a^2
	Uc1 = Ua1*a
	% Direktna i inverzna komponenta napona napajanja:
	Ud1 = 1/3*(Ua1+a*Ub1+a^2*Uc1)
	Ui1 = 1/3*(Ua1+a^2*Ub1+a*Uc1)
	% Nulta komponenta zavisi od sprege:
	if sprega_prim == 0
	    U01 = 1/3*(Ua1+Ub1+Uc1)
	elseif sprega_prim == 2
	    U01 = 0
	end
	
	%% Spoj dve faze preko impedanse:
	Rp = 5; % otpornost povezana izmedju faza b i c sekundara (r.j.)
	% Jednacine fizicke ociglednosti na krajevima sekundara:
	% Ub2 - Uc2 = Rp * Ib2
	% Ib2 + Ic2 = 0
	% Ia2 = 0
	% Jednacine fizicke ociglednosti u domenu simetricnih komponenti, pri cemu je
	% a = e^(j*2*pi/3):
	% (a^2*Ud2+a*Ui2+U02)-(a*Ud2+a^2*Ui2+U02) = Rp*(a^2*Id2+a*Ii2+I02)
	% (a^2*Id2+a*Ii2+I02)+(a*Id2+a^2*Ii2+I02) = 0
	% Id2+Ii2+I02 = 0;
	% Ovim jednacinama dodaju se opste naponske jednacine za direktan, inverzan
	% i nulti sistem:
	% Ud1 - Zk*Id2 = Ud2
	% Ui1 - Zk*Ii2 = Ui2
	% Jednacina za nulti sistem zavisi od vrste sprege primara i sekundara;
	% pogledati u materijalima; u ovom slucaju nulta komponenta struje i napona
	% ne postoji, tako da se jednacina za nulti sistem moze izostaviti, ili se
	% moze napisati:
	% U01 - Zk*I02 = U02
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Sada se ima kompletan sistem jednacina za ovaj kvar u di0 sistemu:
	% (1) (a^2*Ud2+a*Ui2+U02)-(a*Ud2+a^2*Ui2+U02) = Rp*(a^2*Id2+a*Ii2+I02)
	% (2) (a^2*Id2+a*Ii2+I02)+(a*Id2+a^2*Ii2+I02) = 0
	% (3) Id2+Ii2+I02 = 0;
	% (4) Ud1 - Zk*Id2 = Ud2
	% (5) Ui1 - Zk*Ii2 = Ui2
	% (6) U01 - Zk*I02 = U02
	% *** 6 jednacina, 6 nepoznatih (Ud2,Ui2,U02,Id2,Ii2,I02) ***
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Resavanje sistema jednacina pomocu funkcije fsolve
	% x(1) = Ud2
	% x(2) = Ui2
	% x(3) = U02
	% x(4) = Id2
	% x(5) = Ii2
	% x(6) = I02
	% Jednacine se pisu svaka u posebnom redu, u formi f(x) = 0!!!
	% NAPOMENA: Jednacine (1)-(3) zavise od vrste kvara; jednacina (6) zavisi
	% od tipa sprege transformatora!!!
	x0 = [1 1 1 1 1 1]; % vektor pocetnih vrednosti promenljivih
	
	x = fsolve(@(x) [(a^2*x(1)+a*x(2)+x(3))-(a*x(1)+a^2*x(2)+x(3)) - Rp*(a^2*x(4)+a*x(5)+x(6));
	                 (a^2*x(4)+a*x(5)+x(6))+(a*x(4)+a^2*x(5)+x(6));
	                 x(4)+x(5)+x(6);
	                 Ud1 - Zk*x(4) - x(1);
	                 Ui1 - Zk*x(5) - x(2);
	                 U01 - Zk*x(6) - x(3)], x0);
	
	disp ("Spoj dve faze preko impedanse Zk")
	% Velicine u di0 sistemu:
	Ud2 = x(1)
	Ui2 = x(2)
	U02 = x(3)
	Id2 = x(4)
	Ii2 = x(5)
	I02 = x(6)
	
	 disp("Fazni naponi i struje sekundara:")
     Ua2 = Ud2+Ui2+U02
     Ub2 = a^2*Ud2+a*Ui2+U02
	 Uc2 = a*Ud2+a^2*Ui2+U02
	
	 Ia2 = Id2+Ii2+I02
	 Ib2 = a^2*Id2+a*Ii2+I02
	 Ic2 = a*Id2+a^2*Ii2+I02


    %jednofazni kratak spoj K1Z(a)
    %Sta je Zf? Ja sam stavio da bude jednak Zk (impedansi kratkog spoja)
    disp("Jednofazni kratak spoj za spregu")
    disp(nazivi_sprega(brojac,1:4))
    Zf=Rp %aktivni potrosac 
    %Sve jednacine se pisu u obliku f(x)=0 i moraju se dovesti u taj oblik
    %da bi funkcija fsolve prihvatila da radi
    % (1) Ua2-Zf*Ia2=0
    % (2) Ib2=0
    % (3) Ic2=0
    % (4) Ud2+Ui2+U02-Zf*(Id2+Ii2+I02)=0
    % (5) a^2*Id2+a*Ii2+I02=0
    % (6) a*Id2+a^2*Ii2+I02=0
    % *** 6 jednacina, 6 nepoznatih (Ud2, Ui2, U02,Id2,Ii2,I02) ***
    %%%%%%    %%%%%%    %%%%%%    %%%%%%    %%%%%%    %%%%%%    %%%%%%
    % Resavamo jednacine sistema pomocu fsolve, koristimo postojece promenljive
    % jednacina koja zavisi od tipa sprege transformatora je vec pokrivena programom
    % z(1) = Ud2
    % z(2) = Ui2
    % z(3) = U02
    % z(4) = Id2
    % z(5) = Ii2
    % z(6) = I02

    z0 = [1 1 1 1 1 1];
    z = fsolve(@(z) [ Ua2-Zf*Ia2; 
                    Ib2; 
                    Ic2; 
                    (z(1)+z(2)+z(3))-Zf*(z(4)+z(5)+z(6)); 
                    a^2*z(4)+a*z(5)+z(6); 
                    a*z(4)+a^2*z(5)+z(6)], z0);

    Ud2 = z(1)
    Ui2 = z(2)
    U02 = z(3)
    Id2 = z(4)
    Ii2 = z(5)
    I02 = z(6)
    
    disp("trofazno nesimetricno opterecenje za spregu")
    disp(nazivi_sprega(brojac,1:4))
    
    Za=Rp
    Zb=Rp
    Zc=Rp
    
    % (1)   Ua2-Za*Ia2=0
    % (2)   Ub2-Zb*Ib2=0
    % (3)   Uc2-Zc*Ic2=0
    % (4)   Ud2+Ui2+U02-Za*(Id2+Ii2+I02) = 0
    % (5)   a^2*Ud2+a*Ui2+U02-Zb*(a^2*Id2+a*Ii2+I02) = 0
    % (6)   a*Ud2+a^2*Ui2+U02-Zc*(a*Id2+a^2*Ii2+I02) = 0
    % y(1) = Ud2
    % y(2) = Ui2
    % y(3) = U02
    % y(4) = Id2
    % y(5) = Ii2
    % y(6) = I02


    y0 = [1 1 1 1 1 1];
    y = fsolve(@(y) [ Ua2-Za*Ia2; 
                    Ub2-Zb*Ib2; 
                    Uc2-Zc*Ic2; 
                    y(1)+y(2)+y(3)-Za*(y(4)+y(5)+y(6)); 
                    a^2*y(1)+a*y(2)+y(3)-Zb*(a^2*y(4)+a*y(5)+y(6)); 
                    a*y(1)+a^2*y(2)+y(3)-Zc*(a*y(4)+a^2*y(5)+y(6))], y0);
                    
    Ud2 = y(1)
    Ui2 = y(2)
    U02 = y(3)
    Id2 = y(4)
    Ii2 = y(5)
    I02 = y(6)
    
    
    
    brojac=brojac-1
endwhile

