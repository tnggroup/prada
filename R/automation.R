

#main function to run automated procedures
PgxrexClass$methods(
  automation=function(){

    initialise()

    command<-fcoalesce(contextDatabaseList$command,"about") #default to print and exit
    if(command=="about"){
      catl("PGX Rex - A software to work with pharmacogenomics. Please specify the command to run.")
    } else if(command=="automatic_routine"){

      #check for analysis to run
      analyses <- list.files(path = folderpathWork,pattern = "^.+\\.pgxrex\\.analysis\\.conf\\.txt$")
      if(length(analyses)>0){

        #TODO
      } else {
        #no analyses
        catl("There are no analyses to run. A template analysis config file has been created.")
        defaultAnalysiOptions <- list(
          `analysisId`="myAnalysis",
          `folderpathSequencing`="",
          `folderpathWFPGX`=""
        )
        if(!file.exists(file.path(folderpathWork,"TEMPLATE.pgxrex.analysis.conf.txt"))){
          dfOpts<-data.table(names=names(defaultAnalysiOptions), values=defaultAnalysiOptions)
          fwrite(dfOpts,"TEMPLATE.pgxrex.analysis.conf.txt",sep = "=",row.names = FALSE,col.names = FALSE)
          catl("A template analysis config file has been created.")
        }

      }


    } else {
      catl("Misspecified command. You specified the command: ",command)
    }

  }
)

#set up before running automation procedure(s)
PgxrexClass$methods(
  initialise=function(){
    #contextDatabaseList<-pgxrexObj$contextDatabaseList
    catl("***PGX Rex automated routines***")
    if(any(names(contextDatabaseList)=="ncores")) {
      nThread <<- as.integer(contextDatabaseList["ncores"])
    }
    catl0("ncores=",nThread)

    if(any(names(contextDatabaseList)=="folderpathWork")) {
      if(nchar(contextDatabaseList["folderpathWork"])>0) folderpathWork <<-  normalizePath(file.path(contextDatabaseList["folderpathWork"]),mustWork = T)
    }
    catl0("folderpathWork=",folderpathWork)

    #connect database
    connectPgxrexDatabase(
      hostToUse=contextDatabaseList$pgxrexDbHost,
      usernameToUse=contextDatabaseList$pgxrexDbUsername,
      passwordToUse=contextDatabaseList$pgxrexDbPassword,
      dbnameToUse=contextDatabaseList$pgxrexDbName,
      portToUse=as.integer(contextDatabaseList$pgxrexDbPort),
      askForPassword=FALSE
    )
    catl("Database connected")

  }
)
