%% Intro
% Football pre-processing script
% Codes developed by Arman Hassanniakalager
% Last modified 10 Sep. 2018 13:10 BST
clear;
clc;
tic;
tickername='Dataset1New.xlsx';
tblMain=readtable(tickername,'Sheet','Main'); % Table importing
yearser=unique(tblMain.Season);
start=yearser(1);
finish=yearser(end);
for i=start:finish
    tbl1=(tblMain(tblMain.Season==i,:));
    OvUn=(tbl1.FTHG + tbl1.FTAG > 2.5)*1+... % Over 2.5 goals (1)
        (tbl1.FTHG + tbl1.FTAG < 2.5)*2; % Under 2.5 goals (2)
    %% Declaring necessary variables
    % Points Pt
    PtH=zeros(size(tbl1,1),1);PtA=PtH;PtHH=PtH;PtHA=PtH;
    PtAH=PtH;PtAA=PtH;PtH5=PtH;PtA5=PtH;
    
    % Goals scored Gs
    GsH=zeros(size(tbl1,1),1);GsA=GsH;GsHH=GsH;GsHA=GsH;GsAH=GsH;GsAA=GsH;
    GsH5=GsH;GsA5=GsH;
    
    % Goals conceded Gc
    GcH=zeros(size(tbl1,1),1);GcA=GcH;GcHH=GcH;GcHA=GcH;GcAH=GcH;GcAA=GcH;
    GcH5=GcH;GcA5=GcH;
    
    % Previous game count
    PGH=zeros(size(tbl1,1),1);PGA=PGH;
    %%
    for j=2:size(tbl1,1)
        % Home team previous games
        prevHind=find(contains(tbl1.Match(1:j-1),tbl1.HomeTeam(j)));
        % Home team previous games home
        prevHHind=find(strcmp(tbl1.HomeTeam(1:j-1),tbl1.HomeTeam(j)));
        if ~isempty(prevHHind)
            PtHH(j)=sum(.5*tbl1.FTR(prevHHind).^2-3.5.*tbl1.FTR(prevHHind)+6);
            GsHH(j)=sum(tbl1.FTHG(prevHHind));
            GcHH(j)=sum(tbl1.FTAG(prevHHind));
        end
        % Home team previous games away
        prevHAind=find(strcmp(tbl1.AwayTeam(1:j-1),tbl1.HomeTeam(j)));
        if ~isempty(prevHAind)
            PtHA(j)=sum(.5*tbl1.FTR(prevHAind).^2-.5.*tbl1.FTR(prevHAind));
            GsHA(j)=sum(tbl1.FTAG(prevHAind));
            GcHA(j)=sum(tbl1.FTHG(prevHAind));
        end
        % Away team previous games
        prevAind=find(contains(tbl1.Match(1:j-1),tbl1.AwayTeam(j)));
        % Away team previous games away
        prevAAind=find(strcmp(tbl1.AwayTeam(1:j-1),tbl1.AwayTeam(j)));
        if ~isempty(prevAAind)
            PtAA(j)=sum(.5*tbl1.FTR(prevAAind).^2-.5.*tbl1.FTR(prevAAind));
            GsAA(j)=sum(tbl1.FTAG(prevAAind));
            GcAA(j)=sum(tbl1.FTHG(prevAAind));
        end
        % Away team previous games home
        prevAHind=find(strcmp(tbl1.HomeTeam(1:j-1),tbl1.AwayTeam(j)));
        if ~isempty(prevAHind)
            PtAH(j)=sum(.5*tbl1.FTR(prevAHind).^2-3.5.*tbl1.FTR(prevAHind)+6);
            GsAH(j)=sum(tbl1.FTHG(prevAHind));    
            GcAH(j)=sum(tbl1.FTAG(prevAHind));    
        end
        % Total points for Home/Away before game
        PtH(j)=PtHH(j)+PtHA(j);
        PtA(j)=PtAH(j)+PtAA(j);
        PtT=[PtH,PtA];
        % Total Goals scored for Home/Away before game
        GsH(j)=GsHH(j)+GsHA(j);
        GsA(j)=GsAH(j)+GsAA(j);
        % Total Goals conceded for Home/Away before game
        GcH(j)=GcHH(j)+GcHA(j);
        GcA(j)=GcAH(j)+GcAA(j);
        % Number of previous games 
        PGH(j)=numel(prevHind);
        PGA(j)=numel(prevAind);
        % Each team needs to have at least 3 H & 3 A games
        if min(PGH(j),PGA(j))>=5
            % Past 5 games of H team
            %Points
            PtH5(j)=PtH(j)-(PtH(prevHind(end-4))*(strcmp(tbl1.HomeTeam(prevHind(end-4)),tbl1.HomeTeam(j)))+PtA(prevHind(end-4))*(strcmp(tbl1.AwayTeam(prevHind(end-4)),tbl1.HomeTeam(j))));
            % Goals scored
            GsH5(j)=GsH(j)-(GsH(prevHind(end-4))*(strcmp(tbl1.HomeTeam(prevHind(end-4)),tbl1.HomeTeam(j)))+GsA(prevHind(end-4))*(strcmp(tbl1.AwayTeam(prevHind(end-4)),tbl1.HomeTeam(j))));
            % Goals conceded
            GcH5(j)=GcH(j)-(GcH(prevHind(end-4))*(strcmp(tbl1.HomeTeam(prevHind(end-4)),tbl1.HomeTeam(j)))+GcA(prevHind(end-4))*(strcmp(tbl1.AwayTeam(prevHind(end-4)),tbl1.HomeTeam(j))));
            
            % Past 5 games of A team
            %Points
            PtA5(j)=PtA(j)-(PtA(prevAind(end-4))*(strcmp(tbl1.AwayTeam(prevAind(end-4)),tbl1.AwayTeam(j)))+PtH(prevAind(end-4))*(strcmp(tbl1.HomeTeam(prevAind(end-4)),tbl1.AwayTeam(j))));
            % Goals scored
            GsA5(j)=GsA(j)-(GsA(prevAind(end-4))*(strcmp(tbl1.AwayTeam(prevAind(end-4)),tbl1.AwayTeam(j)))+GsH(prevAind(end-4))*(strcmp(tbl1.HomeTeam(prevAind(end-4)),tbl1.AwayTeam(j))));
            % Goals conceded
            GcA5(j)=GcA(j)-(GcA(prevAind(end-4))*(strcmp(tbl1.AwayTeam(prevAind(end-4)),tbl1.AwayTeam(j)))+GcH(prevAind(end-4))*(strcmp(tbl1.HomeTeam(prevAind(end-4)),tbl1.AwayTeam(j))));
            
        end
        
    end
    % Table of calculated variables
    tbl2=table(PtH,PtA,PtH5,PtA5... Points
        ,GsH,GsA,GsH5,GsA5...Goal scored
        ,GcH,GcA,GcH5,GcA5...Goal conceded
        ,PGH,PGA,OvUn);
    %% Normalized Implied Probablities for simple odds
    IP1=(1./tbl1.AvgH)./(1./tbl1.AvgH+1./tbl1.AvgD+1./tbl1.AvgA);
    IPX=(1./tbl1.AvgD)./(1./tbl1.AvgH+1./tbl1.AvgD+1./tbl1.AvgA);
    IP2=(1./tbl1.AvgA)./(1./tbl1.AvgH+1./tbl1.AvgD+1./tbl1.AvgA);
    IPOv=(1./tbl1.AvgOver)./(1./tbl1.AvgOver+1./tbl1.AvgUnder);
    IPUn=(1./tbl1.AvgUnder)./(1./tbl1.AvgOver+1./tbl1.AvgUnder);
    IPAHH=(1./tbl1.AvgAHH)./(1./tbl1.AvgAHH+1./tbl1.AvgAHA);
    IPAHA=(1./tbl1.AvgAHA)./(1./tbl1.AvgAHH+1./tbl1.AvgAHA);
%     IP1=(1./tbl1.AvgH);
%     IPX=(1./tbl1.AvgD);
%     IP2=(1./tbl1.AvgA);
%     IPOv=(1./tbl1.AvgOver);
%     IPUn=(1./tbl1.AvgUnder);
%     IPAHH=(1./tbl1.AvgAHH);
%     IPAHA=(1./tbl1.AvgAHA);
    varnames={'IP0_0','IP0_1','IP0_2','IP0_3','IP0_4','IP1_0',...
        'IP1_1','IP1_2','IP1_3','IP1_4','IP2_0','IP2_1','IP2_2',...
        'IP2_3','IP2_4','IP3_0','IP3_1','IP3_2','IP3_3','IP3_4',...
        'IP4_0','IP4_1','IP4_2','IP4_3'};
    adjIP=num2cell((1./tbl1{:,20:43})./sum(1./tbl1{:,20:43},2));
    % Integration of tables
    tbl3=[tbl1,tbl2,table(IP1,IPX,IP2,IPOv,IPUn,IPAHH,IPAHA),adjIP];
    tbl3.Properties.VariableNames(end-23:end)=varnames;
    [r12,~]=find(tbl2{:,end-2:end-1}<5);
    r12p=unique(r12);
    tbl3(r12,:)=[];
    savetblname=['England_',num2str(i),'_proc.xlsx'];
    writetable(tbl3,savetblname,'FileType','spreadsheet');
end
toc;