# basketballR
## Analysis of NBA data using R

makeVariables.R gets dataframes from json files, and adds variables

makeDirectories.sh creates a directory structure for the raw files

makeFlatfiles.sh runs makeVariables.R on each of the directories

Additionally, you need to delete the empty files for teams which didn't 
exist at some point before running makeFlatfiles.sh  by running 
`find . -name "*.txt" -size -1k --delete`

The resulting flat files are stored as .tsvs in the folder `data/flatfiles/`

New and updated variables:

1. W: Cumulative wins thus far
2. L: Cumulative losses thus far
3. W_PCT: Cumulative win% thus far
4. LOCATION: Home or Away
5. DATE: R-friendly date format
6. OPP: Opponent
7. MARGIN: Final score margin
8. WIN_STREAK
9. LOSS_STREAK

