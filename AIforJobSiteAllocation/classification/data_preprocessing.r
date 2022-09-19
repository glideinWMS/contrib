table_original = read.csv("../data/raw_dataset400k.csv")
table <- data.frame(table_original)

# Remove rows with NA values
table = na.omit(table)

# Select the attributes needed
final_table=table[,c("DiskUsage", "TotalCpus", "TotalMemory", "TotalDisk", "CpuCacheSize",
                     "TotalVirtualMemory", "GLIDEIN_Job_Max_Time", 
                     "TotalSlots", "CpuIsBusy", "SlotType", "GLIDEIN_PS_OK", "GLIDEIN_Site")]

# Maintain only the rows with not-null values of the attributes needed
final_table=final_table[!(final_table$DiskUsage==""),]
final_table=final_table[!(final_table$TotalCpus==""),]
final_table=final_table[!(final_table$TotalMemory==""),]
final_table=final_table[!(final_table$TotalDisk==""),]
final_table=final_table[!(final_table$CpuCacheSize==""),]
final_table=final_table[!(final_table$TotalVirtualMemory==""),]
final_table=final_table[!(final_table$GLIDEIN_Job_Max_Time==""),]
final_table=final_table[!(final_table$TotalSlots==""),]
final_table=final_table[!(final_table$CpuIsBusy==""),]
final_table=final_table[!(final_table$SlotType==""),]
final_table=final_table[!(final_table$GLIDEIN_Site==""),]
final_table=final_table[!(final_table$GLIDEIN_PS_OK==""),]
# Maintain only the rows with valid values
final_table=final_table[!(final_table$GLIDEIN_PS_OK!="true" & final_table$GLIDEIN_PS_OK!="false"),]

# Convert binary values in numeric format
final_table$GLIDEIN_PS_OK[final_table$GLIDEIN_PS_OK=="false"] <- 1
final_table$GLIDEIN_PS_OK[final_table$GLIDEIN_PS_OK=="true"] <- 0
final_table$SlotType[final_table$SlotType=="Static"] <- 1
final_table$SlotType[final_table$SlotType=="Dynamic"] <- 0
final_table$CpuIsBusy[final_table$CpuIsBusy=="false"] <- 0
final_table$CpuIsBusy[final_table$CpuIsBusy=="true"] <- 1

# Rename attributes
colnames(final_table)[11] <- "Failure"
colnames(final_table)[12] <- "Site"
final_table[1:11] <- sapply(final_table[1:11], as.numeric)
write.csv(final_table,"../data/dataset_classification.csv")
