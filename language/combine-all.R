#!/usr/local/bin//Rscript

library(data.table)
library(stringr)
library(magrittr)
library(libbib)


options(warn=1)
options(echo=TRUE)


# langxwalk <- fread("../support/langcodexwalk.txt", header=TRUE)
# langxwalk[, V3:=NULL]
# langxwalk[, V4:=NULL]
# setkey(langxwalk, langcode)


###############
##### CUL #####
###############
cul <- fread("../computed-data/language/cul-languages.txt", na.strings=c("NA", ""),
             header=FALSE)
setnames(cul, c("bibid", "langcode"))
cul[, institution:="CUL"]
setcolorder(cul, c("institution", "bibid", "langcode"))




###############
##### PUL #####
###############
pul <- fread("../computed-data/language/pul-languages.txt", na.strings=c("NA", ""),
             header=FALSE)
setnames(pul, c("bibid", "langcode"))
pul[, institution:="PUL"]
setcolorder(pul, c("institution", "bibid", "langcode"))





################
##### NYPL #####
################
nypl <- fread("../computed-data/language/nypl-languages.txt", na.strings=c("NA", ""),
              header=FALSE)
setnames(nypl, c("bibid", "langcode"))
nypl[, institution:="NYPL"]
setcolorder(nypl, c("institution", "bibid", "langcode"))



###################
##### HARVARD #####
###################
# harvard <- fread("../computed-data/lc-call-numbers/harvard-lc-calls.txt", na.strings=c("NA", ""))
# setnames(harvard, c("bibid", "lccall"))
# harvard[, institution:="HUL"]
# setcolorder(harvard, c("institution", "bibid", "lccall"))





comb <- rbind(cul, pul, nypl)

comb[, .N]
comb[, .N, institution]
comb[, valid_lang_p:=!is.na(langcode)]

comb[, .N, .(institution, valid_lang_p)] %>% dcast(institution ~ valid_lang_p, value.var="N") -> validxtab
setnames(validxtab, c("institution", "invalid", "valid"))
validxtab[, numofbibs:=invalid+valid]
validxtab[, percent_valid:=round(valid/numofbibs, 2)]

validxtab %>% fwrite("../computed-data/language/valid-lang-xtab.txt", sep="\t")



onlyvalid <- comb[valid_lang_p==TRUE, .(institution, langcode)]


this <- onlyvalid[, .N, .(institution, langcode)]


this[this[, sum(N), institution], on="institution"] -> this
setnames(this, "V1", "totalinst")
this[, perc:=round(N/totalinst, 2)]

this %>% fwrite("../computed-data/language/languages.txt", sep="\t")





