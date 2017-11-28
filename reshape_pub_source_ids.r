#### name: reshape_pub_source_ids.r
###  author: Matt Carson
##   creation date: 2017-6-13
#    last update: 2017-11-28
# 
# This script is for reshaping a list of Publication IDs and associated Proprietary IDs from literature databases from:
# 
# Pub_ID     Data_Source     Data_Source_ID
# 12345      Scopus          <...>
# 12345      Crossref        <...>
# 12345      PubMed          <...>
# .          .               .  
# .          .               .
# .          .               .
# 67890      Scopus          <...>
# 67890      Crossref        <...>
# 67890      PubMed          <...>     

# to:

# Pub_ID     Scopus          Crossref         PubMed
# 12345      <...>           <...>            <...>
# .          .               .                .
# .          .               .                .
# .          .               .                .
# 67890      <...>           <...>            <...>


#!/usr/bin/env Rscript


# If you want to run on the command line...
#
# Example: Rscript reshape_pub_source_ids.r -d "/My/Working/Directory" -i "input_file.csv" -o "output_file.csv"
#
require(docopt)

'Usage:
   reshape_pub_source_ids.r [-d <working directory> -i <input file> -o <output file>]

Options:
   -d Working directory
   -i Input file name
   -o Output file [default: reshaped_file.csv]

 ]' -> doc

opts <- docopt(doc)

WORKING_DIR <- opts$d
INPUT_FILE <- opts$i
OUTPUT_FILE <- opts$o

# If you want to run in RStudio...
#WORKING_DIR <- "dir_name"
#INPUT_FILE <- "input.csv"
#OUTPUT_FILE <- "reshaped_file.csv"

# Load libraries
library(reshape2)
library(dplyr) # just for glimpse

setwd(WORKING_DIR)

# Import .csv file from Elements reporting database
publications <- read.csv(INPUT_FILE, header=TRUE)

# Change ID to factor for summary
publications$Publication.ID <- as.factor(publications$Publication.ID)

# Examine and summarize the data frame                    
class(publications)
dim(publications)
names(publications)
str(publications)
glimpse(publications)
summary(publications)

# Create a df for reshaping
long_df <- data.frame("Group_Name" = publications$Group.Name,
	                  "Last_Name" = publications$Last.Name,
	                  "First_Name" = publications$First.Name,
	                  "Department" = publications$Department,
	                  "NetID" = publications$NetID,
	                  "Employee_ID" = publications$Employee_ID,
	                  "Scopus_AU-ID" = publications$Scopus.AU.ID,
	                  "Pub_ID" = publications$Publication.ID,
	                  "Data_Source_Proprietary_ID" = publications$Data.Source.Proprietary.ID,
	                  "Data_Source" = publications$Data.Source)

# Remove duplicate records
long_df_dedup <- unique(long_df)

# Reshape the long data frame to create a column for each "Data_Source_Proprietary_ID" type
# By setting idvar = c("NetID", "Pub_ID") instead of just "Pub_ID", reshape doesn't deduplicate pubs. It will include each researchers full list of pubs,
# even if multiple researchers in the file are authors of the same pub.
wide_df_dedup <- reshape(long_df_dedup, direction = "wide", idvar = c("NetID", "Pub_ID"), timevar= "Data_Source", v.names = "Data_Source_Proprietary_ID")

# If there are any Publication IDs with more than one instance of the same source ID (e.g., more than one Scopus or Web of Science ID),
# the reshape command above will send a warning like this...
#
# Warning message:
#	In reshapeWide(data, idvar = idvar, timevar = timevar, varying = varying,  :
#	multiple rows match for Data.Source=Scopus: first taken
#
# We can identify and count the number of Pub IDs with duplicatesas follows, changing 'Scopus' to whatever proprietary ID you want to examine...

# Create a new df with only Scopus IDs
long_df_scopus <- long_df_dedup[ which(long_df_dedup$publications.Data.Source =='Scopus'), ]

# List of Publication.IDs and the number of times they occurred in the Scopus list
long_df_scopus_duplicated <- data.frame(table(long_df_scopus$publications.Publication.ID))

# List of Publication IDs that have more than one Scopus ID
long_df_scopus_dup_count <- long_df_scopus_duplicated[long_df_scopus_duplicated$Freq > 1,]

# Sorted by most frequent occurrence
long_df_scopus_dup_count_sorted <- long_df_scopus_dup_count[with(long_df_scopus_dup_count, order(-Freq, Var1)), ]

# List of records with more than one Scopus ID
long_df_scopus_dup_IDs <- long_df_scopus[long_df_scopus$publications.Publication.ID %in% long_df_scopus_dup_count$Var1[long_df_scopus_dup_count$Freq > 1],]

# Rename the columns for readability
#
# Make sure the column order is correct before running
names(wide_df_dedup) = c("Group_Name", "Last_Name", "First_Name", "Department", "NetID", "Employee_ID", "Scopus_AU-ID", "Pub_ID", "Europe PubMed Central", "Crossref", "PubMed", "Scopus", "Web of Science", "Web of Science (Lite)")

# Export reshaped file as .csv
write.csv(wide_df_dedup, file = OUTPUT_FILE, row.names = FALSE)
