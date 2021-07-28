% Main procedure for the paper titled "A machine learning perspective on
% responsible gambling"
% Codes developed by Arman Hassanniakalager
% Last modified 10 Sep. 2018 14:46 BST.
% To obtain the results you need to run these codes as below:
%% Preprocessing
Builder;
%% Modelling
% Normal one with logit
MainModeller;
% Minimum likelihood based on the logit 
MinL_Modeller;
% Betting on all choices
UnitBet;
% Randomly betting
Randomizer;
%% Results 
% The results for the main logit model (most skilled) is saved under name:
% 'Logit_Results.xlsx'

% The results for the second logit model (least skilled) is saved under name:
% 'Logit_Results.xlsx'

% The results for the unit bet model (equal wager on each output) is saved
% under name:
% 'Unit_Bet(UB)_Results.xlsx'

% The results for the random model (randomly choosing a bet outcome) is saved
% under name:
% 'Randomizer_Results.xlsx'