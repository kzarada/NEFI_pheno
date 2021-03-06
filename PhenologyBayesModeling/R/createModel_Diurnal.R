library("rjags")
library("runjags")
library("MODISTools")
#library("doParallel")

createBayesModel.Diurnal <- function(siteName,data){
  print("entered model")
  nchain <-  5
  #inits <- list()
  #init.mus <- createInits(data,"SH")
  #print(init.mus)
  # for(i in 1:5){
  #   inits[[i]] <- list(a=rnorm(1,0.0009,0.0003),c=rnorm(1,mean(sort(data$y,decreasing = TRUE)[1:2]),0.05),k=rnorm(1,12,0.3))
  # }
  #data$mean.c <- 0.75
  #data$p.c <- 1/(0.05**2)
  data$alpha.c <- 2
  data$beta.c <- 1.5
  data$s1 <- 0.001 #0.7
  data$s2 <- 0.00001 #0.08
  #data$p.Tran <- 1/(1**2)
  #data$p.b <- 1/(1**2)
  #data$mean.TranL <- 0# 7.5
  #data$mean.bL <- -1.5
  #data$mean.TranR <- 25#17.5
  #data$mean.bR <- 1.8
  data$mean.a <- 0.0009
  data$p.a <- 0.0003
  data$mean.k <- 12
  data$p.k <- 1/(1**2)
  data$n <- length(data$x)
  print("finished defining data")
  DB_model_MM <- "
  model{
  ##priors
  #TranL ~ dnorm(mean.TranL,p.Tran) ##S for spring
  #bL ~ dnorm(mean.bL,p.b)
  #TranR ~ dnorm(mean.TranR,p.Tran)  ##F for fall/autumn
  #bR ~ dnorm(mean.bR,p.b)
  a ~ dnorm(mean.a,p.a) I(0,)
  c ~ dbeta(alpha.c,beta.c)
  k ~ dnorm(mean.k,p.k)
  prec ~ dgamma(s1,s2)
  alp ~ dunif(1,100)
  bet ~ dunif(1,100)
  p.cloud ~ dunif(0,1)

  for(i in 1:n){
  muL[i] <- -a * exp(-1 * (x[i]-k)) + c + a
  muR[i] <- -a * exp((x[i]-k)) + c + a

  f[i] <- ifelse(x[i]>k,muR[i],muL[i])   #change point process model

  y[i] ~ dnorm(mu[i],prec)   ##data model
  is.cloudy[i] ~ dbern(p.cloud)
  trans[i] ~ dbeta(alp,bet)
  mu[i] <- is.cloudy[i] * trans[i]*f[i] + (1-is.cloudy[i]) * f[i]

  }
  }
  "

  j.model   <- jags.model(file = textConnection(DB_model_MM),
                          data = data,
                          n.chains=nchain)
  return(j.model)

}
