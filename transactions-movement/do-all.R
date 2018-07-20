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


# WHY ARE THERE ORDERS WHERE THE ORDER OWNER AND THE ITEM
# OWNER ARE THE SAME?
#
#
#
#
# ####################################
# ###                              ###
# ###     TIME SERIES ANALYSIS     ###
# ###                              ###
# ####################################
#
# library(ggplot2)
# library(forecast)
# library(scales)
#
# #############################
# #### USING THE SHIP DATE ####
# #############################
#
# setorder(xactions, ship_date)
# xactions[, .(num_of_in_xactions=.N), ship_date] -> bydate
#
# inds <- seq(as.Date("2017-06-26"), as.Date("2018-07-18"), by = "day")
# somets <- ts(bydate[, num_of_in_xactions],
#              start=c(2017, as.numeric(format(inds[1], "%j"))),
#              frequency=365)
#
# ggplot(bydate, aes(x=ship_date, y=num_of_in_xactions)) +
#   geom_line() + xlab("Date") + ylab("number of IN transactions shipped") +
#   ggtitle("Time series of number of IN transactions shipped at ReCAP") +
#   theme(plot.title = element_text(hjust = 0.5)) +
#   ggsave("./plots/time-series-on-in-transactions-shipped.png")
#
#
# # WHAT ARE THOSE HUGE SPIKES ABOUT
# bdc <- copy(bydate)
# bdc[, dow:=weekdays(ship_date)]
# bdc[, themonth:=lubridate::month(ship_date, label=TRUE)]
# setorder(bdc, -num_of_in_xactions)
# bdc[, num_of_in_xactions] %>% summary
# bdc[num_of_in_xactions > 700, .N, dow]
# bdc %>% fwrite("./tmp.txt", sep="\t")
# # 73% of transactions over 700 are on Tuesday or Friday
# # 50% of transactions over 700 are on Tuesday
#
#
#
# bydate[order(-num_of_in_xactions), ]
#
# ggplot(bydate, aes(num_of_in_xactions)) +
#   geom_density(fill="pink") + ylab("") + xlab("number of IN transactions shipped") +
#   theme(axis.title.y=element_blank(),
#         axis.ticks=element_blank(),
#         axis.text.y=element_blank(),
#         plot.title = element_text(hjust = 0.5)) +
#   ggtitle("Distribution of number of daily IN transactions shipped") +
#   ggsave("./plots/distribution-of-number-of-daily-ship-transactions.png")
#
#
#
#
# ################################
# #### USING THE REQUEST DATE ####
# ################################
#
# setorder(xactions, req_date)
# xactions[, .(num_of_in_xactions=.N), req_date] -> bydate
#
# inds <- seq(as.Date("2017-06-26"), as.Date("2018-07-17"), by = "day")
# somets <- ts(bydate[, num_of_in_xactions],
#              start=c(2017, as.numeric(format(inds[1], "%j"))),
#              frequency=365)
#
# ggplot(bydate, aes(x=req_date, y=num_of_in_xactions)) +
#   geom_line() + xlab("Date") + ylab("number of IN transactions requested") +
#   ggtitle("Time series of number of IN transactions requested at ReCAP") +
#   theme(plot.title = element_text(hjust = 0.5))
#   ggsave("./plots/time-series-on-in-transactions-requested.png")
#
#
# # WHAT ARE THOSE HUGE SPIKES ABOUT
# bdc <- copy(bydate)
# bdc[, dow:=weekdays(req_date)]
# bdc[, themonth:=lubridate::month(req_date, label=TRUE)]
# setorder(bdc, -num_of_in_xactions)
# bdc
# bdc[, num_of_in_xactions] %>% summary
# bdc[num_of_in_xactions > 1000, .N, dow]
# bdc %>% fwrite("./tmp.txt", sep="\t")
# # over 50% of transactions over 1000 are on Monday
#
#
#
# bydate[order(-num_of_in_xactions), ]
#
# ggplot(bydate, aes(num_of_in_xactions)) +
#   geom_density(fill="pink") + ylab("") + xlab("number of IN transactions requested") +
#   theme(axis.title.y=element_blank(),
#         axis.ticks=element_blank(),
#         axis.text.y=element_blank(),
#         plot.title = element_text(hjust = 0.5)) +
#   ggtitle("Distribution of number of daily IN transactions requested") +
#   ggsave("./plots/distribution-of-number-of-daily-request-transactions.png")
#

####################################
####################################
####################################



###################################
###                             ###
###      MOVEMENT ANALYSIS      ###
###                             ###
###################################

xactions[, .N, .(order_owner, item_owner)][!is.na(item_owner) & N>999] -> movement
setcolorder(movement, c("item_owner", "order_owner", "N"))
movement

movement[item_owner=="NYPL"]
         , .N, order_owner]


# idea: control for the number of orders each institution has
