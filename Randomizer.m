% Code for modelling the football bets - Randomizer : choosing one of bet
% outcomes randomly (by chance)
% Codes developed by Arman Hassanniakalager
% Last modified 10 Sep. 2018 14:38 BST.
clear;
clc;
rng(100000);
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
    Predict1X2=floor(1+3*rand(size(tblIS,1),1));
    Y_IS1X2=tblIS.FTR;
    ISaccuracy1X2(i)=sum(Predict1X2==Y_IS1X2)/numel(Y_IS1X2);
    Y_OOS1X2=tblOOS.FTR;
    Predict_OOS1X2=floor(1+3*rand(size(tblOOS,1),1));
    OOSaccuracy1X2(i)=sum(Predict_OOS1X2==Y_OOS1X2)/numel(Y_OOS1X2);
    tblnew1=payoffestimator3(Predict_OOS1X2,tblOOS,1);
    tblOOS.Properties.VariableNames(12:14)={'BbAvH','BbAvD','BbAvA'};
    %% Over/Under 2.5 goals
    %% IS specification
    Y_ISOvUn=tblIS.OvUn;
    %% OOS specification
    Y_OOSOvUn=tblOOS.OvUn;
    PredictOvUn=floor(1+2*rand(size(tblIS,1),1));
    ISaccuracyOvUn(i)=sum(PredictOvUn==Y_ISOvUn)/numel(Y_ISOvUn);
    Predict_OOSOvUn=floor(1+2*rand(size(tblOOS,1),1));
    OOSaccuracyOvUn(i)=sum(Predict_OOSOvUn==Y_OOSOvUn)/numel(Y_OOSOvUn);
    tblnew2=payoffestimator3(Predict_OOSOvUn,tblOOS,2);
    tblOOS.Properties.VariableNames(15:16)={'BbAvOver','BbAvUnder'};    
    %% Asian Handicap
    %% IS specification
    Y_ISAH=tblIS.OvUn;
    %% OOS specification
    Y_OOSAH=tblOOS.AH;
    PredictAH=floor(1+2*rand(size(tblIS,1),1));
    ISaccuracyAH(i)=sum(PredictAH==Y_ISAH)/numel(Y_ISAH);
    Predict_OOSAH=floor(1+2*rand(size(tblOOS,1),1));
    OOSaccuracyAH(i)=sum(Predict_OOSAH==Y_OOSAH)/numel(Y_OOSAH);
    tblOOS.Properties.VariableNames(17)={'BbAHh'};
    tblOOS.Properties.VariableNames(18:19)={'BbAvAHH','BbAvAHA'};
    tblnew4=payoffestimator4(Predict_OOSAH,tblOOS,4);    
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
    PredictCS=floor(1+25*rand(size(tblIS,1),1));
    ISaccuracyCS(i)=sum(PredictCS==Y_ISCS)/numel(Y_ISCS);
    % OOS specification
    Predict_OOSCS=floor(1+25*rand(size(tblOOS,1),1));
    OOSaccuracyCS(i)=sum(Predict_OOSCS==Y_OOSCS)/numel(Y_OOSCS);
    tblnew3=payoffestimator3(Predict_OOSCS,tblOOS,3);
    %tblnew=[tblOOS,tblnew1(:,end-1:end),tblnew1CF(:,end-1:end),tblnew2(:,end-1:end),tblnew2CF(:,end-1:end),tblnew3(:,end-1:end)];
    tblnew=[tblOOS,tblnew1(:,end-1:end),... 1X2
        tblnew2(:,end-1:end),... OVER/UNDER
        tblnew4(:,end-1:end),... ASIAN HANDICAP
        tblnew3(:,end-1:end)]; 
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
    save(['E0Modelling_',num2str(ISrng(i,1)),'_',num2str(ISrng(i,2)),'RND'])
    writetable(tblnew,['Predicted_Season_',num2str(ISrng(i,1)),'_',num2str(ISrng(i,2)),'RND.xlsx'])
end
close;
writetable(rectbl,'Randomizer_Results.xlsx');
