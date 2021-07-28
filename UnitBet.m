% Code for modelling the football bets - Unit bet : equal wager on each
% potential bet outcome
% Codes developed by Arman Hassanniakalager
% Last modified 10 Sep. 2018 14:30 BST.
clear;
clc;
%% IS-OOS specification
% Insample period
ISper=3; % years
OOSper=1;
yrrng=2010:2017-(ISper-1)-OOSper;
ISrng=[yrrng',yrrng'+(ISper-1)];
% Out-of-sample period
OOSrng=[ISrng(:,2)+1,ISrng(:,2)+OOSper];
rectbl=table();
CapitalSize=100;
InvestSize=5; % In %
for i=1:size(ISrng,1)
    disp(['Modelling year ',num2str(ISrng(i,2)),' ...']);
    % IS data
    tblIS=readtable(['England_',num2str(ISrng(i,1)),'_proc.xlsx']);
    for k=ISrng(i,1)+1:ISrng(i,2)
        addtbl=readtable(['England_',num2str(k),'_proc.xlsx']);
        tblIS=[tblIS;addtbl];
    end
    % OOS data
    tblOOS=readtable(['England_',num2str(OOSrng(i,1)),'_proc.xlsx']);
    if OOSper>1
        for m=OOSrng(i,1)+1:OOSrng(i,2)
            addedtbl=readtable(['England_',num2str(m),'_proc.xlsx']);
            tblOOS=[tblOOS;addedtbl];
        end
    end
    tblIS{:,'IPres'}=ones(size(tblIS,1),1)*1e-4;
    tblOOS{:,'IPres'}=ones(size(tblOOS,1),1)*1e-4;
    AHresIS=(tblIS.FTHG-tblIS.FTAG)+tblIS.AHh;
    AHresIS(AHresIS>=0)=1; % Home Win
    AHresIS(AHresIS<0)=2; % Lose
    tblIS.AH=AHresIS;
    AHresOOS=(tblOOS.FTHG-tblOOS.FTAG)+tblOOS.AHh;
    AHresOOS(AHresOOS>=0)=1;
    AHresOOS(AHresOOS<0)=2;
    tblOOS.AH=AHresOOS;
    AHcte=abs(min(tblIS.AHh))+1;
    %% 1X2 Random model
    Y_IS1X2=tblIS.FTR;
    ISaccuracy1X2(i)=1/3;
    Y_OOS1X2=tblOOS.FTR;
    OOSaccuracy1X2(i)=1/3;
    Column_1X2=11+Y_OOS1X2;
    Third_Return=nan(size(tblOOS,1),1);
    for t=1:size(tblOOS,1)
        Third_Return(t)=tblOOS{t,Column_1X2(t)};
    end
    Result_Bet_Reward=1/3*Third_Return-1;
    tblnew1=[tblOOS,table(Result_Bet_Reward)];
    tblOOS.Properties.VariableNames(12:14)={'BbAvH','BbAvD','BbAvA'};
    %% Over/Under 2.5 goals
    %% IS specification
    Y_ISOvUn=tblIS.OvUn;
    %% OOS specification
    Y_OOSOvUn=tblOOS.OvUn;
    ISaccuracyOvUn(i)=1/2;
    OOSaccuracyOvUn(i)=1/2;
    
    Column_OvUn=14+Y_OOSOvUn;
    Second_Return_OvUn=nan(size(tblOOS,1),1);
    for t=1:size(tblOOS,1)
        Second_Return_OvUn(t)=tblOOS{t,Column_OvUn(t)};
    end
    OvUn_Bet_Reward=1/2*Second_Return_OvUn-1;
    
    tblnew2=[tblOOS,table(OvUn_Bet_Reward)];
    tblOOS.Properties.VariableNames(15:16)={'BbAvOver','BbAvUnder'};    
    %% Asian Handicap
    %% IS specification
    Y_ISAH=tblIS.OvUn;
    %% OOS specification
    Y_OOSAH=tblOOS.AH;
    ISaccuracyAH(i)=1/2;
    OOSaccuracyAH(i)=1/2;
    tblOOS.Properties.VariableNames(17)={'BbAHh'};
    
    Column_AH=17+Y_OOSOvUn;
    Second_Return_AH=nan(size(tblOOS,1),1);
    for t=1:size(tblOOS,1)
        Second_Return_AH(t)=tblOOS{t,Column_AH(t)};
    end
    AH_Bet_Reward=1/2*Second_Return_AH-1;
    
    
    tblOOS.Properties.VariableNames(18:19)={'BbAvAHH','BbAvAHA'};
    
    tblnew4=[tblOOS,table(AH_Bet_Reward)];    
    %% Logit specification for Correct Scores
    % Generating categorical outputs for IS
    outcomes={'0:0','0:1','0:2','0:3','0:4','1:0','1:1','1:2','1:3',...
        '1:4','2:0','2:1','2:2','2:3','2:4','3:0','3:1','3:2',...
        '3:3','3:4','4:0','4:1','4:2','4:3'};
    delimiterIS=[];
    delimiterIS(1:size(tblIS,1),1)=':';
    scorelineIS=cellstr([num2str(tblIS.FTHG),delimiterIS,num2str(tblIS.FTAG)]);
    scorelinecatIS=nan(size(tblIS,1),1);
    for f=1:size(tblIS,1)
        if ~isempty(find(strcmp(scorelineIS(f),outcomes), 1))
            scorelinecatIS(f)=find(strcmp(scorelineIS(f),outcomes));
        else
            scorelinecatIS(f)=size(outcomes,2)+1;
        end
    end
    tblIS.SC=scorelinecatIS;
    Y_ISCS=scorelinecatIS;
    %% OOS categorical 
    delimiterOOS=[];
    delimiterOOS(1:size(tblOOS,1),1)=':';
    scorelineOOS=cellstr([num2str(tblOOS.FTHG),delimiterOOS,num2str(tblOOS.FTAG)]);
    scorelinecatOOS=nan(size(tblOOS,1),1);
    for f=1:size(tblOOS,1)
        if ~isempty(find(strcmp(scorelineOOS(f),outcomes), 1))
            scorelinecatOOS(f)=find(strcmp(scorelineOOS(f),outcomes));
        else
            scorelinecatOOS(f)=size(outcomes,2)+1;
        end
    end
    Y_OOSCS=scorelinecatOOS;
    tblOOS.SC=scorelinecatOOS;
    
    
    ISaccuracyCS(i)=mean((1/24*(any(Y_ISCS==1:24,2))));
    % OOS specification
    OOSaccuracyCS(i)=mean((1/24*(any(Y_OOSCS==1:24,2))));
    
    Column_SC=19+Y_OOSCS;
    Return_CS=nan(size(tblOOS,1),1);
    for t=1:size(tblOOS,1)
        Return_CS(t)=(1-(Column_SC(t)==25))*tblOOS{t,Column_SC(t)};
    end
    CS_Bet_Reward=1/24*Return_CS-1;
    
    tblnew3=[tblOOS,table(CS_Bet_Reward)];    
    %tblnew=[tblOOS,tblnew1(:,end-1:end),tblnew1CF(:,end-1:end),tblnew2(:,end-1:end),tblnew2CF(:,end-1:end),tblnew3(:,end-1:end)];
    tblnew=[tblOOS,tblnew1(:,end),... 1X2
        tblnew2(:,end),... OVER/UNDER
        tblnew4(:,end),... ASIAN HANDICAP
        tblnew3(:,end)]; 
    %% Gambling game
    [betprofit1X2,~,capser1X2]=gamblerfun(tblnew.Result_Bet_Reward,InvestSize/100,CapitalSize);
    [betprofitOvUn,~,capserOvUn]=gamblerfun(tblnew.OvUn_Bet_Reward,InvestSize/100,CapitalSize);
    [betprofitAH,~,capserAH]=gamblerfun(tblnew.AH_Bet_Reward,InvestSize/100,CapitalSize);
    [betprofitCS,~,capserCS]=gamblerfun(tblnew.CS_Bet_Reward,InvestSize/100,CapitalSize);
    %% record results
    rectbl{i,'IS_Start'}=ISrng(i,1);
    rectbl{i,'IS_Finish'}=ISrng(i,2);
    rectbl{i,'IS_Period'}=ISrng(i,2)-ISrng(i,1)+1;
    rectbl{i,'OOS_Start'}=OOSrng(i,1);
    rectbl{i,'OOS_Finish'}=OOSrng(i,2);
    rectbl{i,'OOS_Period'}=OOSrng(i,2)-OOSrng(i,1)+1;
    rectbl{i,'GamesCount'}=size(tblOOS,1);
    rectbl{i,'IS_Accuracy1X2'}=ISaccuracy1X2(i);
    rectbl{i,'OOS_Accuracy1X2'}=OOSaccuracy1X2(i);
    rectbl{i,'OOS_Profit1X2'}=sum(tblnew.Result_Bet_Reward)/size(tblOOS,1);
    rectbl{i,'OOS_Gamble1X2'}=betprofit1X2;
    rectbl{i,'IS_AccuracyOvUn'}=ISaccuracyOvUn(i);
    rectbl{i,'OOS_AccuracyOvUn'}=OOSaccuracyOvUn(i);
    rectbl{i,'OOS_ProfitOvUn'}=sum(tblnew.OvUn_Bet_Reward)/size(tblOOS,1);
    rectbl{i,'OOS_GambleOvUn'}=betprofitOvUn;
    rectbl{i,'IS_AccuracyAH'}=ISaccuracyAH(i);
    rectbl{i,'OOS_AccuracyAH'}=OOSaccuracyAH(i);
    rectbl{i,'OOS_ProfitAH'}=sum(tblnew.AH_Bet_Reward)/size(tblOOS,1);
    rectbl{i,'OOS_GambleAH'}=betprofitAH;
    rectbl{i,'IS_AccuracyCS'}=ISaccuracyCS(i);
    rectbl{i,'OOS_AccuracyCS'}=OOSaccuracyCS(i);
    rectbl{i,'OOS_ProfitCS'}=sum(tblnew.CS_Bet_Reward)/size(tblOOS,1);  
    rectbl{i,'OOS_GambleCS'}=betprofitCS;
    save(['E0Modelling_',num2str(ISrng(i,1)),'_',num2str(ISrng(i,2)),'UB'])
    writetable(tblnew,['Predicted_Season_',num2str(ISrng(i,1)),'_',num2str(ISrng(i,2)),'UB.xlsx'])
end
close;
writetable(rectbl,'Unit_Bet(UB)_Results.xlsx');