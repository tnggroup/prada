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
  # analysisMeta<-pradaO$analysisMeta


  # #read file content of sequencing folder
  # analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw)
  #
  # #read file content of calling folder
  # analysisSettingsList[[settingLabel]]$analysisOutputFilenameList<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw)

  #read file content of sequencing folder
  analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList<<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw)

  #read file content of calling folder
  analysisSettingsList[[settingLabel]]$analysisOutputFilenameList<<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw)


  #application settings
  # analysisMeta[settingLabel,"code"]<-settingLabel
  # analysisMeta[settingLabel,"folderPathAnalysisSequencingRaw"]<-analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw
  # analysisMeta[settingLabel,"folderPathAnalysisOutputRaw"]<-analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw

  analysisMeta[settingLabel,"code"]<<-settingLabel
  analysisMeta[settingLabel,"folderPathAnalysisSequencingRaw"]<<-analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw
  analysisMeta[settingLabel,"folderPathAnalysisOutputRaw"]<<-analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw



  #sequencing data

  ##final summary metadata. this filename has a unique identifier attachd to it, so we must find it in the file-list
  filenameSummaryMetadata<-grep(pattern = "^final_summary.+\\.txt$",x = analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList, value = T)

  #check if sequencing data exists, otherwise abort - assume that it is present for all analyses
  if(!file.exists(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameSummaryMetadata))){
    warning(paste0("No sequencing data present for analysis label ",settingLabel))
    return(0)
  }

  summaryMetadata<-readMetadata(filePath = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameSummaryMetadata))

  #analysisMeta[settingLabel,names(summaryMetadata)]<-summaryMetadata
  analysisMeta[settingLabel,names(summaryMetadata)]<<-summaryMetadata

  # [1] "instrument"                "position"
  # [3] "flow_cell_id"              "sample_id"
  # [5] "protocol_group_id"         "protocol"
  # [7] "protocol_run_id"           "acquisition_run_id"
  # [9] "started"                   "acquisition_stopped"
  # [11] "processing_stopped"        "basecalling_enabled"
  # [13] "sequencing_summary_file"   "fast5_files_in_final_dest"
  # [15] "fast5_files_in_fallback"   "pod5_files_in_final_dest"
  # [17] "pod5_files_in_fallback"    "fastq_files_in_final_dest"
  # [19] "fastq_files_in_fallback"   "bam_files_in_final_dest"
  # [21] "bam_files_in_fallback"


  ##sample sheet. this filename has a unique identifier attachd to it, so we must find it in the file-list
  filenameSampleSheetMetadata<-grep(pattern = "^sample_sheet.+\\.csv$",x = analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList, value = T)

  sampleSheetMetadata<-data.table::fread(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameSampleSheetMetadata))

  #we use the first row as representative of the whole analysis, assume no more rows/(samples?)
  #analysisMeta[settingLabel,colnames(sampleSheetMetadata)]<-sampleSheetMetadata[1,]
  analysisMeta[settingLabel,colnames(sampleSheetMetadata)]<<-sampleSheetMetadata[1,]

  # [1] "protocol_run_id"        "position_id"
  # [3] "flow_cell_id"           "sample_id"
  # [5] "experiment_id"          "flow_cell_product_code"
  # [7] "kit"


  ##report_xxxxx.md this file has metadata, channel(flow-cell?) state/time(minutes)/samples(what unit is this? reads?), throughput statistics
  filenameReportMetadata<-grep(pattern = "^report.+\\.md$",x = analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList, value = T)

  con = file(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameReportMetadata),open="r")
  reportFileData <- readLines(con = con,encoding = "UTF-8")
  close(con)

  i1 <- grep("Tracking ID",x = reportFileData)
  i11 <- grep("={4,}",x = reportFileData[i1:length(reportFileData)])[1]

  i2 <- grep("Duty Time",x = reportFileData)
  i21 <- grep("={4,}",x = reportFileData[i2:length(reportFileData)])[1]

  i3 <- grep("Throughput",x = reportFileData)
  i31 <- grep("={4,}",x = reportFileData[i3:length(reportFileData)])[1]

  if(is.numeric(i1) && i11==2){

    endRownr<-ifelse(is.numeric(i2),i2-1,
                     ifelse(is.numeric(i3),i3-1,length(reportFileData))
                     )

    iTrackingBracketStart <- grep("\\{",x = reportFileData)
    iTrackingBracketEnd <- grep("\\}",x = reportFileData)
    iTrackingBracketStart<-iTrackingBracketStart[iTrackingBracketStart<endRownr][1]
    iTrackingBracketEnd<-iTrackingBracketEnd[iTrackingBracketEnd<endRownr][1]

    trackingIdString<-paste(reportFileData[iTrackingBracketStart:iTrackingBracketEnd],sep = "\n",collapse = '')
    trackingIdData<-jsonlite::fromJSON(trackingIdString)

    #analysisMeta[settingLabel,names(trackingIdData)]<-trackingIdData
    analysisMeta[settingLabel,names(trackingIdData)]<<-trackingIdData


  } else {
    warning(paste0("Could not find the Tracking ID section of the report file, for analysis label ",settingLabel))
  }

  if(is.numeric(i2) && i21==2){

    endRownr<-ifelse(is.numeric(i3),i3-1,length(reportFileData))
    idRownr<- grep("ID:",x = reportFileData[i2:endRownr])[1] #this assumes one id-row
    trackingEndRownr<- grep("---",x = reportFileData[i2:endRownr])[1] + i2 -2 #this assumes one id-row


    #dutyTimeString<-paste(reportFileData[(i2+idRownr):endRownr],sep = "\n",collapse = '')
    dutyTimeData<-data.table::fread(file = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameReportMetadata), skip = (i2+idRownr-1), nrows = trackingEndRownr - (i2+idRownr), fill = T, header = T, sep = ",",strip.white = T) #this reads the file again
    #View(dutyTimeData)

    #analysisMeta[settingLabel,names(trackingIdData)]<-trackingIdData
    analysisMeta[settingLabel,names(trackingIdData)]<<-trackingIdData


  } else {
    warning(paste0("Could not find the Duty Time section of the report file, for analysis label ",settingLabel))
  }

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
