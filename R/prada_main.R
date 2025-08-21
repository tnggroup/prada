


PradaClass <- setRefClass("Prada",
                                           fields = list(
                                             pradaApplicationDAO = "ANY",
                                             paddingPRSAnchorBp = "numeric",
                                             paddingGeneBp = "numeric",
                                             applicationCoverageRegions = 'ANY',
                                             applicationCoverageRegionsFiltered = 'ANY',
                                             applicationCoverageRegionsFilteredPaddedStrands = 'ANY',

                                             #analysis settings
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
                                               paddingPRSAnchorBp<<-10000
                                               paddingGeneBp<<-10000

                                               analysisSettingsList<<-c()
                                               sampleSettingsList<<-c()

                                               analysisMeta<<-as.data.frame(matrix(data = NA,nrow = 0,ncol = 0))
                                               sampleMeta<<-as.data.frame(matrix(data = NA,nrow = 0,ncol = 0))


                                             }
                                           )
)

# we can add more methods after creating the ref class (but not more fields!)

#this is standardised and hard-coded - replace the dao with another for a custom connection
#connectPradaDatabase("tng_prada_system")
PradaClass$methods(
  connectPradaDatabase=function(hostToUse=NULL,usernameToUse=NULL,passwordToUse=NULL,dbnameToUse=NULL,portToUse=NULL){
    if(is.null(passwordToUse)) passwordToUse <- rstudioapi::askForPassword(prompt = c("Enter database password for user: ",usernameToUse))
    if(is.null(hostToUse)) hostToUse <- pradaCentralDBDefaultHost
    if(is.null(dbnameToUse)) dbnameToUse <- pradaCentralDBDefaultDbName
    if(is.null(usernameToUse)) usernameToUse <- pradaCentralDBDefaultUsername
    if(is.null(portToUse)) portToUse <- pradaCentralDBDefaultPort
    pradaApplicationDAO <<- prada::PradaPgDatabaseUtilityClass(host=hostToUse, dbname=dbnameToUse, user=usernameToUse, port=portToUse, password= passwordToUse)
  }
)



