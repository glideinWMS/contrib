table_original = read.csv("../data/raw_dataset400k.csv")
table <- data.frame(table_original)

# Remove rows with NA values
table = na.omit(table)

# Convert LastUpdate format to %Y-%m-%d %H:%M:%s
table[,"LastUpdate"]=as.POSIXct(as.numeric(as.character(table$LastUpdate)), format='%Y-%m-%d %H:%M:%s', origin = "1970-01-01")
table = na.omit(table)

# Select the attributes needed
final_table=table[,c("LastUpdate","GLIDEIN_Site","DiskUsage", "jobStarts", "TotalLoadAvg", "TotalCpus", "TotalJobRunTime", "TotalMemory", "TotalDisk", "TotalCondorLoadAvg", "CondorLoadAvg", "CpusUsage", "ConsoleIdle", "CpuCacheSize", "TotalVirtualMemory", "Glidein_JOB_Max_Time", "CpuBusyTime", TotalLoadAvg)]

# Maintain only the rows with not-null site 
final_table=final_table[!(final_table$GLIDEIN_Site==""),]

# Get year, min, and hour truncation formats
final_table$ydate=date(final_table$LastUpdate)
final_table=final_table[!(final_table$ydate=="1969-12-31"),] # remove not-valid data
final_table$mdate=cut(as.POSIXct(final_table$LastUpdate, format="%d/%m/%Y %H:%M:%S"), breaks="min") 
final_table$hdate=cut(as.POSIXct(final_table$LastUpdate, format="%d/%m/%Y %H:%M:%S"), breaks="hour") 

final_site_table=final_table
na.omit(final_site_table)
final_site_table$TotalCpus = as.numeric(as.character(final_site_table$TotalCpus))
final_site_table$TotalMemory = as.numeric(as.character(final_site_table$TotalMemory))
final_site_table$TotalDisk = as.numeric(as.character(final_site_table$TotalDisk))

# Aggregate by calculating the mean and grouping by hour
final_site_table2 = aggregate(cbind(final_site_table$TotalCpus,final_site_table$TotalMemory,final_site_table$TotalDisk),list(final_site_table$hdate), mean)

df <- data.frame(final_site_table2[,2:4], row.names = final_site_table2[,1])
colnames(df)<-c("TotalCpus","TotalMemory","TotalDisk")
write.csv(df,"../data/dataset_time_series_analysis.csv")
