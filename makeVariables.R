### Load libraries
library(jsonlite)
library(dplyr)

args = commandArgs(trailingOnly=T)
season = args[1]
seasonname=strsplit(season, "./")[[1]][2]
print(seasonname)

### Read in files
allfiles = list.files(season, full=T)
all = lapply(allfiles, fromJSON)

### Get dataframes from json objects
alldfs = lapply(all, function(x) {y = x$resultSets$rowSet[[1]] %>% data.frame(stringsAsFactors=F);
    colnames(y) = x$resultSets$headers[[1]];
    return(y)})

### New variable - Home or Away
alldfs = lapply(alldfs, function(x) {x$LOCATION = ifelse(grepl("@", x$MATCHUP), "Away", "Home"); return(x)})

### New variable - Date in R-friendly date format
alldfs = lapply(alldfs, function(x) {x$DATE = x$GAME_DATE %>% as.Date(format = "%b %d, %Y"); return(x)})

### New variables - This team name, and opponent name - the former is a bit redundant but w/e
alldfs = lapply(alldfs, function(x){ x$THISTEAM = substr(x$MATCHUP %>% as.character,1,3); return(x)})
alldfs = lapply(alldfs, function(x){ x$OPP = substr(x$MATCHUP, nchar(x$MATCHUP)-2, nchar(x$MATCHUP)); return(x)})

### Order season in chronological rather than reverse chronological order
alldfs = lapply(alldfs, function(x){ x = x[order(x$DATE),]; return(x)})

### Fill in missing values - interpreting W to mean wins so far, L - losses so far and W_PCT - Win % so far
alldfs = lapply(alldfs, function(x){ x$W = cumsum(x$WL=="W"); return(x)})
alldfs = lapply(alldfs, function(x){ x$L = cumsum(x$WL=="L"); return(x)})
alldfs = lapply(alldfs, function(x){ x$W_PCT = x$W/(x$W+x$L); return(x)})

### Give each dataframe a name corresponding to the team it belongs to
names(alldfs) = lapply(alldfs, function(x) x$THISTEAM[1])

### Add win/loss margins 
for (team in alldfs) { 
  for (i in 1:nrow(team)) {
   oppteam = alldfs[[team$OPP[i]]]
   team$MARGIN[i] = team$PTS[i] %>% as.numeric - oppteam[oppteam$Game_ID==team$Game_ID[i], ]$PTS %>% as.numeric
  }
  alldfs[[team$THISTEAM[1]]] = team
}

### Remove shitty column - can just use names(df) instead
alldfs = lapply(alldfs, function(x) {x = x[,!colnames(x) %in% c("THISTEAM")]; return(x)})

### FUNCTION FOR CALCULATING WIN/LOSS STREAK ###
calcStreak <- function(WL_vec, W_or_L){ tmp<-cumsum(WL_vec==W_or_L);tmp-cummax((WL_vec!=W_or_L)*tmp)}

### Add win or loss streak functions
alldfs = lapply(alldfs, function(x) {x$WIN_STREAK = calcStreak(x$WL, "W"); return(x)})
alldfs = lapply(alldfs, function(x) {x$LOSS_STREAK = calcStreak(x$WL, "L"); return(x)})

dirpath = paste("../flatfiles", season, sep="/")
print(dirpath)
dir.create(dirpath, recursive=T)

mapply(function(df, names) write.table(df, file=paste0(dirpath, "//", names, "_", seasonname, ".tsv"), sep="\t", quote=F), 
	df=alldfs, names=names(alldfs))

save.image()
