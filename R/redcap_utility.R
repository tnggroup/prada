
#base_url<-"https://redcap.medsci.ox.ac.uk/api/"
PgxrexRedcapUtilityClass <- setRefClass("PgxrexRedcapUtility",
                                            fields = list(
                                              base_url = "character",
                                              apiToken = "character"

                                            ),
                                            methods = list
                                            (
                                              #this is the constructor as per convention
                                              initialize=function(base_url, apiToken, askForapiToken=F)
                                              {
                                                base_url <<- base_url
                                                apiToken <<- apiToken
                                                if(askForapiToken) apiToken <<- rstudioapi::askForPassword(prompt = "Enter API token for specified user.")





                                              }
                                            )
)


# Export Records
PgxrexRedcapUtilityClass$methods(
  exportRecords=function(vRecords=NULL, vForms=NULL){

    #browser()
    recordsArg<-ifelse(is.null(vRecords),
                       '',
                       jsonlite::toJSON(vRecords)
    )
    formsArg<- ifelse(is.null(vForms),
                      '',
                      jsonlite::toJSON(vForms)
    )
    #formsArg<-"concomitant_medication_log"
    resp <- req |>
      req_headers(Accept = "application/json") |>
      req_body_form(
        token=apiToken,
        content='record',
        format='json',
        type='eav', #'flat'
        records = recordsArg,
        forms = formsArg
      ) |>
      req_perform()
    #resp_raw(resp)
    return(resp)
    #return(resp_body_json(resp))
    #https://rguides.dev/guides/httr2-and-apis/#json-responses


  }
)
