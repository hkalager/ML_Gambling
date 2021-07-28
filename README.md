# ML_Gambling

These scripts replicate main results for the paper entitled "A machine learning perspective on responsible gambling"
You can access the paper via https://doi.org/10.1017/bpp.2019.9

To obtain the results you need to run these codes as below:
1) Preprocessing: run the script "Builder.m"
2) Modelling: to run the main results with logit use the script "MainModeller.m"
3) Minimum likelihood: to run the results for a minimum likelihood logit approach, use the script "MinL_Modeller.m"
4) Betting on all choices: to run the results for a case of 1/N for all betting outcomes, use the script "UnitBet.m"
5) Randomly betting: finally for simulating the random outcome betting use the code "Randomizer.m"


Results:
- The results for the main logit model (most skilled) is saved under name: 'Logit_Results.xlsx'
- The results for the second logit model (least skilled) is saved under name:'Logit_Results.xlsx'
- The results for the unit bet model (equal wager on each output) is saved under name:'Unit_Bet(UB)_Results.xlsx'
- The results for the random model (randomly choosing a bet outcome) is saved under name:'Randomizer_Results.xlsx'
