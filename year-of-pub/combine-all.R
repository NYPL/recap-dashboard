#!/usr/local/bin//Rscript

library(data.table)
library(stringr)
library(magrittr)
library(libbib)


options(warn=1)
options(echo=TRUE)




###############
##### CUL #####
###############
cul <- fread("../computed-data/year-of-pub/cul-years.txt", na.strings=c("NA", ""),
             header=FALSE)
setnames(cul, c("bibid", "year"))
cul[, institution:="CUL"]
setcolorder(cul, c("institution", "bibid", "year"))




###############
##### PUL #####
###############
pul <- fread("../computed-data/year-of-pub/pul-years.txt", na.strings=c("NA", ""),
             header=FALSE)
setnames(pul, c("bibid", "year"))
pul[, institution:="PUL"]
setcolorder(pul, c("institution", "bibid", "year"))





################
##### NYPL #####
################
nypl <- fread("../computed-data/year-of-pub/nypl-years.txt", na.strings=c("NA", ""),
              header=FALSE)
setnames(nypl, c("bibid", "year"))
nypl[, institution:="NYPL"]
setcolorder(nypl, c("institution", "bibid", "year"))





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
comb[year>2018 | year < 1800, year:=NA]
comb[, valid_year_p:=!is.na(year)]

comb[, .N, .(institution, valid_year_p)] %>% dcast(institution ~ valid_year_p, value.var="N") -> validxtab
setnames(validxtab, c("institution", "invalid", "valid"))
validxtab[, numofbibs:=invalid+valid]
validxtab[, percent_valid:=round(valid/numofbibs, 2)]

validxtab %>% fwrite("../computed-data/year-of-pub/valid-year-xtab.txt", sep="\t")





set.seed(42)

NUMOFSAMPLES <- 5000
scul <- cul %>% dplyr::sample_n(NUMOFSAMPLES)
spul <- pul %>% dplyr::sample_n(NUMOFSAMPLES)
snypl <- nypl %>% dplyr::sample_n(NUMOFSAMPLES)

comb <- rbind(scul, spul, snypl)

comb[, .N]
comb[, .N, institution]
comb[year>2018 | year < 1800, year:=NA]
comb[, valid_year_p:=!is.na(year)]

onlyvalid <- comb[valid_year_p==TRUE, .(institution, year)]

onlyvalid %>% fwrite("../computed-data/year-of-pub/years-SAMPLE.txt", sep="\t")


