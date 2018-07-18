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
cul <- fread("../computed-data/lc-call-numbers/cul-lc-calls.txt", na.strings=c("NA", ""))
setnames(cul, c("bibid", "lccall", "other"))
cul[is.na(lccall), lccall:=other]
cul[, other:=NULL]
cul[, institution:="CUL"]
setcolorder(cul, c("institution", "bibid", "lccall"))




###############
##### PUL #####
###############
pul <- fread("../computed-data/lc-call-numbers/pul-lc-calls.txt", na.strings=c("NA", ""))
setnames(pul, c("bibid", "lccall", "other"))
pul[is.na(lccall), lccall:=other]
pul[, other:=NULL]
pul[, institution:="PUL"]
setcolorder(pul, c("institution", "bibid", "lccall"))




################
##### NYPL #####
################
nypl <- fread("../computed-data/lc-call-numbers/nypl-lc-calls.txt", na.strings=c("NA", ""))
setnames(nypl, c("bibid", "lccall", "other", "another"))
nypl[is.na(other), other:=another]
nypl[is.na(lccall), lccall:=other]
nypl[, other:=NULL]
nypl[, another:=NULL]
nypl[, institution:="NYPL"]
setcolorder(nypl, c("institution", "bibid", "lccall"))






###################
##### HARVARD #####
###################
harvard <- fread("../computed-data/lc-call-numbers/harvard-lc-calls.txt", na.strings=c("NA", ""))
setnames(harvard, c("bibid", "lccall"))
harvard[, institution:="HUL"]
setcolorder(harvard, c("institution", "bibid", "lccall"))





comb <- rbind(cul, pul, nypl, harvard)

comb[, .N]
comb[, .N, institution]
comb[, valid_lc_p:=is_valid_lc_call(lccall)]
comb[is.na(valid_lc_p), valid_lc_p:=FALSE]

comb[, .N, .(institution, valid_lc_p)] %>% dcast(institution ~ valid_lc_p, value.var="N") -> validxtab
setnames(validxtab, c("institution", "invalid", "valid"))
validxtab[, numofbibs:=invalid+valid]
validxtab[, percent_valid:=round(valid/numofbibs, 2)]

validxtab %>% fwrite("../computed-data/lc-call-numbers/valid-lc-call-xtab.txt", sep="\t")



onlyvalid <- comb[valid_lc_p==TRUE, .(institution, lccall)]

onlyvalid[, broad_subject_letters:=get_lc_broad_letter(lccall)]
onlyvalid[, subject_letters:=get_lc_subject_letters(lccall)]


broads <- onlyvalid[, .N, .(institution, broad_subject_letters)]
broads[broads[, sum(N), institution], on="institution"] -> broads
setnames(broads, "V1", "totalinst")
broads[, perc:=round(N/totalinst, 2)]

broads[, broad_subject:=get_lc_call_subject(broad_subject_letters, already.parsed=TRUE)]

broads %>% fwrite("../computed-data/lc-call-numbers/broad-subjects.txt", sep="\t")





# not broad

sbroads <- broads[, .(institution, broad_subject_letters, N_in_broad=N, totalinst)]

tmp <- onlyvalid[, .(N_in_subject=.N), .(institution, broad_subject_letters, subject_letters)]


subjects <- sbroads[tmp, on=.(institution, broad_subject_letters)]

subjects[, percent_in_category:=round(N_in_subject/N_in_broad, 2)]
subjects[, percent_in_institution:=round(N_in_subject/N_in_broad, 2)]








