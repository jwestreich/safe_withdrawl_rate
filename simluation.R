library(quantmod)
library(dplyr)
library(tibble)
library(lubridate)
library(ggplot2)
library(timeDate)
library(readr)

folder_path<-"C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/"
trial_count<-10
trial_size<-10
withdrawl_rate<-.04
starting_value<-1000000
inflation<-0
training_period<-"1927-01-01"
filename<-paste0("withdraw",withdrawl_rate*100,"_training",year(training_period),"_inflation",inflation*100,"_",trial_count*trial_size,"trials")

breakeven<-1/withdrawl_rate
fail_dates <- list()
getSymbols("^GSPC", from = training_period)
sp500 <- as_tibble(Cl(GSPC), rownames = "Date")

federal_holidays <- as.Date(holidayNYSE(2022:2073))
all_dates <- seq(Sys.Date() + 1, Sys.Date() + 1 + years(50), by = "days")
weekdays_only <- all_dates[!weekdays(all_dates) %in% c("Saturday", "Sunday")]
weekdays_no_holidays <- weekdays_only[!weekdays_only %in% federal_holidays]
weekdays <- data.frame(date = as.POSIXct(weekdays_no_holidays))

trial_counter<-0
for(j in 1:trial_count) {
  sp_500_dist<-sp500%>%
    mutate(daily_growth=GSPC.Close/lag(GSPC.Close))%>%
    mutate(rand=runif(n()))%>%
    arrange(rand)%>%
    mutate(seqnum=row_number())%>%
    select(daily_growth,seqnum)%>%
    filter(!is.na(daily_growth))
  dist_max <- nrow(sp_500_dist)
  
  for (k in 1:trial_size) {
    monthly_withdrawl<-(starting_value*withdrawl_rate)/12
    
    future <- weekdays%>%
      mutate(seqnum = sample(1:dist_max, n(), replace = TRUE))%>%
      left_join(sp_500_dist,by=c("seqnum"))%>%
      select(-seqnum)%>%
      mutate(daily_growth=ifelse(is.na(daily_growth),1,daily_growth))%>%
      mutate(portfolio_value = if_else(row_number() == 1, starting_value, NA_real_))
    
    for(i in 2:nrow(future)) {
      if (year(future$date[i]) != year(future$date[i-1])) {
        monthly_withdrawl<-monthly_withdrawl*(1+inflation)
      }
      if (!is.na(future$portfolio_value[i-1]) && future$portfolio_value[i-1] < 0) {
        break
      }
      future$portfolio_value[i] <- future$portfolio_value[i-1] * (future$daily_growth[i])
      if (month(future$date[i]) != month(future$date[i-1])) {
        future$portfolio_value[i] <- future$portfolio_value[i] - monthly_withdrawl
      }
    }
    
    future<-future%>%filter(!is.na(portfolio_value))
    
    if(min(future$portfolio_value) < 0) {
      fail_dates[[length(fail_dates) + 1]] <- as.numeric(format(max(future$date), "%Y"))
    }
    
    trial_counter <- trial_counter + 1
    print(paste("Trial", trial_counter, "completed at",Sys.time()))
  }
}

fail_years <- tibble(fail_year = fail_dates)%>%
  mutate(fail_year=as.integer(fail_year))%>%
  group_by(fail_year) %>%
  summarise(fails=n())

yearly_summary <- tibble(year = (as.numeric(format(Sys.Date(), '%Y'))):(as.numeric(format(Sys.Date(), '%Y')) + 50))%>%
  left_join(fail_years,by=c("year"="fail_year"))%>%
  mutate(fails=ifelse(is.na(fails),0,fails))%>%
  mutate(success_prob = ifelse(row_number() == 1, (trial_count*trial_size)-fails, NA_real_))%>%
  mutate(success_prob = cumsum(if_else(is.na(success_prob), -fails, success_prob)))%>%
  mutate(success_prob=success_prob*(100/(trial_count*trial_size)))%>%
  mutate(retirement_length=year-as.numeric(format(Sys.Date(), '%Y')))

write_csv(yearly_summary, paste0(folder_path,filename,".csv"))
