# *************************************************** *********************************
#*********Qingmin Zhang writes this code ****************
#*********for utilising the coxPh model for data*********
#* 2023-3-31-
#*
#**********************************
# aidssi2, analysising the relationship between aid death and age and CCR5.

# install.packages(c("survival", "survminer", "gt", "conflicted","tidyverse","glue","webshot2"))

#library(ggplot2)
if(!require(ggplot2))install.packages(ggplot2)
if(!require(ggpubr))install.packages(ggpubr)
if(!require("survminer"))install.packages("survminer")
if(!require("survival"))install.packages("survival")
if(!require(mstate))install.packages(mstate)
if(!require(gt))install.packages(gt)


data("aidssi2")
print(aidssi2)
# To save the aidssi2 as .xls frormat
patnr = data.frame(aidssi2$patnr)
entry.time = data.frame(aidssi2$entry.time)
aids.time = data.frame(aidssi2$aids.time)
aids.stat = data.frame(aidssi2$aids.stat)

si.time = data.frame(aidssi2$si.time)
si.stat = data.frame(aidssi2$si.stat)

death.time = data.frame(aidssi2$death.time)
death.stat = data.frame(aidssi2$death.stat)
age.inf = data.frame(aidssi2$age.inf)

x_start = 0
x_end = max(si.time)+0.5
ccr5 = data.frame(aidssi2$ccr5)
aidssi2 = cbind(patnr,
                entry.time,
                aids.time,
                aids.stat,
                si.time,
                si.stat,
                death.time,
                death.stat,
                age.inf,
                ccr5)
names(aidssi2) <- c("patnr",
                    "entry.time",
                    "aids.time",
                    "aids.stat",
                    "si.time",
                    "si.stat",
                    "death.time",
                    "death.stat",
                    "age.inf",
                    "ccr5")
write.csv(data.frame(aidssi2), file ="aidssi2.csv")
discri_statistic = data.frame(summary(aidssi2))

# kaplan-meier curve for original data
Y <- data.frame(aidssi2$death.time) # +aidssi2$entry.time. infection time to terminal event (death from AIDS)
d2 <- data.frame(aidssi2$death.stat)#indicator for death from AIDS

age<- data.frame(aidssi2$age.inf)
ccr5 <- data.frame(aidssi2$ccr5 )
aidssi2_frame = cbind(Y, d2, age, ccr5)
write.csv(data.frame(aidssi2_frame), file ="aidssi2_frame.csv")
names(aidssi2_frame) <- c("Y", "d2", "age","ccr5")
km1 <-survfit(Surv(Y, d2)~1, data=aidssi2_frame)
km<-survfit(Surv(Y, d2)~ccr5, data=aidssi2_frame)
# set.seed(33)
# palette <- sample(c("color1", "color2", ...), 324, replace = TRUE) ggsurvplot
fitlist<-list(km1, km)
ggsurvplot_combine(fitlist, data = aidssi2_frame,
                   title  = "",  
                   xlab = "time(year)", 
                   ylab = "survival probability", 
                   font.main = c(22,  "darkblue"), 
                   font.x = c(22,  "darkblue"), 
                   font.y = c(22, "darkblue"),
                   palette=c("red", "blue","green"),
                   # group.by = "ccr5",
                   legend = c(0.8,0.95),       
                   legend.title = "ccr5",  
                   legend.labs = c('All', 'ccr5=WW' , 'ccr5=WM'),  
                   # size = 1, 
                   break.x.by=1 ,
                   break.y.by=0.2 ,
                   surv.scale="default" ,
                   # palette ="aaas", 
                   conf.int = T, 
                   pval = TRUE ,
                   # pval.coord = c(12, 0),
                   # pval.size = 5,
                   # pval.method=TRUE,
                   # pval.method.size=5,
                   # pval.method.coord=c(1,0),
                   linetype = "strata",
                   surv.median.line = "hv",
                   # ggtheme = theme_bw(), 
                   # palette =
                   # palette = c("ucscgb","npg" ),   # "npg" ucscgb" #E7B800
                   ylim = c(0, 1),
                   xlim =c(x_start, x_end),
                   
                   risk.table = TRUE,     
                   risk.table.title = "Number at risk by time",
                   risk.table.fontsize = 3,
                   risk.table.height = 0.3, surv.plot.height = 0.7,
)
####### plot the predicted survival function curve
# explicitly change the dummy variables
Y <- data.frame(aidssi2$death.time) #-aidssi2$entry.time time to terminal event (death from AIDS)
d2 <- data.frame(aidssi2$death.stat)#indicator for death from AIDS
age<- data.frame(aidssi2$age.inf)
ccr5 <- data.frame(aidssi2$ccr5 )
aidssi2_frame = cbind(Y, d2, age, ccr5)
names(aidssi2_frame) <- c("Y", "d2", "age","ccr5")
# implicitly deal with the dummy variables 
# res_cox <- survfit(Surv(Y, d2) ~ age + ccr5, data =  aidssi2_frame)
# res_cox_sum = summary(res_cox)
res.cox <- coxph(Surv(Y, d2) ~ age + ccr5, data =  aidssi2_frame)
res_c0x_sum = summary(res.cox)
fitlist_fit<-list(km1, survfit(res.cox))
ggsurvplot_combine(fitlist_fit, data =  aidssi2_frame,
                   xlab = "time(year)", 
                   ylab = "survival probability", 
                   font.main = c(22,  "darkblue"), 
                   font.x = c(22,  "darkblue"), 
                   font.y = c(22, "darkblue"),
                   palette=c("blue", "red"),
                   # group.by = "ccr5",
                   legend = c(0.1,0.2),         
                   legend.title = "",  
                   legend.labs = c('original' , 'survfit'),  
                   # size = 1, 
                   break.x.by=1 ,
                   break.y.by=0.2 ,
                   surv.scale="default" ,
                   # palette ="aaas", 
                   conf.int = T, 
                   linetype = "strata",
                   ylim = c(0, 1),
                   xlim =c(x_start, x_end),
                   risk.table = TRUE,     
                   risk.table.title = "Number at risk by time",
                   risk.table.fontsize = 3,
                   risk.table.height = 0.3, surv.plot.height = 0.7,)
# ggsurvplot(fitlist_fit, data =  aidssi2_frame,palette= "#2E9FDF",
#            ggtheme = theme_minimal())

# %>%
# dplyr::slice(1:5)
sex_df <- with(aidssi2_frame,data.frame(ccr5 = c('WW', 'WM'), 
                                        age = rep(mean(age, na.rm = TRUE), 2)))
sex_df

fit_rescox <- survfit(res.cox, newdata = sex_df)
# compare_fit<-list(km, fit_rescox)
# ggsurvplot_combine(compare_fit, data =sex_df, 
#                    conf.int = TRUE, 
#                    legend.labs=c("ccr5=WW","ccr5=WM","ccr5=surfitWW", 
#                                                     "ccr5=surfitWM"),
#                                            ggtheme = theme_minimal())
ggsurvplot(fit_rescox, data =sex_df, 
           legend.labs=c("ccr5=WW", "ccr5=WM"),
           font.main = c(22,  "darkblue"), 
           xlab = "time(year)", 
           ylab = "survival probability", 
           font.x = c(22,  "darkblue"), 
           font.y = c(22, "darkblue"),
           palette=c("red", "blue"),
           legend = c(0.1,0.1), # legend position         
           legend.title = "", # legend title  
           # size = 1, 
           break.x.by=1 ,
           break.y.by=0.2 ,
           surv.scale="default" ,
           # palette ="aaas", 
           conf.int = T, 
           linetype = "strata",
           ylim = c(0, 1),
           xlim =c(x_start, x_end),
           #         ggtheme = theme_minimal()
)
# save the estimation of the coefficient
dataframe_res_c0x = data.frame(res_c0x_sum[["coefficients"]])
dataframe_res_cox_sum = data.frame(res_c0x_sum[["conf.int"]])
bind_cox = cbind(round(dataframe_res_c0x,3),  round(dataframe_res_cox_sum,3) )
bind_cox1= bind_cox[,-which(duplicated(names(bind_cox)))]
write.csv(data.frame(bind_cox1), file ="coefficient_Cox.csv")
#
logtest =  res_c0x_sum[["logtest"]] 
sctest = res_c0x_sum["sctest"]
waldtest = res_c0x_sum["waldtest"]
test_combin = data.frame( logtest,  sctest , waldtest  )
test_combin = data.frame(t(test_combin))

