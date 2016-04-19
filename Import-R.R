#This Script reads the data from relevant csv files containing the data that feeds the dashboard
  
  

#Following Line sets the local directory out of which R will work, look for scripts, save files, etc

setwd("C:/Users/Upamanyu/Documents/R Codes")

#Following lines loand relevant packages for the execution of this script.
#NOTE: Packages can be attached at any time, before the execution of relevant commands.

library(rio) #This package is a wrapper for different commands that import data from different formats
library(magrittr)#This package enables the use of the %>% operator, a pipe via which commands can be chained together
library(dplyr)#This package enables some of the most data wrangling commands
library(stringr)#This package enables specific string functions
library(lubridate)#This package enables ease of operations with dates and times

rm(list=ls()) #Removes any pre-existing files from R environment

member3<-import("C:/Users/Upamanyu/Documents/DSS Data/Member3.csv", stringsAsFactors=FALSE)#rio package in action
names(member3)<-tolower(names(member3))#Names=Variables. Thus all var names to lowercase
member3<-arrange(member3, member_id)#R's sort command, out of dplyr package

cbo<-import("C:/Users/Upamanyu/Documents/DSS Data/cbo.csv", stringsAsFactors=FALSE)
names(cbo)<-tolower(names(cbo))
cbo<-mutate(cbo, created_on=ifelse(updated_on!="", updated_on, created_on))%>%#mutate=All purpose dplyr command signalling creation/replacement of new/existins variable
  mutate(created_on=substring(created_on, 1, 8))%>%#pipe in action; created_on, conditionally replaced in last line, now undergoes a parsing
  mutate(entry_date_cbo=dmy(created_on))%>%
  select(-(created_by:registration_date))#select; dplyr command to select variables

cbo_mapping<-import("C:/Users/Upamanyu/Documents/DSS Data/cbo mapping.csv", stringsAsFactors=FALSE)
names(cbo_mapping)<-tolower(names(cbo_mapping))
cbo_mapping<-select(cbo_mapping, id:parent_cbo_id)

district<-import("C:/Users/Upamanyu/Documents/DSS Data/district.csv", stringsAsFactors=FALSE)
names(district)<-tolower(names(district))
district<-select(district, district_id:state_id)%>%
  mutate(district_name=str_trim(district_name))%>%#The only use of stringr package, str_trim: to remove leading/trailing space
  mutate(district_name=toupper(district_name))%>%
  mutate(district_name=ifelse(district_name=="KAIMUR (BHABUA)", "KAIMUR", district_name))

districtmapping<-import("C:/Users/Upamanyu/Documents/DSS Data/districtmapping.csv", stringsAsFactors=FALSE)
names(districtmapping)<-tolower(names(districtmapping))
districtmapping<-group_by(districtmapping, district_id)%>%#group_by: dplyr command to allow operations by groups in all subsequent commands till ungroup()
  mutate(scheme_id2=max(scheme_id))%>%
  mutate(scheme=ifelse(scheme_id2==3, "BRLP", 
                       ifelse(scheme_id2==6, "NRLP", "NRLM")))%>%
  ungroup()%>%
  distinct(district_id)%>%#distinct: dplyr command to drop duplicates by variables provided
  select(district_id, scheme)

district<-full_join(district, districtmapping)#full_join: dplyr join command
rm(districtmapping)

block<-import("C:/Users/Upamanyu/Documents/DSS Data/block.csv", stringsAsFactors=FALSE)
names(block)<-tolower(names(block))
block<-select(block, block_id:state_id)%>%
  mutate(block_name=str_trim(block_name))%>%
  mutate(block_name=toupper(block_name))%>%
  mutate(block_name=ifelse(block_name=="CHANAN*", "CHANAN", block_name))%>%
  mutate(block_name=ifelse(block_name=="DINAPUR-CUM-", "DINAPUR", block_name))

panchayat<-import("C:/Users/Upamanyu/Documents/DSS Data/panchayat.csv", stringsAsFactors=FALSE)
names(panchayat)<-tolower(names(panchayat))
panchayat<-select(panchayat, state_id:panchayat_name)%>%
  mutate(panchayat_name=str_trim(panchayat_name))%>%
  mutate(panchayat_name=toupper(panchayat_name))

village<-import("C:/Users/Upamanyu/Documents/DSS Data/village.csv", stringsAsFactors=FALSE)
names(village)<-tolower(names(village))
village<-select(village, village_id:block_id, panchayat_id)%>%
  mutate(village_name=str_trim(village_name))%>%
  mutate(village_name=toupper(village_name))

ac_master<-import("C:/Users/Upamanyu/Documents/DSS Data/ac master.csv", stringsAsFactors=FALSE)
names(ac_master)<-tolower(names(ac_master))

loan_detail<-import("C:/Users/Upamanyu/Documents/DSS Data/loan detail.csv", stringsAsFactors=FALSE)
names(loan_detail)<-tolower(names(loan_detail))
loan_detail<-select(loan_detail, -(record_updated_on:record_created_by), -interest_amount, -till_date)#variables with '-' sign in front get dropped from selection

repayment<-import("C:/Users/Upamanyu/Documents/DSS Data/repayment.csv", stringsAsFactors=FALSE)
names(repayment)<-tolower(names(repayment))

#NOTE: We are about to do some basic data manipulation with the next import of adjustment vouchers
#Both adjustment and ajusted vouchers are in voucher master table. In adjusted voucher table, they sit side by side
#So one way of getting rid of adjustment vouchers is to remove both sets from voucher master
#To do that, one way is to create a column of adjustment and adjusted vouchers, join with voucher master & drop matching records

avoucher<-import("C:/Users/Upamanyu/Documents/DSS Data/avoucher.csv", stringsAsFactors=FALSE)
names(avoucher)<-tolower(names(avoucher))
avoucher<-select(avoucher, -(created_by:created_on))%>%
  mutate(voucher_id=as.numeric(1)) #Creating dummy voucher_id
avoucher<-avoucher[rep((1:nrow(avoucher)), 2),]%>%#Duplicating original table
  arrange(adjusted_voucher_id, adjustment_voucher_id)%>%
  group_by(adjusted_voucher_id, adjustment_voucher_id)%>%
  mutate(id=seq_along(adjustment_voucher_id))%>%#Creating a sequence of 1 & 2 for each adjusted vucher and adjustment voucher pair, duplicated earlier
  mutate(voucher_id=ifelse(id==1, adjusted_voucher_id, adjustment_voucher_id))%>%#If sequence=1, replacing dummy by adjusted voucher, if 2, by adjustment voucher
  ungroup()%>%
  select(voucher_id, id)#single column of adjustment and adjusted vouchers created, for easy join with voucher master

transactions<-import("C:/Users/Upamanyu/Documents/DSS Data/transactions.csv", stringsAsFactors=FALSE)
names(transactions)<-tolower(names(transactions))

voucher_master<-import("C:/Users/Upamanyu/Documents/DSS Data/voucher master.csv", stringsAsFactors=FALSE)
names(voucher_master)<-tolower(names(voucher_master))
voucher_master<-mutate(voucher_master, date_voucher=dmy(voucher_date))%>%
  select(-voucher_date)%>%
  rename(voucher_date=date_voucher)%>%
  mutate(voucher_entry_date=dmy(substr(created_on, 1, 8)))%>%
  select(-created_by, -created_on, -remarks)


save.image(file="Imported.RData") #Saves all objects in environment as an image, for ready loading later

#End import codes. These are out of manual imports. If ODBC connections are used, the import commands are not needed
#Instead we'll use the sqlfetch commands after setting up our dsn. But we'll need the basic data cleaning & manipulation commands after the initial R objects are created.


