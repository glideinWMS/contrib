T = NA
table_raw = NA
glm_model = NA

train_classifier <- function(){
  table_raw <<- read.csv("data/dataset_classification.csv")
  table_raw <<- data.frame(table_raw[,-1], row.names = table_raw[,1])
  # Remove rows with NA values
  table_raw <<- na.omit(table_raw)
  table_scaled = table_raw
  # Table standardization of numerical values
  table_scaled[1:8] = scale(table_raw[,1:8])
  table_scaled[,9:12] = table_raw[,9:12]
  table=data.frame(table_scaled[1:11])
  # Best classifier: GLM
  glm_model<<-glm(Failure ~., data=table, family=binomial)
}

predict_probability <- function(row){
  p=predict(glm_model,row,type="response")
  return(p)
}

train_Memory_predictor <- function(){
  df = read.csv("data/dataset_400k_hour.csv")
  # Select subset of the data (the most recent) in order to have a more current time series trend
  df = tail(df, n=200)
  df = data.frame(df[,-1], row.names = df[,1])
  # Set the attribute to analyze in this timeseries analysis
  df = df[,"TotalMemory"]
  T <<- ts(df, frequency=24)
  T.memhw <<- HoltWinters(T, seasonal="additive",l.start = 11352, b.start = 10580)
}

predict_memory <- function(){
  return(predict(T.memhw, 1))
}

train_CPU_predictor <- function(){
  df = read.csv("data/dataset_400k_hour.csv")
  # Select subset of the data (the most recent) in order to have a more current time series trend
  df = tail(df, n=200)
  df = data.frame(df[,-1], row.names = df[,1])
  # Set the attribute to analyze in this timeseries analysis
  df = df[,"TotalCpus"]
  T <<- ts(df, frequency=24)
  # Least square method
  T.cpuls <<- ar(T, method="ols")
}

predict_CPU <- function(){
  # Forecasting
  T.cpuls.pt <<- predict(T.cpuls, n.ahead = 1, se.fit = FALSE)
  return(T.cpuls.pt)
}

# Normalize distribution in the range [0,50]
normalize50 <- function(x, na.rm = TRUE) {
  return(((x- min(x)) /(max(x)-min(x)))*50)
}

score <- function(DiskUsage, TotalDisk, CpuCacheSize, TotalVirtualMemory, GLIDEIN_Job_Max_Time, TotalSlots, CpuIsBusy, SlotType){
  # CPU
  train_CPU_predictor()
  CPU = predict_CPU()
  # Memory
  train_Memory_predictor()
  Memory = predict_memory()
  # Failure probability
  train_classifier()
  row = data.frame(DiskUsage=DiskUsage,TotalCpus=CPU[1],TotalMemory=Memory[1],TotalDisk=TotalDisk,CpuCacheSize=CpuCacheSize,TotalVirtualMemory=TotalVirtualMemory,GLIDEIN_Job_Max_Time=GLIDEIN_Job_Max_Time,TotalSlots=TotalSlots,CpuIsBusy=CpuIsBusy,SlotType=SlotType)
  table = table_raw[1:10]
  # scale the new instance before classifying
  table[nrow(table) + 1,] <- row
  table_scaled = table
  table_scaled[,1:8] = scale(table[,1:8])
  table_scaled[,9:10] = table[,9:10]
  row_scaled=data.frame(tail(table_scaled, n=1))
  p = predict_probability(row_scaled)
  # scale the new instance's CPU
  CPUdist=table["TotalCpus"]
  CPUdist[nrow(CPUdist) + 1,] <- CPU[1]
  CPU = tail(normalize50(CPUdist), n=1)
  # scale the new instance's Memory
  Memorydist=table["TotalMemory"]
  Memorydist[nrow(Memorydist) + 1,] <- Memory[1]
  Memory = tail(normalize50(Memorydist), n=1)
  # score
  score = (CPU[1,"TotalCpus"]+Memory[1,"TotalMemory"])*(1-p)
  return(score)
}

# Example of call
# Specify DiskUsage, TotalDisk, CpuCacheSize, TotalVirtualMemory, GLIDEIN_Job_Max_Time, TotalSlots, CpuIsBusy, SlotType
score(DiskUsage=98,TotalDisk=1223453,CpuCacheSize=2345212,TotalVirtualMemory=23482,GLIDEIN_Job_Max_Time=1200,TotalSlots=5,CpuIsBusy=1,SlotType=0)





