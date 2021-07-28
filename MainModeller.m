% Code for modelling the football bets
% Codes developed by Arman Hassanniakalager
% Last modified 10 Sep. 2018 13:28 BST.
clear;
clc;
% Add the codes for Conditional Logit
addpath([cd,'\clogit']);
% Suppress warning notifications within the loops
warning('off','all');
rng(0);
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
    %% Logit specification for 1X2
    %% IS specification
%   Y is an N x 1 vector of integers 1 through J indicating which
%   alternative was chosen.     
    Y_IS1X2=tblIS.FTR;
%   X is an N x K1 matrix of individual-specific covariates.
    indpredictors1X2=[tblIS.PtH5,tblIS.PtA5,tblIS.GsH5,tblIS.GsA5,tblIS.GcH5,tblIS.GcA5,tblIS.IPAHH,tblIS.IPAHA,tblIS.AHh+AHcte];
    X_IS1X2=[indpredictors1X2,tblIS.IP1,tblIS.IPX,tblIS.IP2];
    %% OOS specification
    Y_OOS1X2=tblOOS.FTR;
    indpredictors_OOS1X2=[tblOOS.PtH5,tblOOS.PtA5,tblOOS.GsH5,tblOOS.GsA5,tblOOS.GcH5,tblOOS.GcA5,tblOOS.IPAHH,tblOOS.IPAHA,tblOOS.AHh+AHcte];
    %% MATLAB built-in fcn
    B1X2 = mnrfit(X_IS1X2,Y_IS1X2,'Model','nominal','Interactions','on');
    pihat1X2 = mnrval(B1X2,X_IS1X2);
    [~,Predict1X2]=max(pihat1X2,[],2);
    %% CLogit performance
    ISaccuracy1X2(i)=sum(Predict1X2==Y_IS1X2)/numel(Y_IS1X2);
    X_OOS1X2=[indpredictors_OOS1X2,tblOOS.IP1,tblOOS.IPX,tblOOS.IP2];
    pihat_OOS1X2 = mnrval(B1X2,X_OOS1X2);
    [~,Predict_OOS1X2]=max(pihat_OOS1X2,[],2);
    OOSaccuracy1X2(i)=sum(Predict_OOS1X2==Y_OOS1X2)/numel(Y_OOS1X2);
    tblnew1=payoffestimator3(Predict_OOS1X2,tblOOS,1);
    tblOOS.Properties.VariableNames(12:14)={'BbAvH','BbAvD','BbAvA'};
    %% Logit specification for Over/Under 2.5 goals
    %% IS specification
    Y_ISOvUn=tblIS.OvUn;
    indpredictorsOvUn=[tblIS.PtH5,tblIS.PtA5,tblIS.GsH5,tblIS.GsA5,tblIS.GcH5,tblIS.GcA5,tblIS.IPAHH,tblIS.IPAHA,tblIS.AHh+AHcte];
    X_ISOvUn=[indpredictorsOvUn,tblIS.IPOv,tblIS.IPUn];
    %% OOS specification
    Y_OOSOvUn=tblOOS.OvUn;
    indpredictors_OOSOvUn=[tblOOS.PtH5,tblOOS.PtA5,tblOOS.GsH5,tblOOS.GsA5,tblOOS.GcH5,tblOOS.GcA5,tblOOS.IPAHH,tblOOS.IPAHA,tblOOS.AHh+AHcte];
    B_OvUn = mnrfit(X_ISOvUn,Y_ISOvUn,'Model','nominal','Interactions','on');
    pihatOvUn = mnrval(B_OvUn,X_ISOvUn);
%     B_OvUn = glmfit(X_ISOvUn,Y_ISOvUn-1,'binomial');
%     yhat = glmval(B_OvUn,X_ISOvUn,'logit');   
    [~,PredictOvUn]=max(pihatOvUn,[],2);
    ISaccuracyOvUn(i)=sum(PredictOvUn==Y_ISOvUn)/numel(Y_ISOvUn);
    X_OOSOvUn=[indpredictors_OOSOvUn,tblOOS.IPOv,tblOOS.IPUn];
    pihat_OOSOvUn = mnrval(B_OvUn,X_OOSOvUn);
    [~,Predict_OOSOvUn]=max(pihat_OOSOvUn,[],2);
    OOSaccuracyOvUn(i)=sum(Predict_OOSOvUn==Y_OOSOvUn)/numel(Y_OOSOvUn);
    tblnew2=payoffestimator3(Predict_OOSOvUn,tblOOS,2);
    tblOOS.Properties.VariableNames(15:16)={'BbAvOver','BbAvUnder'};
    %% Logit specification for Asian Handicap
    %% IS specification
    Y_ISAH=tblIS.AH;
    indpredictorsAH=[tblIS.PtH5,tblIS.PtA5,tblIS.GsH5,tblIS.GsA5,tblIS.GcH5,tblIS.GcA5,tblIS.IPAHH,tblIS.IPAHA,tblIS.AHh+AHcte];
    X_ISAH=indpredictorsAH;
    %% OOS specification
    Y_OOSAH=tblOOS.AH;
    indpredictors_OOSAH=[tblOOS.PtH5,tblOOS.PtA5,tblOOS.GsH5,tblOOS.GsA5,tblOOS.GcH5,tblOOS.GcA5,tblOOS.IPAHH,tblOOS.IPAHA,tblOOS.AHh+AHcte];
    B_AH = mnrfit(X_ISAH,Y_ISAH,'Model','nominal','Interactions','on');
    pihatAH = mnrval(B_AH,X_ISAH);
%     B_AH = glmfit(X_ISAH,Y_ISAH-1,'binomial');
%     yhat = glmval(B_AH,X_ISAH,'logit');   
    [~,PredictAH]=max(pihatAH,[],2);
    ISaccuracyAH(i)=sum(PredictAH==Y_ISAH)/numel(Y_ISAH);
    X_OOSAH=indpredictors_OOSAH;
    pihat_OOSAH = mnrval(B_AH,X_OOSAH);
    [~,Predict_OOSAH]=max(pihat_OOSAH,[],2);
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
    indpredictorsCS=[tblIS.PtH5,tblIS.PtA5,tblIS.GsH5,tblIS.GsA5,tblIS.GcH5,tblIS.GcA5,tblIS.IP1,tblIS.IPX,tblIS.IP2,tblIS.IPOv,tblIS.IPUn,tblIS.IPAHH,tblIS.IPAHA,tblIS.AHh+AHcte];
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
    
%     %% Matlab built-in
%      B_CS = mnrfit(X_ISCS,Y_ISCS,'Model','nominal','Interactions','on');
%      pihatCS = mnrval(B_CS,X_ISCS); 
    % Clogit code
    % IS specification
    columns=unique(Y_ISCS);
    J=numel(columns);
    cte=ones(size(tblIS,1),1);
    X_IS=[cte,indpredictorsCS];
    Z_IS=nan(size(tblIS,1),1,J);
    firstSCoddcolumn=find(contains(tblOOS.Properties.VariableNames,'IP0_0'));
    Z_IS(:,1,:)=tblIS{:,firstSCoddcolumn+columns-1};
    options=optimset('Algorithm','trust-region','Disp','off','LargeScale','on','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-8,'Tolfun',1e-8,'GradObj','on','DerivativeCheck','off','FinDiffType','central','UseParallel',true);
    %options = optimoptions('fminunc','Algorithm','trust-region');
    rng(0);
    b=rand(size(X_IS,2),J);
    bz=2;
    bAns = b(:)-repmat(b(:,J),J,1);
    bAns = cat(1,bAns(1:(J-1)*size(X_IS,2)),bz);
    startval = bAns;
    bEst = fminunc('clogit',startval,options,[],Y_ISCS,X_IS,Z_IS);
    Probs = pclogit(bEst,Y_ISCS,X_IS,Z_IS);
    [~,PredictCS]=max(Probs,[],2);
    ISaccuracyCS(i)=sum(PredictCS==Y_ISCS)/numel(Y_ISCS);
    % OOS specification
    indpredictorsCSOOS=[tblOOS.PtH5,tblOOS.PtA5,tblOOS.GsH5,tblOOS.GsA5,tblOOS.GcH5,tblOOS.GcA5,tblOOS.IP1,tblOOS.IPX,tblOOS.IP2,tblOOS.IPOv,tblOOS.IPUn,tblOOS.IPAHH,tblOOS.IPAHA,tblOOS.BbAHh+AHcte];
    cte_OOS=ones(size(tblOOS,1),1);
    X_OOSCS=[cte_OOS,indpredictorsCSOOS];
    Z_OOSCS=nan(size(tblOOS,1),1,J);
    Z_OOSCS(:,1,:)=tblOOS{:,firstSCoddcolumn+columns-1};
    randYOOS=(1:J)';
    randYOOS=repmat(randYOOS,floor(size(tblOOS,1)/J),1);
    randYOOS=[randYOOS;(1:(size(tblOOS,1)-size(randYOOS,1)))'];
    Probs_OOSCS = pclogit(bEst,randYOOS,X_OOSCS,Z_OOSCS);
    [~,Predict_OOSCS]=max(Probs_OOSCS,[],2);
    OOSaccuracyCS(i)=sum(Predict_OOSCS==Y_OOSCS)/numel(Y_OOSCS);
    tblnew3=payoffestimator3(Predict_OOSCS,tblOOS,3);
    %tblnew=[tblOOS,tblnew1(:,end-1:end),tblnew1CF(:,end-1:end),tblnew2(:,end-1:end),tblnew2CF(:,end-1:end),tblnew3(:,end-1:end)];
    tblnew=[tblOOS,tblnew1(:,end-1:end),... 1X2
        tblnew2(:,end-1:end),... OVER/UNDER
        tblnew4(:,end-1:end),... ASIAN HANDICAP
        tblnew3(:,end-1:end)... CS
        ]; 
    %% Gambling game
    [betprofit1X2,hl_1X2,capser1X2]=gamblerfun(tblnew.Result_Bet_Reward,InvestSize/100,CapitalSize);
    [betprofitOvUn,hl_OvUn,capserOvUn]=gamblerfun(tblnew.OvUn_Bet_Reward,InvestSize/100,CapitalSize);
    [betprofitAH,hl_AH,capserAH]=gamblerfun(tblnew.AH_Bet_Reward,InvestSize/100,CapitalSize);
    [betprofitCS,hl_CS,capserCS]=gamblerfun(tblnew.CS_Bet_Reward,InvestSize/100,CapitalSize);
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
    rectbl{i,'OOS_HalfLife1X2'}=hl_1X2;
    rectbl{i,'OOS_Gamble1X2'}=betprofit1X2;
    rectbl{i,'IS_AccuracyOvUn'}=ISaccuracyOvUn(i);
    rectbl{i,'OOS_AccuracyOvUn'}=OOSaccuracyOvUn(i);
    rectbl{i,'OOS_ProfitOvUn'}=sum(tblnew.OvUn_Bet_Reward)/size(tblOOS,1);
    rectbl{i,'OOS_HalfLifeOvUn'}=hl_OvUn;
    rectbl{i,'OOS_GambleOvUn'}=betprofitOvUn;
    rectbl{i,'IS_AccuracyAH'}=ISaccuracyAH(i);
    rectbl{i,'OOS_AccuracyAH'}=OOSaccuracyAH(i);
    rectbl{i,'OOS_ProfitAH'}=sum(tblnew.AH_Bet_Reward)/size(tblOOS,1);
    rectbl{i,'OOS_HalfLifeAH'}=hl_AH;
    rectbl{i,'OOS_GambleAH'}=betprofitAH;
    rectbl{i,'IS_AccuracyCS'}=ISaccuracyCS(i);
    rectbl{i,'OOS_AccuracyCS'}=OOSaccuracyCS(i);
    rectbl{i,'OOS_ProfitCS'}=sum(tblnew.CS_Bet_Reward)/size(tblOOS,1);  
    rectbl{i,'OOS_HalfLifeCS'}=hl_CS;
    rectbl{i,'OOS_GambleCS'}=betprofitCS;
    save(['E0Modelling_',num2str(ISrng(i,1)),'_',num2str(ISrng(i,2))])
    writetable(tblnew,['Predicted_Season_',num2str(ISrng(i,1)),'_',num2str(ISrng(i,2)),'.xlsx'])
end
close;
writetable(rectbl,'Logit_Results.xlsx');