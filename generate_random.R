

cat("starting generation...")

theseed <- round(runif(1,0,100))
set.seed(theseed)
added <- sample(1:10,1)
date <- Sys.time()

if (file.exists("data/mydata.rda")) {
  
  cat("\nfound old data. appending new one")
  
  load("data/mydata.rda")
  
  newone <- data.frame(Session = session,
                       Coin = rbinom(added,1,.5)
                       )
  
  thedata <- rbind(thedata,newone)
  
  session <- max(sesinfo$Session)
  
  info <- data.frame(Session = session + 1,
                     Date = as.character(date),
                     Seed = theseed,
                     Added = added)
  
  sesinfo <- rbind(sesinfo,info)
  
  
} else {
  
  cat("\nold data not found. starring new")
  
  session <- 1
  
  newone <- data.frame(Session = session,
                       Coin = rbinom(added,1,.5)
  )
  
  thedata <- newone
  
  sesinfo <- data.frame(Session = session,
                     Date = as.character(date),
                     Seed = theseed,
                     Added = added)
  
}


save(sesinfo,thedata,file = "data/mydata.rda")

write.csv(file = "data/matrix.csv",thedata)
write.csv(file = "data/sesinfo.csv",sesinfo)

cat("\nnew data added!")

library(ggplot2)
library(knitr)

cat("\nMaking markdown report....")

res <- data.frame(P = cumsum(thedata$Coin)/1:nrow(thedata),
                  N = 1:nrow(thedata))

p1 <- ggplot(res,aes(N,P)) +
  scale_y_continuous(limits = c(0,1)) +
  geom_line(color = "red") +
  theme_minimal() +
  labs(title = "Convergence of Binomial 0.5")

ggsave(filename = "charts/plot1.png",plot = p1)

p2 <- ggplot(sesinfo,aes(Date,Added)) + 
  geom_bar(stat = "identity",fill = "red") +
  theme_minimal() +
  labs(title = "Added Coins by date")

ggsave(filename = "charts/plot2.png",plot = p2)

tabtxt <- paste(knitr::kable(sesinfo),collapse = "\n")
mdtxt <- paste("# Status of the operation
  
  This is a daily random binomial generator.
  
## Procces info",tabtxt,
"## Charts 

![](charts/plot1.png)

![](charts/plot2.png)

## End

Thats it, thanks for watching!", sep = "\n\n")

writeLines(con = "readme.md",mdtxt)

cat("\n Report Done! Everything up to date!")

