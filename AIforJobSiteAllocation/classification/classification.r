table_raw = read.csv("../data/dataset_classification.csv")
table_raw <- data.frame(table_raw[,-1], row.names = table_raw[,1])

# Remove rows with NA values
table_raw = na.omit(table_raw)

# Table standardization of numerical values
table_raw[,1:8] = scale(table_raw[,1:8])
table=data.frame(table_raw[1:11])
table_with_sites=table_raw

# Plot with sampled dataset for simplicity
table_sampled=data.frame(table[sample(nrow(table), 5000), ])
plot(table_sampled, pch=20, col=c("indianred3","sandybrown"))
barplot(table(table$Failure), col=c("indianred3","sandybrown"))

source("s2_cmroc.r")

# Classic linear regression, re-writing classes as +-1
tablelr = table
tablelr$Failure = 2*tablelr$Failure-1
tablelr.lm=lm(Failure~., data = tablelr)
sum((predict(tablelr.lm)>0) ==(tablelr$Failure > 0))/length(tablelr$Failure)
response = (tablelr$Failure>0)
predictor = (predict(tablelr.lm)>0)
s2_confusion(response,predictor)

# Logistic Regression
table.glm =glm(Failure ~., data=table, family=binomial)
table.glm.p = predict(table.glm, type="response")
sum((table.glm.p>0.5)==(table$Failure>0.5))/length(table$Failure)
s2_confusion(table$Failure, table.glm.p)
table.glm.roc = s2_roc(table$Failure, table.glm.p) 
s2_roc.plot(table.glm.roc)
s2_auc(table.glm.roc)

# Linear Discriminant Analysis
library(MASS)
table.lda=lda(Failure ~.,data=table,prior=c(1/2,1/2))
table.lda.values=predict(table.lda)
table.lda.post = table.lda.values$posterior[,2] 
sum(table$Failure  == table.lda.values$class)/length(table$Failure )
s2_confusion(table$Failure, table.lda.post)
table.lda.roc = s2_roc(table$Failure, table.lda.post) 
s2_roc.plot(table.lda.roc)
s2_auc(table.lda.roc)

# Quadratic Discriminant Analysis
table.qda=qda(Failure ~.,data=table,prior=c(1/2,1/2))
table.qda.values=predict(table.qda)
table.qda.post = table.qda.values$posterior[,2] 
sum(table$Failure  == table.qda.values$class)/length(table$Failure )
s2_confusion(table$Failure, table.qda.post)
table.qda.roc = s2_roc(table$Failure, table.qda.post) 
s2_roc.plot(table.qda.roc)
s2_auc(table.qda.roc)

# ROC curves
s2_roc.plot(table.qda.roc, col="green3")
s2_roc.lines(table.lda.roc, col="blue")
s2_roc.lines(table.glm.roc, col="red")
legend("bottomright",legend = c("glm", "lda", "qda"),col = c("red", "blue", "green3"),lwd=2)

# Models' robustness analysis
# Switching the class of continuously subsequent indexes in the training set in order to train models with wrong data
# and testing the same models on the correct dataset as test set.
# Testing in this way the robustness of the models
old_table=table
table=table_sampled
tablelr=table_sampled
idx=sample(1000,1000)
acclm=rep(0,1000)
accglm=rep(0,1000)
acclda=rep(0,1000)
accqda=rep(0,1000)
for(i in 1:1000){
  tablef=table
  tableflr=tablelr
  tableflr$Failure[idx[1:i]]=-tableflr$Failure[idx[1:i]]
  for(j in 1:i){
    if(tablef$Failure[idx[j]]==0)
      tablef$Failure[idx[j]] = 1
    else
      tablef$Failure[idx[j]] = 0
  }
  tableflr.lm=lm(Failure~.,data=tableflr)
  acclm[i]=sum((predict(tableflr.lm)>0)==(tablelr$Failure>0))/length(tablelr$Failure)
  tablef.glm =glm(Failure ~., data=tablef, family=binomial)
  accglm[i] = sum((predict(tablef.glm)>0.5) ==(table$Failure>0.5))/length(table$Failure)
  tablef.lda=lda(Failure ~.,data=tablef,prior=c(1/2,1/2))
  tablef.lda.values=predict(tablef.lda)
  tablef.lda.post = tablef.lda.values$posterior[,2]
  acclda[i] = sum(table$Failure  == tablef.lda.values$class)/length(table$Failure )
  tablef.qda=qda(Failure ~.,data=tablef,prior=c(1/2,1/2))
  tablef.qda.values=predict(tablef.qda)
  tablef.qda.post = tablef.qda.values$posterior[,2]
  accqda[i] = sum(table$Failure  == tablef.qda.values$class)/length(table$Failure )
  print(i)
}
plot(accglm,type="l", col="red",xlab="Values changed", ylab="Accuracy", ylim=c(0.12,0.9))
lines(acclda,type="l", col="blue")
lines(accqda,type="l", col="green3")
legend("bottomleft",legend = c("lm", "glm", "lda", "qda"),col = c("black", "red", "blue", "green3"),lwd=2)
table=old_table

# Autovalidation
l=length(table$Failure)
acc=matrix(0,50,4)
spec=matrix(0,50,4)
n = 50
for(i in 1:n){
  idx=sample(l,n)
  tablecv=table[-idx,]
  tablelrcv=table[-idx,]
  tablelrcv.lm=lm(Failure~., data = tablelrcv)
  predictor=(predict(tablelrcv.lm,table[idx,])>0)
  response=(tablelr$Failure[idx]>0)
  conf = s2_pconfusion(response,predictor)
  spec[i,1] = conf$`actual 0`[2]/sum(conf$`actual 0`)
  acc[i,1]=sum(predictor==response)/n
  table.glm=glm(Failure~.,family=binomial,data=tablecv)
  table.glm.p=predict(table.glm,table[idx,],type="response")
  conf = s2_confusion(table$Failure[idx], table.glm.p)
  spec[i,2] = conf$`actual 0`[2]/sum(conf$`actual 0`)
  acc[i,2]=sum((table.glm.p>0.5)==(table$Failure[idx]>0.5))/n
  table.lda=lda(Failure~.,data=tablecv)
  table.lda.p=predict(table.lda,table[idx,])$posterior[,2]
  conf = s2_confusion(table$Failure, table.lda.post)
  spec[i,3] = conf$`actual 0`[2]/sum(conf$`actual 0`)
  acc[i,3]=sum((table.lda.p>0.5)==(table$Failure[idx]>0.5))/n
  table.qda=qda(Failure~.,data=tablecv)
  table.qda.p=predict(table.qda,table[idx,])$posterior[,2]
  conf = s2_confusion(table$Failure, table.qda.post)
  spec[i,4] = conf$`actual 0`[2]/sum(conf$`actual 0`)
  acc[i,4]=sum((table.qda.p>0.5)==(table$Failure[idx]>0.5))/n
}
# Linear Regression
mean(acc[,1])
sd(acc[,1])
hist(acc[,1])
# Logistic Regression
mean(acc[,2])
sd(acc[,2])
hist(acc[,2])
# Linear Discriminant Analysis
mean(acc[,3])
sd(acc[,3])
hist(acc[,3])
# Quadratic Discriminant Analysis
mean(acc[,4])
sd(acc[,4])
hist(acc[,4])

# Autovalidation on the different sites
i = 1
skipped = 0
acc=matrix(0,length(unique(table_with_sites$Site)),4)
for(site in unique(table_with_sites$Site)){
  print(site)
  # considering only sites which have enough samples
  if(length(which(table_with_sites$Site==site)) < nrow(table_with_sites)/100){
    print(length(which(table_with_sites$Site==site)))
    print("Skipping..") 
    skipped=skipped+1
    next
  }
  l=length(table$Failure[table_with_sites$Site == site])
  tableSite=table_with_sites[table_with_sites$Site == site,1:11]
  n = nrow(tableSite)
  
  # Linear Regression
  predictor=(predict(tablelr.lm,tableSite)>0)
  response=(tableSite$Failure>0)
  conf = s2_pconfusion(response,predictor)
  acc[i,1]=sum(predictor==response)/n
  
  # Logistic Regression
  table.glm.p=predict(table.glm,tableSite,type="response")
  conf = s2_confusion(tableSite$Failure, table.glm.p)
  acc[i,2]=sum((table.glm.p>0.5)==(tableSite$Failure>0.5))/n
  
  # Linear Discriminant Analysis
  table.lda.p=predict(table.lda,tableSite)$posterior[,2]
  conf = s2_confusion(tableSite$Failure, table.lda.p)
  acc[i,3]=sum((table.lda.p>0.5)==(tableSite$Failure>0.5))/n

  # Quadratic Discriminant Analysis
  table.qda.p=predict(table.qda,tableSite)$posterior[,2]
  conf = s2_confusion(tableSite$Failure, table.qda.p)
  acc[i,4]=sum((table.qda.p>0.5)==(tableSite$Failure>0.5))/n
  i = i + 1
}

acc = head(acc, -skipped)
# Linear Regression
mean(acc[,1])
sd(acc[,1])
hist(acc[,1])
# Logistic Regression
mean(acc[,2])
sd(acc[,2])
hist(acc[,2])
# Linear Discriminant Analysis
mean(acc[,3])
sd(acc[,3])
hist(acc[,3])
# Quadratic Discriminant Analysis
mean(acc[,4])
sd(acc[,4])
hist(acc[,4])
  
# Trade-off between accuracy and sensitivity (preferred wrt specificity seen our application)
l=length(table$Failure)
acc=matrix(0,50,3)
sens=matrix(0,50,3)
i = 1
for(p in seq(0.5,0.99,0.01)){
  table.lda=lda(Failure~.,data=table)
  table.lda.p=predict(table.lda,table)$posterior[,2]
  conf = s2_confusion(table$Failure, table.lda.post,p)
  sens[i,1] = conf$`actual 1`[1]/sum(conf$`actual 1`)
  acc[i,1]=sum((table.lda.p>p)==(table$Failure>p))/length(table$Failure)
  table.qda=qda(Failure~.,data=tablecv)
  table.qda.p=predict(table.qda,table)$posterior[,2]
  conf = s2_confusion(table$Failure, table.qda.post,p)
  sens[i,2] = conf$`actual 1`[1]/sum(conf$`actual 1`)
  acc[i,2]=sum((table.qda.p>p)==(table$Failure>p))/length(table$Failure)
  table.glm=glm(Failure~.,family=binomial,data=tablecv)
  table.glm.p=predict(table.glm,table,type="response")
  conf = s2_confusion(table$Failure, table.glm.p,p)
  sens[i,3] = conf$`actual 1`[1]/sum(conf$`actual 1`)
  acc[i,3]=sum((table.glm.p>p)==(table$Failure>p))/length(table$Failure)
  i = i + 1
}
plot(acc[,1],xaxt = "n",type="l", col="blue",xlab="Probability Threshold", ylab="Accuracy and Sensitivity",ylim=c(0.6,1))
lines(acc[,2],type="l", col="green3")
lines(acc[,3],type="l", col="red")
lines(spec[,1],type="l", col="blue",lty=9)
lines(spec[,2],type="l", col="green3",lty=9)
lines(spec[,3],type="l", col="red", lty=9)
legend("bottomleft",legend = c("glm", "lda", "qda"),col = c("red", "blue", "green3"),lwd=2)
axis(1, at=1:50, labels=seq(0.5,0.99,0.01))

# Best classifier: GLB with probability threshold = 0.68
table.glm =glm(Failure ~., data=table, family=binomial)
table.glm.p = predict(table.glm, type="response")
conf = s2_confusion(table$Failure, table.glm.p+0.68-0.5)
sens = conf$`actual 1`[1]/sum(conf$`actual 1`)
acc = sum((table.glm.p>0.68)==(table$Failure>0.68))/length(table$Failure)

# Plot classified instances on sampled dataset for simplicity
table_sampled.glm =glm(Failure ~., data=table_sampled, family=binomial)
table_sampled.glm.p = predict(table_sampled.glm, type="response")
plot(table_sampled.glm$fitted.values, pch=8, ylab="Probability Output",col=as.numeric(table_sampled$Failure)+9)
points(table_sampled.glm$fitted.values, col=as.numeric(table_sampled.glm.p > 0.68)+9)
legend("bottomleft",legend = c("Non Failures", "Failures"),col = c("black","red"), lwd=2)

