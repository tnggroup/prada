
#install package with
#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')

PgxrexClass <- setRefClass("Pgxrex",
                                           fields = list(
                                             pgxrexApplicationDAO = "ANY",
                                             paddingPRSAnchorBp = "numeric",
                                             paddingGeneBp = "numeric",
                                             applicationCoverageRegions = 'ANY',
                                             applicationCoverageRegionsFiltered = 'ANY',
                                             applicationCoverageRegionsFilteredPaddedStrands = 'ANY',

                                             #analysis settings
                                             nThread = "numeric",
                                             analysisSettingsList = 'ANY',
                                             sampleSettingsList = 'ANY',
                                             analysisMeta = 'ANY',
                                             sampleMeta = 'ANY'
                                           ),
                                           methods = list
                                           (
                                             #this is the constructor as per convention
                                             initialize=function()
                                             {

                                               #defaults
                                               pgxrexApplicationDAO <<- NULL

                                               paddingPRSAnchorBp<<-10000
                                               paddingGeneBp<<-10000

                                               applicationCoverageRegions <<- NULL
                                               applicationCoverageRegionsFiltered <<- NULL
                                               applicationCoverageRegionsFilteredPaddedStrands <<- NULL

                                               nThread <<- 6
                                               analysisSettingsList<<-c()
                                               sampleSettingsList<<-c()

                                               analysisMeta<<-as.data.frame(matrix(data = NA,nrow = 0,ncol = 0))
                                               sampleMeta<<-as.data.frame(matrix(data = NA,nrow = 0,ncol = 0))


                                             }
                                           )
)

# we can add more methods after creating the ref class (but not more fields!)

#this is standardised and hard-coded - replace the dao with another for a custom connection
#connectPgxrexDatabase("tng_prada_system")
PgxrexClass$methods(
  connectPgxrexDatabase=function(hostToUse=NULL,usernameToUse=NULL,passwordToUse=NULL,dbnameToUse=NULL,portToUse=NULL){
    if(is.null(passwordToUse)) passwordToUse <- rstudioapi::askForPassword(prompt = c("Enter database password for user: ",usernameToUse))
    if(is.null(hostToUse)) hostToUse <- pgxrexCentralDBDefaultHost
    if(is.null(dbnameToUse)) dbnameToUse <- pgxrexCentralDBDefaultDbName
    if(is.null(usernameToUse)) usernameToUse <- pgxrexCentralDBDefaultUsername
    if(is.null(portToUse)) portToUse <- pgxrexCentralDBDefaultPort
    pgxrexApplicationDAO <<- pgxrex::PgxrexPgDatabaseUtilityClass(host=hostToUse, dbname=dbnameToUse, user=usernameToUse, port=portToUse, password= passwordToUse)
  }
)



