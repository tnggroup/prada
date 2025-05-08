


PradaClass <- setRefClass("Prada",
                                           fields = list(
                                             pradaApplicationDAO = "ANY",
                                             paddingPRSAnchorBp = "numeric",
                                             paddingGeneBp = "numeric"
                                           ),
                                           methods = list
                                           (
                                             #this is the constructor as per convention
                                             initialize=function()
                                             {
                                               #defaults
                                               paddingPRSAnchorBp=10000
                                               paddingGeneBp=10000
                                             }
                                           )
)

# we can add more methods after creating the ref class (but not more fields!)

#this is standardised and hard-coded - replace the dao with another for a custom connection
#connectPradaDatabase("tng_prada_system")
PradaClass$methods(
  connectPradaDatabase=function(usernameToUse){
    #usernameToUse<-"tng_prada_system"
    cinfo <- c()
    cinfo$pw <- rstudioapi::askForPassword(prompt = c("Enter database password for user: ",usernameToUse))
    cinfo$host <- pradaCentralDBDefaultHost
    cinfo$dbname <- pradaCentralDBDefaultDbName
    cinfo$user <- usernameToUse
    cinfo$port <- pradaCentralDBDefaultPort
    pradaApplicationDAO <<- prada::PradaPgDatabaseUtilityClass(host=cinfo$host, dbname=cinfo$dbname, user=cinfo$user, port=cinfo$port, password= cinfo$pw)
  }
)



