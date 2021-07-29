% Typ=1 >>> 1X2
% Typ=2 >>> Over/Under
% Typ=3 >>> Scorelines
% Typ=4 >>> Asian Handicap
% Script by Arman Hassanniakalager for the football paper with Phil
% Based on a code 17 JUL 2017 12:09 BST.
% Last modified 07 Feb. 2018 18:45 GMT 
function tblnew=payoffestimator4(output1,oddstable,typ)
if isempty(typ)
    typ=1;
end    
tblnew=oddstable;

%% Betting on 1X2
if typ==1
    entrycostres=1;
    pred_1X2=output1;
    tblnew=[tblnew,table(pred_1X2)];
    HCIres=and(tblnew.FTR==1,tblnew.pred_1X2==1); % home win correct indices
    ACIres=and(tblnew.FTR==3,tblnew.pred_1X2==3); % away win correct indices
    DCIres=and(tblnew.FTR==2,tblnew.pred_1X2==2); %draw correct indices
    PpG1x2=HCIres.*tblnew.BbAvH+ACIres.*tblnew.BbAvA+DCIres.*tblnew.BbAvD-entrycostres;
    tblnew{:,end+1}=PpG1x2;
    tblnew.Properties.VariableNames{end}='Result_Bet_Reward';
    
    %% Betting on Over/Under
elseif typ==2
    entrycostOvUn=1;
    pred_OvUn=output1;
    tblnew=[tblnew,table(pred_OvUn)];
    OvCI=and(tblnew.OvUn==1,tblnew.pred_OvUn==1); % Correct >2.5 goals
    UnCI=and(tblnew.OvUn==2,tblnew.pred_OvUn==2); % Correct <2.5 goals
    PpGOvUn=OvCI.*tblnew.BbAvOver... BbAv_2_5 means BbAv>2.5
        +UnCI.*tblnew.BbAvUnder... BbAv_2_5_1 means BbAv<2.5
        -entrycostOvUn;
    tblnew{:,end+1}=PpGOvUn;
    tblnew.Properties.VariableNames{end}='OvUn_Bet_Reward';
    
    %% Betting on Scorelines
elseif typ==3
    entrycostCS=1;
    pred_SC=output1;
    tblnew=[tblnew,table(pred_SC)];
    CSret=nan(size(tblnew,1),1);
    for u=1:size(tblnew,1)
        CSret(u)=(tblnew.pred_SC(u)==tblnew.SC(u))*tblnew{u,19+tblnew.pred_SC(u)};
    end
    PpGCS=CSret-entrycostCS;
    tblnew{:,end+1}=PpGCS;
    tblnew.Properties.VariableNames{end}='CS_Bet_Reward';
    %% Betting on Asian Handicap
elseif typ==4
    entrycostAH=1;
    pred_AH=output1;
    tblnew=[tblnew(:,1:end-2),table(pred_AH)];
    AHdiff=(tblnew.FTHG-tblnew.FTAG)+tblnew.BbAHh;
    HFW=and(tblnew.pred_AH==1,AHdiff>=.5); % Home team full win
    HHW=and(tblnew.pred_AH==1,AHdiff==.25); % Home team half win
    HSR=and(tblnew.pred_AH==1,AHdiff==0); % Home team stake refund
    HHL=and(tblnew.pred_AH==1,AHdiff==-.25); % Home team half lose
    HFL=and(tblnew.pred_AH==1,AHdiff<=-.5); % Home team full lose
    AFW=and(tblnew.pred_AH==2,AHdiff<=-.5); % Away team full win
    AHW=and(tblnew.pred_AH==2,AHdiff==-.25); % Away team half win
    ASR=and(tblnew.pred_AH==2,AHdiff==0); % Away team stake refund
    AHL=and(tblnew.pred_AH==2,AHdiff==.25); % Away team half lose
    AFL=and(tblnew.pred_AH==2,AHdiff>=.5); % Away team full lose
    
    PpGAHH=HFW.*tblnew.BbAvAHH+HHW.*(1+tblnew.BbAvAHH)/2+HSR.*entrycostAH+...
        HHL.*entrycostAH*.5+HFL.*0;
    PpGAHA=AFW.*tblnew.BbAvAHA+AHW.*(1+tblnew.BbAvAHA)/2+ASR.*entrycostAH+...
        AHL.*entrycostAH*.5+AFL.*0;
    PpGAH=PpGAHH+PpGAHA-entrycostAH;
    tblnew{:,end+1}=PpGAH;
    tblnew.Properties.VariableNames{end}='AH_Bet_Reward';
end
end