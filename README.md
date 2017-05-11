# basketballR
## Analysis of NBA data using R
makeVariables.R gets dataframes from json files, and adds variables
makeDirectories.sh creates a directory structure for the raw files
makeFlatfiles.sh runs makeVariables.R on each of the directories

Additionally, you need to delete the empty files for teams which didn't 
exist at some point by running

find . -name "*.txt" -size -1k --delete
