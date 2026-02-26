#merge snomed codes from different sources

library(data.table)

folderpath.project<-"/Users/jakz/Documents/work_rstudio/prada"

dDataMining_yuhao<-fread(file.path(folderpath.project,"data","gdppr_codes_bundle","snomed_codes_output.csv"))
setkeyv(dDataMining_yuhao,cols = c("snomed_ct_id","search_term"))


