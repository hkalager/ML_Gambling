%% Gambler game function to simulate the gambler practice
% Script by Arman Hassanniakalager for the Football paper
% Created on 17 JUL 2017 13:38 BST,
% Last modified 03 JUN 2018 20:43 BST.
%% Inputs:
%   -PayoffSer: The initial series of payoff per game
%   -InvestSize: Investment per bet (in %), default=0.01
%   -CapitalBlock: Imaginary capital size (in currency unit), default=1000
function [betprofit,hl,capser]=gamblerfun(PayoffSer,InvestSize,CapitalBlock)
if nargin==0
    error(' You need to call the function at least with one input (initial payoff)!!');
elseif nargin==1
    InvestSize=0.01;
    CapitalBlock=1000;
elseif nargin==2
    CapitalBlock=1000;
end
retser=zeros(numel(PayoffSer),1);
retser(1)=InvestSize*CapitalBlock*PayoffSer(1);
capser=zeros(numel(PayoffSer),1);
capser(1)=CapitalBlock+retser(1);
for q=2:numel(PayoffSer)
    retser(q)=round(InvestSize*(capser(q-1)),1)*PayoffSer(q);
    capser(q)=max(capser(q-1)+retser(q),0);
end
hl=find(capser/CapitalBlock<=0.5,1,'first');
if isempty(hl)
    hl=Inf;
end
betprofit=capser(end)/CapitalBlock-1;