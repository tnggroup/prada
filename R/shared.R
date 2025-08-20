# library(tm)
# library(DBI)
# library(RPostgres)
# library(data.table)
# library(seqinr)

#general shared package utilities
pradaPackageVersion.major.minor.patch<-c()
pradaPackageVersion.major.minor.patch[1]<-0
pradaPackageVersion.major.minor.patch[2]<-2
pradaPackageVersion.major.minor.patch[3]<-0


pradaCentralDBDefaultHost <- "localhost"
pradaCentralDBDefaultUsername <- "tng_prada_system"
pradaCentralDBDefaultDbName <- "prada_local"
pradaCentralDBDefaultPort <- 65432

filePathBed<-file.path("..","data","grch38.5k.1p3percent.bed")
filePathFasta=file.path("..","data","GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz")


#this is WIP?
createAdaptedFastaReferenceForCustomBed=function(
    filePathBed,
    filePathFasta=file.path("data","GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz")
){
  ref <- seqinr::read.fasta(file = filePathFasta)
  bed <- fread(file = filePathBed, sep = "\t",header = T)

}

#re-used from the gwas_sumstats genetic correlations project
readMetadata <- function(filePath,labelValueSeparator='='){
  toReturn<-c()
  #filePath <- file.path(analysisSettingsList[[settingLabel]]$folderPathAnalysisSequencingRaw,filenameSummaryMetadata)
  con = file(filePath,open="r")
  f <- readLines(con = con,encoding = "UTF-8")
  for(iLine in 1:length(f)){
    if(nchar(f[iLine])>2){
      #iLine<-1
      #strsplit(x = f[iLine], split = "\\s")
      m<-gregexpr(pattern = paste0("\\s*\\w*",labelValueSeparator,"\\w*\\s*"),text = f[iLine])
      k<-NA
      v<-NA
      if(length(m)>0){
        if(length(m[[1]])>0) {
          fullString <- trimws(substr(x =f[iLine], start = m[[1]][[1]],  stop = m[[1]][[1]]+(attr(x = m[[1]], which = "match.length")[[1]]-1)),which = "both")
          fullString.split<-strsplit(fullString,split = labelValueSeparator)
          k<-trimws(fullString.split[[1]][[1]], which = "both")
          v<-trimws(fullString.split[[1]][[2]], which= "both")
        }
      }

      if(!is.na(k) & !is.na(v)) toReturn[k]<-v

    }
  }
  close(con)
  return(toReturn)

}

#TODO this does not quite remove duplicates? Is this still a problem? Needs more testing.
#parses and formats the provided column names to the database standard
formatStdColumnNames=function(columnNames,prefixesToExcludeRegex=c(), prefixesToItemiseRegex=c(),suffixesToExcludeRegex=c(), deitemise=F, forceItem=NULL, maxVariableNameLength=30){ #enumerate= - not used, enumerationCharacterLength=4

  #test
  # columnNames <- colnames(dbutil$importDataDf)
  # prefixesToExcludeRegex = list("alsfrs\\.")
  # suffixesToExcludeRegex = list("_followup1")
  # maxVariableNameLength=30
  # prefixesToItemiseRegex=c()
  # #prefixesToItemiseRegex <- paste0(nontabMeta$code,"\\.")
  # deitemise=T
  # forceItem=NULL
  # maxVariableNameLength=30

  columnNames.orig<-columnNames

  itemisedColumnNames<-c()

  colsNumeric<-grepl(pattern = ".+_numeric$",x = columnNames, ignore.case = T)

  valueLabels<-data.frame(valueColumn=columnNames.orig[colsNumeric])
  valueLabels$valueLabelColumn<-gsub(pattern = "(.+)_numeric$",replacement = "\\1", x = valueLabels$valueColumn, ignore.case = T)
  valueLabels<-merge(data.frame(valueColumn=columnNames.orig),valueLabels,by = "valueColumn", all.x = T)
  rownames(valueLabels)<-valueLabels$valueColumn #this is sensitive to duplicates in valueColumn
  valueLabels<-valueLabels[columnNames.orig,]
  colsValueLabels<-columnNames.orig %in% valueLabels$valueLabelColumn


  colsSelect<-!colsValueLabels  #add more logic here when additional column types


  #per column name - exclude prefixes and _numeric suffixes
  for(iCol in 1:length(columnNames)){
    #iCol<-10
    cName<-columnNames[iCol]
    #parse column name further
    ##exclude prefixes if any
    if(length(prefixesToExcludeRegex)>0){
      for(iPat in 1:length(prefixesToExcludeRegex)){
        #iPat<-1
        cName<-gsub(pattern = paste0("^",prefixesToExcludeRegex[iPat],"(.+)"),replacement = "\\1", x = cName)
      }
    }

    cPrefix<-NA
    if(length(prefixesToItemiseRegex)>0){
      for(iPat in 1:length(prefixesToItemiseRegex)){
        #iPat<-1

        if(grepl(pattern = paste0("^",prefixesToItemiseRegex[iPat]),x = cName)){
          cPrefix <- sub(pattern = paste0("^(",prefixesToItemiseRegex[iPat],").*"),replacement = "\\1", x = cName)
        }
        cName <- gsub(pattern = paste0("^",prefixesToItemiseRegex[iPat],"(.+)"),replacement = "\\1", x = cName)

      }
    }

    ##exclude numeric suffix - execute before other suffixes
    cName<-gsub(pattern = paste0("(.+)_numeric$"),replacement = "\\1", x = cName, ignore.case = T)

    ##exclude more suffixes
    if(length(suffixesToExcludeRegex)>0){
      for(iPat in 1:length(suffixesToExcludeRegex)){
        #iPat<-1
        cName<-gsub(pattern = paste0("(.+)",suffixesToExcludeRegex[iPat],"$"),replacement = "\\1", x = cName)
      }
    }

    #store results
    columnNames[iCol]<-cName
    itemisedColumnNames[iCol]<-cPrefix
  }

  if(deitemise) {
    columnNames<-gsub(pattern = "[_]",replacement = "", x = columnNames)
    itemisedColumnNames<-gsub(pattern = "[_]",replacement = "", x = itemisedColumnNames)
  }



  #trim unwanted characters
  columnNames<-gsub(pattern = "[^A-Za-z0-9_]",replacement = "", x = columnNames) #includes the _ character to accomodate the item categorisation
  columnNames<-gsub(pattern = "[\\.]",replacement = "", x = columnNames)
  itemisedColumnNames<-gsub(pattern = "[^A-Za-z0-9_]",replacement = "", x = itemisedColumnNames) #includes the _ character to accomodate the item categorisation
  itemisedColumnNames<-gsub(pattern = "[\\.]",replacement = "", x = itemisedColumnNames)

  #add label suffix to label column names
  columnNames[colsValueLabels] <- paste0(columnNames[colsValueLabels],"l")

  #case and length
  columnNames<-substr(tolower(columnNames),start = (nchar(columnNames)-maxVariableNameLength + 1), stop=(nchar(columnNames))) #take the tail rather than the head to accommodate tail numbering
  itemisedColumnNames<-substr(tolower(itemisedColumnNames),start = (nchar(itemisedColumnNames)-maxVariableNameLength + 1), stop=(nchar(itemisedColumnNames)))

  #leading numeric
  columnNames<-gsub(pattern = "^([0-9])",replacement = "n\\1", x = columnNames)

  #fix duplicate column naming - max 999 duplicate column names
  for(iCol in 1:length(columnNames)){
    #iCol <- 6
    cColName <- columnNames[iCol]
    cItem <-itemisedColumnNames[iCol]
    cCols <- columnNames[columnNames==cColName & itemisedColumnNames==cItem]

    if(length(cCols)>1){
      intermediateColName <- substring(cColName,first = 1, last = (maxVariableNameLength-3))
      for(iCCol in 1:length(cCols)){
        cCols[iCCol]<-paste0(intermediateColName,phenodbr::padStringLeft(as.character(iCCol),"0",3))
      }
      columnNames[columnNames==cColName]<-cCols
    }
  }


  if(!is.null(forceItem)) {
    columnNames<-paste0(forceItem,"_",columnNames)
  } else if(any(!is.na(itemisedColumnNames))) {
    columnNames<-ifelse(is.na(itemisedColumnNames),columnNames,paste0(itemisedColumnNames,"_",columnNames))
  }



  #return(list(colsSelect=colsSelect, names.new=columnNames, names.orig=columnNames.orig, colsValueLabels=colsValueLabels, valueLabelColumn=valueLabels$valueLabelColumn))
  return(data.frame(colsSelect=colsSelect, names.new=columnNames, names.orig=columnNames.orig, colsValueLabels=colsValueLabels, valueLabelColumn=valueLabels$valueLabelColumn))
}

asPgsqlTextArray=function(listToParse=c()){
  if(length(listToParse)<1) return("ARRAY[]::character varying(100)[]")
  modifiedList<-unlist(lapply(listToParse, function(x){paste0("'",x,"'")}))
  return(paste0("ARRAY[",paste(modifiedList,collapse = ","),"]"))
}

padStringLeft <- function(s,padding,targetLength){
  pl<-targetLength-nchar(s)
  if(pl>0) {paste0(c(rep(padding,pl),s),collapse = "")} else {s}
}


