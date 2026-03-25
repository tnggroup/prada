#merge snomed codes from different sources

library(data.table)

folderpath.project<-"/Users/jakz/Documents/work_rstudio/prada"

dDataMining_yuhao<-fread(file.path(folderpath.project,"data","gdppr_codes_bundle","snomed_codes_output.csv"))
setkeyv(dDataMining_yuhao,cols = c("snomed_ct_id","search_term"))

uCodesDatamining<-unique(unlist(dDataMining_yuhao$snomed_ct_id))
length(uCodesDatamining)

dOpencodelistsDemographic_jz<-fread(file.path(folderpath.project,"data","gdppr_codes_bundle","johanzvrskovec-demographic-as-encountered-at-the-gp-for-llc-nhsd_gdppr_snomed-1e9ddb7f.csv"))
setkeyv(dOpencodelistsDemographic_jz,cols = c("code"))

dOpencodelistsBehaviour_jz<-fread(file.path(folderpath.project,"data","gdppr_codes_bundle","johanzvrskovec-behaviour-gp-for-llc-nhsd-gdppr-snomed-37ad4eb4-definition.csv"))
setkeyv(dOpencodelistsBehaviour_jz,cols = c("code"))

uCodesOpecodelists<-unique(unlist(c(dOpencodelistsDemographic_jz$code,dOpencodelistsBehaviour_jz$code)))
length(uCodesOpecodelists)

sum(uCodesOpecodelists %in% uCodesDatamining)

cCodesAll<-unique(unlist(c(uCodesOpecodelists,uCodesDatamining)))
length(cCodesAll)

dfAllCodes<-data.frame(row=1:length(cCodesAll),code=cCodesAll)
setDT(dfAllCodes)
setkeyv(dfAllCodes,cols = c("row","code"))

dfAllCodes[dOpencodelistsBehaviour_jz,on = c(code='code'), c('name'):=list(i.term)]
nrow(dfAllCodes[!is.na(name),])
dfAllCodes[dOpencodelistsDemographic_jz,on = c(code='code'), c('name'):=list(i.term)]
nrow(dfAllCodes[!is.na(name),])
dfAllCodes[dDataMining_yuhao,on = c(code='snomed_ct_id'), c('name'):=list(i.fsn)]
nrow(dfAllCodes[!is.na(name),])
nrow(dfAllCodes)
fwrite(dfAllCodes[,.(code,name)],file = file.path(folderpath.project,"data","gdppr_codes_bundle","codes-for-application-out.tsv.gz"),sep = "\t",quote = TRUE,compressLevel = 9)
