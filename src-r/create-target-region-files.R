
library(prada)
library(data.table)

settingProjectFolder<-"/Users/jakz/Documents/work_rstudio/prada"

pradaO<-PradaClass()
pradaO$connectPradaDatabase(usernameToUse="tng_prada_system", dbnameToUse="prada_central_dev")
pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx.grch38.5k.0p7percent.bed"),nPrioritisedCnv=0, nPrioritisedSnp=0, nPrioritisedTotal = 5000)
pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx_cnv.grch38.5k.2p1percent.bed"),nPrioritisedSnp=0, nPrioritisedTotal = 5000)
#pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.5k.1p3percent.bed",nPrioritisedTotal = 5000) #1e6 CNV weighting
pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx_cnv_mddeur.grch38.5k.2p6percent.bed"),nPrioritisedTotal = 5000)
pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx_cnv_mddeur.grch38.25k.4p5percent.bed"),nPrioritisedTotal = 25000)
pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx_cnv_mddeur.grch38.50k.7p3percent.bed"),nPrioritisedTotal = 50000)
#pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx_cnv_mddeur.grch38.75k.10p0percent.bed"),nPrioritisedTotal = 75000)
#pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx_cnv_mddeur.grch38.100k.12p8percent.bed"),nPrioritisedTotal = 100000)


pradaO$computeGenomeCoverage( writeToThisBedPath = file.path(settingProjectFolder,"data","bed","pgx.grch38.padded_100k.bed"),nPrioritisedCnv=0, nPrioritisedSnp=0, nPrioritisedTotal = 1000, writePaddedStrands = T, paddingGeneBp = 100000)

#View(pradaO$applicationCoverageRegionsFiltered[pradaO$applicationCoverageRegionsFiltered$label=="CYP2D6",])
# #check
# bedDf1<-pradaO$applicationCoverageRegionsFiltered
# data.table::setorderv(bedDf1,
#                       cols = c("chr","bp1","id","bp2"),
#                       order =c(1,1,1,1)
# )
# View(bedDf1)
#
# bedDf<-pradaO$applicationCoverageRegionsFilteredPaddedStrands
# data.table::setorderv(bedDf,
#                       cols = c("chr","bp1","id","strand","bp2"),
#                       order =c(1,1,1,1,1)
# )
# View(bedDf)

#PGX:                                   The coverage of the current selection is  20296834 bp or  0.006572235
#PGX + CNV:                             The coverage of the current selection is  66340186 bp or  0.02148134
#nPrioritisedTotal = 5000 (no CNV's) :  The coverage of the current selection is  38946202 bp or  0.01261101
#nPrioritisedTotal = 5000 :             The coverage of the current selection is  79617339 bp or  0.02578056
#nPrioritisedTotal = 25000 :            The coverage of the current selection is  139605404 bp or  0.04520505
#nPrioritisedTotal = 50000 :            The coverage of the current selection is  224963114 bp or  0.07284438
#nPrioritisedTotal = 75000 :            The coverage of the current selection is  309284802 bp or  0.1001482
#nPrioritisedTotal = 100000 :           The coverage of the current selection is  394041240 bp or  0.1275929
