#PGX Rex CLI

library(optparse)
library(pgxrex)
library(data.table)

#setwd(utils::getSrcDirectory(function(){})[1]) #force wd in case of previous changes

#command line options
optionParser <- OptionParser()

optionParser <- add_option(
  object = optionParser,
  opt_str = c("-c", "--command"),
  type = "character",
  default = "automatic_routine",
  help = "Command to run."
)

optionParser <- add_option(
  object = optionParser,
  opt_str = c("-s", "--settingsFilePath"),
  type = "character",
  default = "settings.conf.txt",
  help = "Path to settings-file."
)

optionParser <- add_option(
  object = optionParser,
  opt_str = c("-p", "--protectedFilePath"),
  type = "character",
  default = "protected.conf.txt",
  help = "Path to protected settings-file (passwords etc.)"
)

parsedCLOptions <- parse_args(optionParser)
parsedCFOptions <- list(
  `pgxrexId`="mySite",
  `pgxrexDbHost`="localhost",
  `pgxrexDbUsername`="tng_prada_system",
  `pgxrexDbName`="prada_local",
  `pgxrexDbPort`=65432,
  `redcapBaseUrl`="https://redcap.medsci.ox.ac.uk/api/",
  `ncores`=6,
  `folderpathWork`="" #default to current folder
  ) #defaults


if(file.exists(parsedCLOptions$settingsFilePath)){
  parsedCFOptions <- pgxrex::readMetadata(filePath = parsedCLOptions$settingsFilePath)
} else {
  if(!file.exists("settings.conf.txt")){
    dfOpts<-data.table(names=names(parsedCFOptions), values=parsedCFOptions)
    fwrite(dfOpts,"settings.conf.txt",sep = "=",row.names = FALSE,col.names = FALSE)
  }
}


parsedPCFOptions <- list(
  `pgxrexDbPassword`="XXX_replace_with_password_XXX",
  `redcapApiToken`="XXX_replace_with_API_token_XXX"
) #defaults


if(file.exists(parsedCLOptions$protectedFilePath)){
  parsedPCFOptions <- pgxrex::readMetadata(filePath = parsedCLOptions$protectedFilePath)
} else {
  if(!file.exists("protected.conf.txt")){
    dfOpts<-data.table(names=names(parsedPCFOptions), values=parsedPCFOptions)
    fwrite(dfOpts,"protected.conf.txt",sep = "=",row.names = FALSE,col.names = FALSE)
  }
}


#unify settings/options
parsedOptions<-parsedCLOptions
parsedOptions[names(parsedCFOptions)]<-parsedCFOptions
parsedOptions[names(parsedPCFOptions)]<-parsedPCFOptions

PgxrexClass$trace("automation") #DEBUG

pgxrexObj<-PgxrexClass()

pgxrexObj$testFlag.offline<-TRUE #TEST

pgxrexObj$contextDatabaseList<-parsedOptions #set context options
#pgxrexObj$trace("automation")
pgxrexObj$automation()





