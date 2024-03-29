##################################################################################
# An R script to solve ODE's of a Susceptible Infected Recovered (SIR) model 
# I will add in our more complicated DE after further experimenting with the simplified model 
#I am also sharing this on my Github TravisWu so it will be readily available to all
require("sfsmisc")
source("sir_func.R")  # this file contains a function SIRfunc that calculates
# the derivatives of S Iw and Ir to time


#initial
npop = 1000 
I_0 = 1       # put one infected person in the population
S_0 = npop-I_0
R_0 = 0       # initially no one has recovered yet

# now the parameters of the model. 
# recovery is now gamma and the transmission
# rate as b or beta

vt = seq(0,100,1)  # let's determine the values of S,I and R at times in vt
gamma = 1/3        # approximate average recovery period of TB in days^{-1} 
R0    = 1.5        # R0 of a hypothetical strain of pandemic influenza 
beta  = R0*gamma   # transmission rate of TB is estimated by solving R0=beta/gamma for beta

vparameters = c(gamma=gamma,beta=beta)
inits = c(S=S_0,I=I_0,R=R_0)

sirmodel = as.data.frame(lsoda(inits, vt, SIRfunc, vparameters))
cat("The item names in the sirmodel object are:",names(sirmodel),"\n")


# now let's plot the results

par(mfrow=c(2,2))                             # divides the plot area into two up and two down
mult.fig(4,main="SIR model of pandemic influenza with R0=1.5") # this is from the sfsmisc package that also
# divides into two up and two down, *and*
# prints a title at the top

plot(sirmodel$time,sirmodel$I/npop,type="l",xlab="time",ylab="fraction infected",ylim=c(0,0.1),lwd=3,col=4,main="Infected")
n=length(sirmodel$time)
lines(sirmodel$time[2:n],-diff(sirmodel$S/npop),type="l",lwd=3,col=2)
legend("topright",legend=c("total infected (prevalence)","mutated"),bty="n",lwd=3,col=c(4,2))

plot(sirmodel$time,sirmodel$S/npop,type="l",xlab="time",ylab="fraction susceptible",ylim=c(0.4,1),lwd=3,main="Susceptible")
tind = which.min(abs(sirmodel$S/npop-1/R0)) # find the index at which S/N is equal to 1/R0
lines(c(sirmodel$time[tind],sirmodel$time[tind]),c(-1000,1000),col=3,lwd=3)
#legend("bottomleft",legend=c("time at which S=1/R0"),bty="n",lwd=3,col=c(3),cex=0.7)

#plot(sirmodel$time,log(sirmodel$I/npop),type="l",xlab="time",ylab="log(fraction infected)",lwd=3,col=4,main="log(Infected)")
text(40,-14,"Initial\n exponential\n rise",cex=0.7)
lines(c(sirmodel$time[tind],sirmodel$time[tind]),c(-1000,1000),col=3,lwd=3)
legend("topleft",legend=c("time at which S=1/R0","log(Infected)"),bty="n",lwd=3,col=c(3,4),cex=0.7)


# output the final size
# first solve for the final fraction of suscetibles at time=infinity
# using the final size relationship in 
# www.fields.utoronto.ca/programs/scientific/10-11/drugresistance/emergence/fred1.pdf 

dsinf = 0.00001
vsinf = seq(0,1-dsinf,dsinf)
sinf_predicted = vsinf[which.min(abs(R0*(1-vsinf)+log(vsinf)-log(S_0/npop)))]  # numerically solve -log(sinf) = R0*(1-sinf)
cat("The final fraction of susceptibles at the end of the epidemic from the model simulation is ",min(sirmodel$S)/npop,"\n")
cat("The final fraction of susceptibles at the end of the epidemic predicted by the final size relation is ",sinf_predicted,"\n")




