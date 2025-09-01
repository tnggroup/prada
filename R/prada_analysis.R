#Functions to apply our custom analysis and qc routines after running previous standardised calling and qc pipelines
#
#
# library(prada)
# library(data.table)
#
# pradaO<-PradaClass()
# pradaO$connectPradaDatabase(usernameToUse="tng_prada_system", dbnameToUse="prada_central")
# pradaO$computeGenomeCoverage(nPrioritisedSnp = 0, nPrioritisedTotal = 5000) #to cache the default regions
# pradaO$addAnalysisSetting(settingLabel = "pilot2_nogtube",folderPathAnalysisSequencingRaw = "/Users/jakz/Documents/work_rstudio/prada/data/ont_raw/No_Gtube/20250724_1536_3C_PAY03690_092497cc",folderPathAnalysisOutputRaw = "/Users/jakz/Documents/work_rstudio/prada/work/pgx/pilot2/p2-nogtube-b1",folderPathDepthAnalysisOutputRaw = "/Users/jakz/Documents/work_rstudio/prada/work/mosdepth/pilot2/p2-nogtube-nobedtest")
# pradaO$collectAnalysisCallData("pilot2_nogtube")
# pradaO$collectAnalysisDepthData("pilot2_nogtube")
# pradaO$computeDepthDataStatistics(filePathBed <- "/Users/jakz/Documents/work_rstudio/prada/data/bed/pgx_cnv.grch38.5k.2p1percent.bed")
# pradaO$printData()

PradaClass$methods(
  addAnalysisSetting=function(
    settingLabel,
    folderPathAnalysisSequencingRaw=NA,
    folderPathAnalysisOutputRaw=NA,
    folderPathDepthAnalysisOutputRaw=NA
  ){

    # settingLabel = "pilot2_nogtube"
    # folderPathAnalysisSequencingRaw = "/Users/jakz/Documents/work_rstudio/prada/data/ont_raw/No_Gtube/20250724_1536_3C_PAY03690_092497cc"
    # folderPathAnalysisOutputRaw = "/Users/jakz/Documents/work_rstudio/prada/work/pgx/pilot2/p2-nogtube-b1"

    #application settings
    # analysisMeta[settingLabel,"code"]<-settingLabel
    # analysisMeta[settingLabel,"pradaPackageVersion"]<-paste(pradaPackageVersion.major.minor.patch,collapse = '.')
    # analysisMeta[settingLabel,"folderPathAnalysisSequencingRaw"]<-analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw
    # analysisMeta[settingLabel,"folderPathAnalysisOutputRaw"]<-analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw


    analysisMeta[settingLabel,"code"]<<-settingLabel
    analysisMeta[settingLabel,"pradaPackageVersion"]<<-paste(pradaPackageVersion.major.minor.patch,collapse = '.')
    analysisMeta[settingLabel,"folderPathAnalysisSequencingRaw"]<<-folderPathAnalysisSequencingRaw
    analysisMeta[settingLabel,"folderPathAnalysisOutputRaw"]<<-folderPathAnalysisOutputRaw
    analysisMeta[settingLabel,"folderPathDepthAnalysisOutputRaw"]<<-folderPathDepthAnalysisOutputRaw

    #analysisSettingsList<-c()
    analysisSettingsList[settingLabel][[1]]<<-list(
      folderPathAnalysisSequencingRaw=folderPathAnalysisSequencingRaw,
      folderPathAnalysisOutputRaw=folderPathAnalysisOutputRaw,
      folderPathDepthAnalysisOutputRaw=folderPathDepthAnalysisOutputRaw
      )
  }
)

#this function reads metadata and small size data. large data has to be handled using the existing file formats.
#Identifies list of barcodes
PradaClass$methods(
collectAnalysisCallData=function(settingLabel){
  # settingLabel <- "pilot2_nogtube"
  # pradaApplicationDAO<-pradaO$pradaApplicationDAO
  # nThread<-pradaO$nThread
  # analysisSettingsList<-pradaO$analysisSettingsList
  # sampleSettingsList<-pradaO$sampleSettingsList
  # analysisMeta<-pradaO$analysisMeta
  # sampleMeta<-pradaO$sampleMeta

  # #read file content of sequencing folder
  # analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw)
  #
  # #read file content of calling folder
  # analysisSettingsList[[settingLabel]]$analysisOutputFilenameList<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw)

  #read file content of sequencing folder
  analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList<<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw)

  #read file content of calling folder
  analysisSettingsList[[settingLabel]]$analysisOutputFilenameList<<-list.files(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw)



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

    dutyTimeData<-data.table::fread(file = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameReportMetadata), skip = (i2+idRownr-1), nrows = trackingEndRownr - (i2+idRownr-1), fill = T, header = T, sep = ",",strip.white = T) #this reads the file again
    #View(dutyTimeData)

    dutyTimeData<-dutyTimeData[`Channel State`!='---' & nchar(`Channel State`)>0,] #quick cleaning because the previous read is rough towards the end

    #analysisSettingsList[[settingLabel]]$dutyTimeData<-as.data.frame(dutyTimeData)
    analysisSettingsList[[settingLabel]]$dutyTimeData<<-as.data.frame(dutyTimeData)


  } else {
    warning(paste0("Could not find the Duty Time section of the report file, for analysis label ",settingLabel))
  }


  if(is.numeric(i3) && i31==2){

    endRownr<-length(reportFileData)
    idRownr<- grep("ID:",x = reportFileData[i3:endRownr])[1] #this assumes one id-row
    trackingEndRownr<- grep("---",x = reportFileData[i3:endRownr])[1] + i3 -2 #this assumes one id-row

    throughputData<-data.table::fread(file = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameReportMetadata), skip = (i3+idRownr-1), nrows = trackingEndRownr - (i3+idRownr-1), fill = T, header = T, sep = ",",strip.white = T) #this reads the file again
    #View(throughputData)

    throughputData<-throughputData[`Experiment Time (minutes)` !='---' & nchar(`Experiment Time (minutes)` )>0,] #quick cleaning because the previous read is rough towards the end

    #analysisSettingsList[[settingLabel]]$throughputData<-as.data.frame(throughputData)
    analysisSettingsList[[settingLabel]]$throughputData<<-as.data.frame(throughputData)


  } else {
    warning(paste0("Could not find the Throughput section of the report file, for analysis label ",settingLabel))
  }


  ##sequencing_summary_XXXXX.txt #massive size!!! ~47GB
  ## Let's not read this until we know what to use it for

  # filenameSequencingSummary<-grep(pattern = "^sequencing_summary.+\\.txt$",x = analysisSettingsList[[settingLabel]]$analysisSequencingFilenameList, value = T)
  # sequencingSummaryData<-data.table::fread(file = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameSequencingSummary), fill = T, header = T, strip.white = T,nThread = nThread)



  #wf-pgx data

  ##launch.json

  #check if sequencing data exists, otherwise abort - assume that it is present for all analyses
  if(!file.exists(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw,"launch.json"))){
    warning(paste0("No calling data available for label ",settingLabel))
    return(0)
  }

  con = file(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw,"launch.json"),open="r")
  callLaunchDataString <- readLines(con = con,encoding = "UTF-8")
  close(con)
  callLaunchData<-jsonlite::fromJSON(callLaunchDataString)
  #View(callLaunchData)


  #analysisMeta[settingLabel,"wfpgx_instanceid"]<-callLaunchData$instanceId
  analysisMeta[settingLabel,"wfpgx_instanceid"]<<-callLaunchData$instanceId #only saves instance ID for now


  #output/params.json
  con = file(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw,"output","params.json"),open="r")
  callOutputParamsDataString <- readLines(con = con,encoding = "UTF-8")
  close(con)
  callOutputParamsData<-jsonlite::fromJSON(callOutputParamsDataString)
  #View(callOutputParamsData)

  nl <- unlist(callOutputParamsData,recursive = TRUE,use.names = TRUE)

  names(nl)<-sub("\\.",replacement = "_",x = paste0("wfpgx_",names(nl)))

  #analysisMeta[names(nl)]<-nl
  analysisMeta[names(nl)]<<-nl

  ##output/software.versions.txt
  softwareVersionData<-data.table::fread(file = file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw,"output","software_versions.txt"), fill = T, header = F, sep = ",",strip.white = T)
  colnames(softwareVersionData)<-c("software","version")
  #View(softwareVersionData)

  #analysisMeta[settingLabel,"wfpgx_softwareVersions"]<-jsonlite::toJSON(softwareVersionData)
  analysisMeta[settingLabel,"wfpgx_softwareVersions"]<<-jsonlite::toJSON(softwareVersionData)

  ##output/barcodeXX folders

  outputFiles <- list.files(file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw,"output"))
  barcodeFolders<-grep(pattern = "^barcode\\d\\d",x = outputFiles,value = T)

  if(length(barcodeFolders)>0){
    for(iBarcode in 1:length(barcodeFolders)){
      #iBarcode<-1
      cUniqueSampleLabel <- paste0(settingLabel,"_",barcodeFolders[iBarcode])
      cBarcodeFolderpath<-file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisOutputRaw,"output",barcodeFolders[iBarcode])

      #sampleMeta[cUniqueSampleLabel,c("analysis","barcode")]<-c(settingLabel,barcodeFolders[iBarcode])
      sampleMeta[cUniqueSampleLabel,c("analysis","barcode")]<<-c(settingLabel,barcodeFolders[iBarcode])

      ##barcode match.json
      con = file(file.path(cBarcodeFolderpath,paste0(barcodeFolders[iBarcode],".match.json")),open="r")
      dString <- paste0(readLines(con = con,encoding = "UTF-8"),collapse = "\n")
      close(con)
      dJson<-jsonlite::fromJSON(dString,simplifyDataFrame=FALSE) #this otherwise reverts to true for some reason and creates data frames

      #cyp2d6 call from chinook
      d<-as.data.frame(data.table::fread(file = file.path(cBarcodeFolderpath,"CYP2D6","report.tsv"), fill = T, header = T,strip.white = T))

      nd <- list(
        source="CHINOOK",
        version="2025-08-20",
        chromosome="chr22",
        gene="CYP2D6",
        diplotypes = list(
          list(name=d[d$Sample=="CYP2D6",c(barcodeFolders[iBarcode])])
        )
      )
      nd$source<-jsonlite::unbox(nd$source)
      nd$version<-jsonlite::unbox(nd$version)
      nd$chromosome<-jsonlite::unbox(nd$chromosome)
      nd$gene<-jsonlite::unbox(nd$gene)
      #ndJson <- jsonlite::toJSON(x = nd,pretty = TRUE)

      dJson$results[[length(dJson$results)+1]]<- nd #update with cyp2d6 call
      #View(dJson$results)
      #length(dJson$results)


      # dString2 <- jsonlite::toJSON(x = dJson,pretty = TRUE)
      # con = file(file.path("updated.match.json"),open="w")
      # writeLines(con = con,text = dString2,sep = "\n")
      # close(con)

      #sampleSettingsList[[cUniqueSampleLabel]]$pgx_calls<-dJson
      sampleSettingsList[[cUniqueSampleLabel]]$pgx_calls<<-dJson

      # #sampleMeta[cUniqueSampleLabel,c("analysis","barcode","pgx_calls")]<-c(settingLabel,barcodeFolders[iBarcode],jsonlite::toJSON(dJson,pretty = TRUE))
      # sampleMeta[cUniqueSampleLabel,c("analysis","barcode","pgx_calls")]<<-c(settingLabel,barcodeFolders[iBarcode],jsonlite::toJSON(dJson,pretty = TRUE))

      ## XX.pharmcat.tsv
      d<-as.data.frame(data.table::fread(file = file.path(cBarcodeFolderpath,paste0(barcodeFolders[iBarcode],".pharmcat.tsv")), fill = T, header = T,strip.white = T))

      #sampleSettingsList[[cUniqueSampleLabel]]$pgx_calls_table<-d
      sampleSettingsList[[cUniqueSampleLabel]]$pgx_calls_table<<-d

    }
  }

  }
)


PradaClass$methods(
  collectAnalysisDepthData=function(
    settingLabel
  ){
    # settingLabel <- "pilot2_nogtube"
    # pradaApplicationDAO<-pradaO$pradaApplicationDAO
    # nThread<-pradaO$nThread
    # analysisSettingsList<-pradaO$analysisSettingsList
    # sampleSettingsList<-pradaO$sampleSettingsList
    # analysisMeta<-pradaO$analysisMeta
    # sampleMeta<-pradaO$sampleMeta

    if(nrow(sampleMeta>0)){
      for(iBarcode in 1:nrow(sampleMeta)){
        #iBarcode<-1
        if(!sampleMeta[iBarcode,c("analysis")]==settingLabel) next
        cBarcode<-sampleMeta[iBarcode,c("barcode")]
        cUniqueSampleLabel <- paste0(settingLabel,"_",cBarcode)

        #per-base bed
        d<-as.data.frame(data.table::fread(file = file.path(analysisMeta[settingLabel,c("folderPathDepthAnalysisOutputRaw")],paste0(cBarcode,".per-base.bed.gz"))))
        #sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthTable<-d
        sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthTable<<-d

        cFile<-file.path(analysisMeta[settingLabel,c("folderPathDepthAnalysisOutputRaw")],paste0(cBarcode,".regions.bed.gz"))
        if(file.exists(cFile)){
          #regions bed
          d<-as.data.frame(data.table::fread(file = cFile))
          #sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTable<-d
          sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTable<<-d
        }
      }
    }

  }
)

#requires applicationCoverageRegions loaded from db or file
#pradaO$computeGenomeCoverage(nPrioritisedSnp = 0, nPrioritisedTotal = 5000)
PradaClass$methods(
  computeDepthDataStatistics=function(
    filePathBed
    ){
    # pradaApplicationDAO<-pradaO$pradaApplicationDAO
    # nThread<-pradaO$nThread
    # analysisSettingsList<-pradaO$analysisSettingsList
    # sampleSettingsList<-pradaO$sampleSettingsList
    # analysisMeta<-pradaO$analysisMeta
    # sampleMeta<-pradaO$sampleMeta
    # applicationCoverageRegions<-pradaO$applicationCoverageRegions
    #
    # filePathBed <- "/Users/jakz/Documents/work_rstudio/prada/data/bed/pgx_cnv.grch38.5k.2p1percent.bed"


    dApplicationCoverageRegions<-applicationCoverageRegions
    colnames(dApplicationCoverageRegions)<-paste0(colnames(dApplicationCoverageRegions),"_region")
    setDT(dApplicationCoverageRegions)
    setkeyv(dApplicationCoverageRegions,cols = c("chr_name_region","bp1_region","bp2_region"))

    dBed<-data.table::fread(file = filePathBed)
    colnames(dBed)<-c("chr_bed","bp1_bed","bp2_bed","label","v")
    setDT(dBed)
    setkeyv(dBed,cols = c("chr_bed","bp1_bed","bp2_bed"))

    #unique(dBed$chr_bed)


    if(nrow(sampleMeta)>0){
      for(iSample in 1:nrow(sampleMeta)){
        #iSample<-1
        cAnalysisLabel<-sampleMeta[iSample,c("analysis")]
        cBarcode<-sampleMeta[iSample,c("barcode")]
        cUniqueSampleLabel <- paste0(cAnalysisLabel,"_",cBarcode)

        dDepth<-sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthTable
        colnames(dDepth)<-c("chr","bp1","bp2","v")
        setDT(dDepth)
        setkeyv(dDepth,cols = c("chr","bp1","bp2"))

        #unique(dDepth$chr)

        dDepth[dBed,on=.(chr=chr_bed,bp1<bp2_bed, bp1>=bp1_bed), c('bp1InBed','bp1_bedlabel') := list(1,i.label)]
        dDepth[dBed,on=.(chr=chr_bed,bp2<=bp2_bed, bp2>bp1_bed), c('bp2InBed','bp2_bedlabel') := list(1,i.label)]
        dDepth[bp1InBed==1 & bp2InBed==1 & bp1_bedlabel==bp2_bedlabel, bpInBed:=1]

        dDepth[dApplicationCoverageRegions,on=.(chr=chr_name_region,bp1<bp2_region, bp1>=bp1_region), c('bp1InRegion','bp1_regionlabel') := list(1,i.label_region)]
        dDepth[dApplicationCoverageRegions,on=.(chr=chr_name_region,bp2<=bp2_region, bp2>bp1_region), c('bp2InRegion','bp2_regionlabel') := list(1,i.label_region)]
        dDepth[(bp1InRegion==1 | bp2InRegion==1) & bp1_regionlabel==bp2_regionlabel, overlappingRegion:=1]

        dDepth[,length:=bp2-bp1]

        #View(dDepth[bpInBed==1,])
        #View(dDepth[bpInBed!=1 | is.na(bpInBed),])
        #stats

        #sequening depth stratified by in bed region and not in bed region
        dDepth.inBed<-dDepth[bpInBed==1,]
        qInBed<-ggstats::weighted.quantile(x = unlist(dDepth.inBed$v), w = unlist(dDepth.inBed$length), probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)
        dDepth.notInBed<-dDepth[bpInBed!=1 | is.na(bpInBed),]
        qNotInBed<-ggstats::weighted.quantile(x = unlist(dDepth.notInBed$v), w = unlist(dDepth.notInBed$length), probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)

        # sampleMeta[cUniqueSampleLabel,c("sdepth_q000_bed","sdepth_q002_bed","sdepth_q025_bed","sdepth_q050_bed","sdepth_q075_bed","sdepth_q098_bed","sdepth_q100_bed","sdepth_q000_nobed","sdepth_q002_nobed","sdepth_q025_nobed","sdepth_q050_nobed","sdepth_q075_nobed","sdepth_q098_nobed","sdepth_q100_nobed")]<-c(
        #   qInBed[1],qInBed[2],qInBed[3],qInBed[4],qInBed[5],qInBed[6],qInBed[7],qNotInBed[1],qNotInBed[2],qNotInBed[3],qNotInBed[4],qNotInBed[5],qNotInBed[6],qNotInBed[7]
        #   )
        sampleMeta[cUniqueSampleLabel,c("sdepth_q000_bed","sdepth_q002_bed","sdepth_q025_bed","sdepth_q050_bed","sdepth_q075_bed","sdepth_q098_bed","sdepth_q100_bed","sdepth_q000_nobed","sdepth_q002_nobed","sdepth_q025_nobed","sdepth_q050_nobed","sdepth_q075_nobed","sdepth_q098_nobed","sdepth_q100_nobed")]<<-c(
          qInBed[1],qInBed[2],qInBed[3],qInBed[4],qInBed[5],qInBed[6],qInBed[7],qNotInBed[1],qNotInBed[2],qNotInBed[3],qNotInBed[4],qNotInBed[5],qNotInBed[6],qNotInBed[7]
        )

        #per original region statistics

        dApplicationCoverageRegions.sample<-dApplicationCoverageRegions

        dDepth.overlappingRegion<-dDepth[overlappingRegion==1,]

        dDepth.overlappingRegion.aggstats<-dDepth.overlappingRegion[, .(
          count = .N,
          q002 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[2],
          q025 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[3],
          q050 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[4],
          q075 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[5],
          q098 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[6]
          ), by = bp1_regionlabel]

        dApplicationCoverageRegions.sample[dDepth.overlappingRegion.aggstats,on=c(label_region='bp1_regionlabel'),c('sdepth_q002','sdepth_q025','sdepth_q050','sdepth_q075','sdepth_q098') := list(i.q002,i.q025,i.q050,i.q075,i.q098)]

        #sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthOriginalRegionsTableCustom<-as.data.frame(dApplicationCoverageRegions.sample)
        sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthOriginalRegionsTableCustom<<-as.data.frame(dApplicationCoverageRegions.sample)


        #per bed region statistics

        dBed.sample<-dBed
        dBed.sample[,v:=NULL]

        #dDepth.inBed.aggstats<-dDepth.inBed[, .(count = .N, var = median(v)), by = bp1_bedlabel]

        dDepth.inBed.aggstats<-dDepth.inBed[, .(
          count = .N,
          q002 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[2],
          q025 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[3],
          q050 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[4],
          q075 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[5],
          q098 = ggstats::weighted.quantile(x = v,w = length, probs = c(0,0.02,0.25,0.5,0.75,0.98,1), na.rm = T)[6]
        ), by = bp1_bedlabel]

        dBed.sample[dDepth.inBed.aggstats,on=c(label='bp1_bedlabel'),c('sdepth_q002','sdepth_q025','sdepth_q050','sdepth_q075','sdepth_q098') := list(i.q002,i.q025,i.q050,i.q075,i.q098)]

        #sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTableCustom<-as.data.frame(dBed.sample)
        sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTableCustom<<-as.data.frame(dBed.sample)

        #View(sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTable)
        #View(sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTableCustom)

      }
    }


  }
)

PradaClass$methods(
  printData=function(
  ){
    # pradaApplicationDAO<-pradaO$pradaApplicationDAO
    # nThread<-pradaO$nThread
    # analysisSettingsList<-pradaO$analysisSettingsList
    # sampleSettingsList<-pradaO$sampleSettingsList
    # analysisMeta<-pradaO$analysisMeta
    # sampleMeta<-pradaO$sampleMeta
    # applicationCoverageRegions<-pradaO$applicationCoverageRegions


    #original regions (as loaded)
    if(!is.null(applicationCoverageRegions)){
      applicationCoverageRegions.filepath<-"applicationCoverageRegions.tsv"
      fwrite(applicationCoverageRegions,file = applicationCoverageRegions.filepath,sep = "\t",row.names = F,col.names = T, append = F, nThread = nThread)
    }

    analysisMeta.filepath<-"analysisMeta.tsv"
    fwrite(analysisMeta,file = analysisMeta.filepath,sep = "\t",row.names = F,col.names = T, append = F, nThread = nThread)

    sampleMeta.filepath<-"sampleMeta.tsv"
    fwrite(sampleMeta,file = sampleMeta.filepath,sep = "\t",row.names = F,col.names = T, append = F, nThread = nThread)


    #nothing here yet - most data in sample settings list etc
    # if(nrow(analysisMeta)>0){
    #   for(iAnalysis in 1:nrow(analysisMeta)){
    #     #iAnalysis<-1
    #     cAnalysisLabel<-analysisMeta[iAnalysis,c("code")]
    #
    #     #nrow(analysisSettingsList[[cAnalysisLabel]]$dutyTimeData)
    #     #nrow(analysisSettingsList[[cAnalysisLabel]]$throughputData)
    #
    #
    #   }
    # }

    if(nrow(sampleMeta)>0){
      for(iSample in 1:nrow(sampleMeta)){
        #iSample<-1
        cAnalysisLabel<-sampleMeta[iSample,c("analysis")]
        cBarcode<-sampleMeta[iSample,c("barcode")]
        cUniqueSampleLabel <- paste0(cAnalysisLabel,"_",cBarcode)

        cfilepath<-paste0("sampleSequencingDepthRegionsTableCustom_",cUniqueSampleLabel,".tsv")
        fwrite(sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthRegionsTableCustom,file = cfilepath,sep = "\t",row.names = F,col.names = T, append = F, nThread = nThread)

        cfilepath<-paste0("sequencingDepthOriginalRegionsTableCustom_",cUniqueSampleLabel,".tsv")
        fwrite(sampleSettingsList[[cUniqueSampleLabel]]$sequencingDepthOriginalRegionsTableCustom,file = cfilepath,sep = "\t",row.names = F,col.names = T, append = F, nThread = nThread)

      }
    }


  }
)


