df = read.csv("../data/dataset_400k_hour.csv")

# Select subset of the data (the most recent) in order to have a more current time series trend
df = tail(df, n=200)
df = data.frame(df[,-1], row.names = df[,1])

# Set the attribute to analyze in this timeseries analysis
df = df[,"TotalCpus"]

# Exploration
T = ts(df)
start(T)
end(T)
plot(T, ylab="Average Total Memory", main="Series")
plot(diff(T), ylab="Series after removing trend")

# Auto-correlation function
acf(T,90)
acf(diff(T),50)

# Decomposition, set the frequency highlighted if present
T = ts(df, frequency=24)

# Additive
T.d = decompose(T)
plot(T.d)

# Multiplicative
T.dm = decompose(T, "multiplicative")
plot(T.dm)

# ACF comparison 
acf(na.omit(T.d$random),100, main="ACF Additive Decomposition")
acf(na.omit(T.dm$random),100, main="ACF Multiplicative Decomposition")

# Residues comparison

# Plot
T.dr = as.vector(na.omit(T.d$random))
plot(T.dr, pch = 20, main="Residues additive decomposition")
T.dmr = as.vector(na.omit(T.dm$random))
T.dmrl = log(T.dmr)
plot(T.dmrl, pch=20, main="Residues multiplicative decomposition")

# Non-explained variance
var(na.omit(T.dr))/var(T)
var(na.omit(T.dmrl))/var(na.omit(log(T)))

# Histogram
hist(T.dr, 20,freq=F, main="Histogram Additive Decomposition")
lines(density(na.omit(T.dr)),col="blue")
lines(sort(na.omit(T.dr)), dnorm(sort(na.omit(T.dr)),mean(na.omit(T.dr)),sd(na.omit(T.dr))),col="red")
hist(T.dmrl, 20,freq=F, main="Histogram Multiplicative Decomposition")
lines(density(na.omit(T.dmrl)),col="blue")
lines(sort(na.omit(T.dmrl)), dnorm(sort(na.omit(T.dmrl)),mean(na.omit(T.dmrl)),sd(na.omit(T.dmrl))),col="red")

# Q-Q Plot
qqnorm(T.dr, main="Q-Q Plot Additive Decomposition")
qqline(T.dr)
qqnorm(T.dmrl, main="Q-Q Plot Multiplicative Decomposition")
qqline(T.dmrl)

# Shapiro-Wilk test
shapiro.test(T.dr)
shapiro.test(T.dmrl)

# Std ACF
sd(acf(T.dr, plot = F)$acf)
sd(acf(T.dmr, plot = F)$acf)

# STL (Non-uniform seasonal decomposition)
plot(stl(7))

# Residues analysis STL (window = 7)
T.stl = stl(T,7)
T.stlr = T.stl$time.series[,3]
acf(na.omit(T.stlr),100)
plot(T.stlr, pch = 20, main="Residues STL")
var(T.stlr)/var(na.omit(T))
hist(T.stlr, 20,freq=F,main="Histogram STL")
lines(density(T.stlr),col="blue")
lines(sort(T.stlr), dnorm(sort(T.stlr),mean(T.stlr),sd(T.stlr)),col="red")
qqnorm(T.stlr, main="Q-Q Plot STL")
qqline(T.stlr)
shapiro.test(T.stlr)

# Residues analysis STL (window = 9)
T.stl = stl(T,9)
T.stlr = T.stl$time.series[,3]
acf(na.omit(T.stlr),100)
plot(T.stlr, pch = 20)
var(T.stlr)/var(na.omit(T))
hist(T.stlr, 20,freq=F)
lines(density(T.stlr),col="blue")
lines(sort(T.stlr), dnorm(sort(T.stlr),mean(T.stlr),sd(T.stlr)),col="red")
qqnorm(T.stlr)
qqline(T.stlr)
shapiro.test(T.stlr)
sd(acf(T.stlr, plot = F)$acf)

# Overlapping trend and seasonalty with the decompose ones
plot(decompose(T)$trend, col="blue")
lines(stl(T,7)$time.series[,2],col="red")
legend("bottomright",legend = c("Additive Decomposition", "STL"),col = c("blue","red"),lwd=2)
plot(decompose(T)$seasonal, col="blue")
lines(stl(T,7)$time.series[,1],col="red")
legend("bottomright",legend = c("Additive Decomposition", "STL"),col = c("blue","red"),lwd=2)

# HoltWinters method
T.hw = HoltWinters(T, seasonal="additive")
plot(T.hw)
T.hw$alpha
T.hw$beta
T.hw$gamma

# Initial conditions forecasting
x = 1:24
coefficients(lm(T[x]~x))
plot(HoltWinters(T, l.start = -0.73, b.start = 5.43))

# Exploring a range of parameters close to the ones provided by the software
# Set the correct range
for(alpha in 2:4){
  for(beta in 0:1){
    for(gamma in 5:9){
      plot(HoltWinters(T,alpha=alpha/10,beta=beta/10,gamma=gamma/10,l.start = -0.73, b.start = 5.43),xlab=paste("alpha:",alpha/10," beta:",beta/10," gamma:",gamma/10))
    }
  }
}

# Forecasting
plot(T.hw, predict(T.hw,24), main="Forecasting next day")
legend("bottomright",legend = c("Holt-Winters", "Original Series"),col = c("red","black"),lwd=2)

# Non-parametric uncertainty
T.hw.r = residuals(T.hw)
plot(T.hw, predict(T.hw, 24))
lines(predict(T.hw, 24) + quantile(T.hw.r, 0.05), col = "blue")
lines(predict(T.hw, 24) + quantile(T.hw.r, 0.95), col = "blue")

# Comparison with the multiplicative method
T.hwm = HoltWinters(T, seasonal="multiplicative")
ts.plot(T, T.hw$fitted[,1], T.hwm$fitted[,1],col=c("black","red","blue"))
legend("bottomright",legend = c("Holt-Winters","Multiplicative Holt-Winters", "Original Series"),col = c("red","blue","black"),lwd=2)

# Residues comparison
T.hw.r = residuals(T.hw)
T.hwm.r = residuals(T.hwm)

plot(T.hw.r, type = "p", pch = 20,main="Additive residues")
plot(T.hwm.r, type = "p", pch = 20,main="Multiplicative residues")
plot(T.hw$fitted[, 1], T.hw.r, pch = 20)
plot(T.hwm$fitted[, 1], T.hwm.r, pch = 20)

var(T.hw.r)/var(T)
var(T.hwm.r)/var(T)

acf(T.hw.r,100,main="ACF Additive residues")
acf(T.hwm.r,100,main="ACF Multiplicative residues")

hist(T.hw.r, 20, freq = F, main="Histogram Additive Residues")
lines(density(T.hw.r))
lines(sort(T.hw.r), dnorm(sort(T.hw.r), mean(T.hw.r), sd(T.hw.r)), col = "red")
hist(T.hwm.r, 20, freq = F, "Histogram Multiplicative Residues")
lines(density(T.hwm.r))
lines(sort(T.hwm.r), dnorm(sort(T.hwm.r), mean(T.hwm.r), sd(T.hwm.r)), col = "red")

qqnorm(T.hw.r, pch = 20,main="Q-Q Plot Additive Residues")
qqline(T.hw.r)
qqnorm(T.hwm.r, pch = 20,main="Q-Q Plot Multiplicative Residues")
qqline(T.hwm.r)

shapiro.test(T.hw.r)
shapiro.test(T.hwm.r)

# Autovalidation
l = length(T)
res.hw = rep(0, 24)
res.hwm = rep(0, 24)
j = 1
for (i in (l - 24):(l - 1)) {
  T_cv = ts(T[1:i], frequency = 24, start = c(1, 1))
  T.hw = HoltWinters(T_cv, seasonal = "additive")
  T.hwm = HoltWinters(T_cv, seasonal = "multiplicative")
  T.hw.p = predict(T.hw, 1)
  T.hwm.p = predict(T.hwm, 1)
  res.hw[j] = T.hw.p - T[i + 1]
  res.hwm[j] = T.hwm.p - T[i + 1]
  j = j + 1
}
sqrt(mean(res.hw^2))
sqrt(mean(res.hwm^2))
plot(res.hwm, type = "b", pch = 20, col = "green3", xlim=c(1,24), main="Comparison Forecasting Capability")
lines(res.hw, type = "b", pch = 20, col = "blue", xlim=c(1,24))
legend("bottomleft",legend = c("Additive Holt-Winters", "Multiplicative Holt-Winters"),col = c("blue","green3"),lwd=2)

# Regression methods
pacf(T,200, main="Partial Autocorrelation Function")
pacf(diff(T),200, main="Partial Autocorrelation Function without trend")

L = length(df)
l = 3  # number of lags in input
mnt = matrix(nrow = L - l, ncol = l + 1)
for (i in 1:(l + 1)) {
  mnt[, i] = df[i:(L - l - 1 + i)]
}
mnt <- data.frame(mnt)
nt.lm <- lm(X4 ~ ., data = mnt)  # X4 because 13 lags as input
summary(nt.lm)
nt.lm <- lm(X4 ~ . - X2, data = mnt)
summary(nt.lm)

# Yule-Walker Method
T.ar = ar(T)
T.ar
ts.plot(T, T - T.ar$resid, col = c("black", "red"), main="Yule-Walker")
legend("bottomleft",legend = c("Time Series", "Yule-Walker Forecasting"),col = c("black","red"),lwd=2)

# Forecasting
T.ar.pt = predict(T.ar, n.ahead = 24, se.fit = FALSE)
plot(T.ar.pt)
ts.plot(T,  T - T.ar$resid, T.ar.pt,col=c("black","red","red"), main="Yule-Walker Forecasting")
legend("bottomleft",legend = c("Yule-Walker", "Original Series"),col = c("red","black"),lwd=2)
T.ar.r= T.ar$resid

# Residues analysis
plot(T.ar.r, type = "p", pch = 20, main="Residues Yule-Walker")
T.ar.fitted = as.double(na.omit(T - T.ar$resid))
l = length(T)
v = var(T[2:l])
var(na.omit(T.ar$resid))/v
acf(na.omit(T.ar.r),100, main="Autocorrelation Residues Yule-Walker")
pacf(na.omit(T.ar.r),100,main="Partial Autocorrelation Residues Yule-Walker")
hist(na.omit(T.ar.r), 20, freq = F,main="Histogram  Residues Yule-Walker")
lines(density(na.omit(T.ar.r)))
lines(sort(na.omit(T.ar.r)), dnorm(sort(na.omit(T.ar.r)), mean(na.omit(T.ar.r)), sd(na.omit(T.ar.r))), col = "red")
qqnorm(T.ar.r, pch = 20, main="Q-Q Plot Residues Yule-Walker")
qqline(T.ar.r)
shapiro.test(T.ar.r)

# Least square method
T.ls = ar(T, method="ols")
T.ls
ts.plot(T, T - T.ls$resid, col = c("black", "red"), xlim=c(1.5,9), main="Least Squares Method")

# Forecasting
T.ls.pt = predict(T.ls, n.ahead = 24, se.fit = FALSE)
plot(T.ls.pt)
ts.plot(T, T - T.ls$resid, T.ls.pt,col=c("black","red","red"), main="Forecasting Least Squares Method")

# Non-parametric uncertainty
T.ls.r = as.double(na.omit(T.ls$resid))
y.max = max(T.ls.pt + quantile(T.ls.r, 0.975))
y.min = min(T.ls.pt + quantile(T.ls.r, 0.025))
ts.plot(T.ls.pt, ylim = c(y.min, y.max))

# Residues analysis
plot(T.ls.r, type = "p", pch = 20, main="Residues analysis LSM")
T.ls.fitted = as.double(na.omit(T - T.ls$resid))
plot(T.ls.fitted, T.ls.r, pch = 20)
var(T.ls.r)/var(T.ls.r + T.ls.fitted)
acf(T.ls.r,100, main="ACF LSM")
pacf(T.ls.r, 100,main="PACF LSM")
hist(T.ls.r, 20, freq = F, main="Histogram LSM")
lines(density(T.ls.r))
lines(sort(T.ls.r), dnorm(sort(T.ls.r), mean(T.ls.r), sd(T.ls.r)), col = "red")
qqnorm(T.ls.r, pch = 20, main="Q-Q Plot LSM")
qqline(T.ls.r)
shapiro.test(T.ls.r)

# Autovalidation
res.hw = rep(0, 24)
res.ls = rep(0, 24)
for (i in 1:24) {
  train = window(T, end = c(6, i))
  test = window(T, start = c(6, i + 1))
  res.hw[i] = predict(HoltWinters(train), 1)
  res.ls[i] = predict(ar(train, method="ols"), n.ahead = 1, se.fit = F)
}
test = window(T, start = c(6, 2))
sqrt(mean((test[1:24] - res.hw)^2))
sqrt(mean((test[1:24] - res.ls)^2))
plot(res.ls, type = "b", pch = 20, col = "green3", main="Comparison Forecasting Capability", xlab="Mese", ylim=c(0,400000))
lines(res.hw, type = "b", pch = 20, col = "blue")
legend("bottomleft",legend = c("Additive Holt-Winters", "Least Square Method"),col = c("blue","green"),lwd=2)

