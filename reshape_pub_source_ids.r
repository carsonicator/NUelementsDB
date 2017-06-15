#### name: reshape_pub_source_ids.r
###  author: Matt Carson
##   creation date: 2017-6-13
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

# Load libraries
library(reshape2)
library(dplyr) # just for glimpse

# Import .csv file from Elements reporting database
long_df <- read.csv("file.csv", header=TRUE)

# Change ID to factor for summary
long_df$Publication.ID <- as.factor(long_df$Publication.ID)
long_df$User.ID <-as.factor(long_df$User.ID)

# Examine and summarize the data frame                    
class(long_df)
dim(long_df)
names(long_df)
str(long_df)
glimpse(long_df)
summary(long_df)

# Get rid of ID and group name columns (we don't need them in the reshaped file)
long_df$User.ID <- NULL
long_df$name <- NULL
long_df$doi <- NULL

# Remove duplicate records
long_df_dedup <- unique(long_df)

# Reshape the long data frame to create a column for each Proprietary.ID type
wide_df_dedup <- reshape(long_df_dedup, direction = "wide", idvar = "Publication.ID", timevar= "Data.Source", v.names = "Data.Source.Proprietary.ID")

# If there are any Publication IDs with more than one instance of the same source ID (e.g., more than one Scopus ID),
# the reshape command above will send a warning like this...
#
# Warning message:
#	In reshapeWide(data, idvar = idvar, timevar = timevar, varying = varying,  :
#	multiple rows match for Data.Source=Scopus: first taken
#
# We can identify and count the number of Pub IDs as follows...

# Create a new df with only Scopus IDs
long_df_scopus <- long_df_dedup[ which(long_df_dedup$Data.Source =='Scopus'), ]

# List of Publication.IDs and the number of times they occurred in the Scopus list
long_df_scopus_duplicated <- data.frame(table(long_df_scopus$Publication.ID))

# List of Publication IDs that have more than one Scopus ID
long_df_scopus_dup_count <- long_df_scopus_duplicated[long_df_scopus_duplicated$Freq > 1,]

# Sorted by most frequent occurrence
long_df_scopus_dup_count_sorted <- long_df_scopus_dup_count[with(long_df_scopus_dup_count, order(-Freq, Var1)), ]

# List of records with more than one Scopus ID
long_df_scopus_dup_IDs <- long_df_scopus[long_df_scopus$Publication.ID %in% long_df_scopus_dup_count$Var1[long_df_scopus_dup_count$Freq > 1],]

# Export reshaped file as .csv
write.csv(wide_df_dedup, file = "reshaped_file.csv", row.names = FALSE)
