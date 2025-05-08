


PradaPgDatabaseUtilityClass <- setRefClass("PradaPgDatabaseUtility",
                                             fields = list(
                                               dbname = "character",
                                               user = "character",
                                               host = "character",
                                               port = "numeric",
                                               statusCode = "numeric",
                                               cacheDb = "ANY",
                                               savedCachePath = "character",
                                               connection = "ANY"
                                             ),
                                             methods = list
                                             (
                                               #this is the constructor as per convention
                                               initialize=function(dbname, host, user, port, password, doCache=T, askForPassword=F)
                                               {

                                                 dbname <<- dbname
                                                 host <<- host
                                                 user <<- user
                                                 port <<- port
                                                 if(askForPassword){
                                                   connection <<- dbConnect(RPostgres::Postgres(),
                                                                            dbname = dbname,
                                                                            host = host,
                                                                            port = port,
                                                                            user = user,
                                                                            password = rstudioapi::askForPassword(prompt = "Enter database password for specified user."))
                                                 } else {
                                                   connection <<- dbConnect(RPostgres::Postgres(),
                                                             dbname = dbname,
                                                             host = host,
                                                             port = port,
                                                             user = user,
                                                             password = password)
                                                 }
                                                 savedCachePath <<- "./pgDatabaseUtilityCache.Rds"

                                                 if(doCache==T) cache()
                                               }
                                             )
)

# we can add more methods after creating the ref class (but not more fields!)

# cache frequently and rarely changing data from the server
PradaPgDatabaseUtilityClass$methods(
  cache=function(refresh=F, write=T, cacheSaveFilePath=NULL){
    if(is.null(cacheSaveFilePath)){
      cacheSaveFilePath <- savedCachePath
    }

    if(file.exists(cacheSaveFilePath) && refresh == F){
      cacheDb <<- readRDS(file=cacheSaveFilePath)
    } else {
      cacheDb <<- c()

      #store cache data here

      if(write) {
        saveRDS(cacheDb,file = cacheSaveFilePath)
        savedCachePath <<- cacheSaveFilePath
      }

    }
  }
)

#this is not injection safe
PradaPgDatabaseUtilityClass$methods(
  setSearchPath=function(searchPath){
    #searchPath<-"dat_cohort"
    c <- paste0("SET search_path TO ",paste(searchPath, sep = ","))
    #cat(c)
    q <- dbSendQuery(connection, c)
  }
)

PradaPgDatabaseUtilityClass$methods(
  setSearchPath.standard=function(){
    setSearchPath("\"$user\", public")
  }
)

PradaPgDatabaseUtilityClass$methods(
  getPGTempSchema=function(cohort){
    q <- dbSendQuery(connection,
                     "SELECT nspname FROM pg_namespace WHERE oid  =  pg_my_temp_schema()")
    res<-dbFetch(q)
    dbClearResult(q)
    if(length(res)>0) return(res[[1]]) else return(NA_character_)
  }
)



PradaPgDatabaseUtilityClass$methods(
  getPradaChromosome=function(){
    q <- dbSendQuery(connection,
                     "SELECT * FROM prada.chromosome")
    res<-dbFetch(q)
    dbClearResult(q)
    if(length(res)>0) return(res[[1]]) else return(NA_character_)
  }
)


#should be used with care as it passes the data by value rather than reference
PradaPgDatabaseUtilityClass$methods(
  importDataAsTable=function(name,df,temporary = T){

    if(!is.null(df)){
      if(dbExistsTable(conn = connection, name = name)) dbRemoveTable(conn = connection, name = name, temporary= temporary)
      dbCreateTable(conn = connection, name = name, fields = df, temporary = temporary)
      dbAppendTable(conn = connection, name = name, value = df)
    }

  }
)
