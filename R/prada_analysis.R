#Functions to apply our custom analysis and qc routines after running previous standardised calling and qc pipelines
#

# library(prada)
# library(data.table)
# pradaO<-PradaClass()
# pradaO$connectPradaDatabase(usernameToUse="tng_prada_system", dbnameToUse="prada_central")
# pradaO$addAnalysisSetting(label = "pilot2_nogtube",folderPathAnalysisSequencingRaw = "/Users/jakz/Documents/work_rstudio/prada/data/ont_raw/No_Gtube/20250724_1536_3C_PAY03690_092497cc",folderPathAnalysisOutputRaw = "/Users/jakz/Documents/work_rstudio/prada/work/pgx/pilot2/p2-nogtube-b1")

PradaClass$methods(
  addAnalysisSetting=function(
    label,
    folderPathAnalysisSequencingRaw=NA,
    folderPathAnalysisOutputRaw=NA
  ){
    #analysisSettingsList<-c()
    analysisSettingsList[label][[1]]<<-list(
      folderPathAnalysisSequencingRaw=folderPathAnalysisSequencingRaw,
      folderPathAnalysisOutputRaw=folderPathAnalysisOutputRaw
      )
  }
)

#this function reads metadata and small size data. large data has to be handled using the existing file formats.
PradaClass$methods(
collectSettingCallData=function(settingLabel){
  # settingLabel <- "pilot2_nogtube"
  # pradaApplicationDAO<-pradaO$pradaApplicationDAO
  # analysisSettingsList<-pradaO$analysisSettingsList

  #read file content of sequencing folder
  analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList<<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw)

  #read file content of calling folder
  analysisSettingsList[[settingLabel]]$analysisOutputFilenameList<<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw)

  #sequencing data

  ##final summary metadata. this filename has a unique identifier attachd to it, so we must find it in the file-list
  filenameSummaryMetadata<-grep(pattern = "^final_summary.+\\.txt$",x = analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList, value = T)

  summaryMetadata<-readMetadata(filePath = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameSummaryMetadata))



}
)

#library(prada)
#library(data.table)
# pradaO<-PradaClass()
# pradaO$connectPradaDatabase(usernameToUse="tng_prada_system", dbnameToUse="prada_central")
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx.grch38.5k.0p7percent.bed",nPrioritisedCnv=0, nPrioritisedSnp=0, nPrioritisedTotal = 5000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv.grch38.5k.2p1percent.bed",nPrioritisedSnp=0, nPrioritisedTotal = 5000)
# #pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.5k.1p3percent.bed",nPrioritisedTotal = 5000) #1e6 CNV weighting
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.5k.2p6percent.bed",nPrioritisedTotal = 5000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.25k.4p5percent.bed",nPrioritisedTotal = 25000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.50k.7p3percent.bed",nPrioritisedTotal = 50000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.75k.10p0percent.bed",nPrioritisedTotal = 75000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.100k.12p8percent.bed",nPrioritisedTotal = 100000)


#
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx.grch38.5k.0p7percent.bed",nPrioritisedCnv=0, nPrioritisedSnp=0, nPrioritisedTotal = 5000)
#
# View(pradaO$applicationCoverageRegionsFiltered)

#PGX:                                   The coverage of the current selection is  20296834 bp or  0.006572235
#PGX + CNV:                             The coverage of the current selection is  66340186 bp or  0.02148134
#nPrioritisedTotal = 5000 (no CNV's) :  The coverage of the current selection is  38946202 bp or  0.01261101
#nPrioritisedTotal = 5000 :             The coverage of the current selection is  79617339 bp or  0.02578056
#nPrioritisedTotal = 25000 :            The coverage of the current selection is  139605404 bp or  0.04520505
#nPrioritisedTotal = 50000 :            The coverage of the current selection is  224963114 bp or  0.07284438
#nPrioritisedTotal = 75000 :            The coverage of the current selection is  309284802 bp or  0.1001482
#nPrioritisedTotal = 100000 :           The coverage of the current selection is  394041240 bp or  0.1275929
