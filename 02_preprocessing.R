library(tidyverse)
library(magrittr)
library(purrr)
library(here)
library(pinyin)
library(lubridate)
library(timeDate)

cityname<-list.files("data/2020")
path<-list.dirs("data/2020")[-1]
filepath<-map2(path,map(path,list.files),~paste(.x,.y,sep="/"))

#map(list.files("data/2020"),read_csv)%>%reduce(rbind)
df<-tibble(cityname,filepath)%>%
  unnest()%>%
  mutate(value=map(filepath,
                   ~read_csv(file=.,
                             col_names = c("ID","time1","AQI1","Grade1","PM251",
                                           "PM101","SO21","CO1","NO21","O31"),
                             col_types=list(col_integer(),
                                            col_character(),
                                            col_character(),
                                            col_character(),
                                            col_character(),
                                            col_character(),
                                            col_character(),
                                            col_character(),
                                            col_character(),
                                            col_character()),
                             skip=1)))%>%
  unnest()%>%
  mutate(cn_en=gsub(" ",
                    "",
                    str_to_title(py(.$cityname,
                            sep=" ",
                            dic=pydic(method="toneless",
                                      dic="pinyin2")))),
         time=str_remove(.$time1,"[a-z>\n\r]+"),
         AQI=as.numeric(str_remove(.$AQI1,"[a-z>\n\r]+")),
         PM25=as.numeric(str_remove(.$PM251,"[a-z>\n\r]+")),
         PM10=as.numeric(str_remove(.$PM101,"[a-z>\n\r]+")),
         SO2=as.numeric(str_remove(.$SO21,"[a-z>\n\r]+")),
         CO=as.numeric(str_remove(.$CO1,"[a-z>\n\r]+")),
         NO2=as.numeric(str_remove(.$NO21,"[a-z>\n\r]+")),
         O3=as.numeric(str_remove(.$O31,"[a-z>\n\r]+")))%>%
  mutate(season= cut(month(as_date(.$time)),
                     breaks=c(0,2,5,8,11,12),
                     labels=c("winter","spring","summer","autumn","winter")),
         week=dayOfWeek(timeDate(as_date(.$time), FinC = "GMT")),
         grade=cut(.$AQI,
                   breaks=c(-1,0,50,100,200,300,1000),
                   labels=c("0","1st","2st","3st","4st","5st")))%>%
  select(cn_en,
         cn_zh=cityname,
         time,
         season,
         week,
         grade,
         AQI,PM25,PM10,SO2,CO,NO2,O3
        )%T>%
  write.csv(here("data","AQI_2020.csv"))
