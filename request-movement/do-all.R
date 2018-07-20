#!/usr/local/bin//Rscript --vanilla

# options(warn=1)
options(echo=TRUE)


library(data.table)
library(magrittr)
library(lubridate)



##
xwalk <- fread("../support/customer-code-xwalk.txt")
setkey(xwalk, thekey)

get_place <- function(x){
  places <- data.table(thekey=x)
  setindex(places, "thekey")
  results <- xwalk[places]
  return(results[,place])
}
##



xactions <- fread("../ian-data/xactions.csv", colClasses="character", header=TRUE,
                  col.names=c("order_owner", "item_barcode", "item_owner",
                              "req_date", "ship_date", "requestor",
                              "stopp", "status", "order_type"))

xactions[, .N, order_type]
# THERE ARE OTHER ORDER TYPES THAN JUST RETRIEVAL
# BUT LETS ONLY USE RETRIEVAL
xactions <- xactions[order_type=="RETRIEVE"]


xactions[, `:=`(item_barcode=NULL, requestor=NULL,
                order_type=NULL, stopp=NULL)]
xactions[, ship_date:=mdy(ship_date)]
xactions[, req_date:=mdy(req_date)]


# now join with xwalk
xactions[, order_owner:=get_place(order_owner)]
xactions[, item_owner:=get_place(item_owner)]

xactions[, .N, status]
# THERE ARE OTHER STATUSES BESIDES "IN"
# BUT LET'S JUST USE "IN" FOR NOW
xactions <- xactions[status=="IN"]





###################################
###                             ###
###      MOVEMENT ANALYSIS      ###
###                             ###
###################################

xactions[, .N, .(order_owner, item_owner)][!is.na(item_owner)] -> movement
setcolorder(movement, c("item_owner", "order_owner", "N"))
movement
# very few of columbia's items go to the NYPL

movement[item_owner=="NYPL", percentage_incoming_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[item_owner=="CUL", percentage_incoming_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[item_owner=="PUL", percentage_incoming_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[item_owner=="HUL", percentage_incoming_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[order_owner=="NYPL", percentage_outgoing_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[order_owner=="CUL", percentage_outgoing_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[order_owner=="PUL", percentage_outgoing_requests:=round(N/sum(N, na.rm=TRUE), 2)]
movement[order_owner=="HUL", percentage_outgoing_requests:=round(N/sum(N, na.rm=TRUE), 2)]


# idea: control for the number of orders each institution has

movement %>% fwrite("../computed-data/request-movement/all-movement.txt",
                    sep="\t")
