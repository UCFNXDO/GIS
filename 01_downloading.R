#devtools::install_github("cpsievert/rdom")
library(XML)
library(xml2)
library(rdom)
library(magrittr)
library(here)
#stopifnot(Sys.which("phantomjs") != "")#test the phantomjs 
city<-read.csv(file=here("city.csv"))
riqi<-c(202001:202012)
for (ct in 1:length(city$URL)){
  file_path<-paste(here("data"),city$name[ct],sep="/")
  for (rq in riqi){
    #filename<-paste(file_path,"/",as.character(rq),".csv",sep="")
    if (!file.exists(file_path)){
      dir.create(paste(here("data"),city$name[ct],sep="/"))
    }
    url<-paste(city$URL[ct],"&month=",as.character(rq),sep="")
    tbl<-rdom(url)
    tbl1<-readHTMLTable(tbl,header=TRUE)
    tbl2<-as.data.frame(tbl1)
    if (nrow(tbl2)!=0) {
      colnames(tbl2)<-c("riqi","AQI","grade","PM2.5","PM10","SO2","CO","NO2","O3_8h")
      write.csv(tbl2,file=paste(here("data",city$name[ct]),"/",as.character(rq),".csv",sep=""))
    }else{
      result_null<-data.frame()
      result_null<-data.frame(riqi=c(NA),AQI=c(NA),grade=c(NA),PM2.5=c(NA),PM10=c(NA),
                              SO2=c(NA),CO=c(NA),NO2=c(NA),O3_8h=c(NA))
      write.csv(result_null[-1,],file=paste(here("data",city$name[ct]),"/",as.character(rq),".csv",sep=""))
    }
  }
  cat(city$name[ct])
}
