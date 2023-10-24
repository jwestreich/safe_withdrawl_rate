library(quantmod)
library(dplyr)
library(tibble)
library(lubridate)
library(ggplot2)

trial_count<-10000
withdrawl_rate<-.04
starting_value<-1000000

monthly_withdrawl<-(starting_value*withdrawl_rate)/12
breakeven<-1/withdrawl_rate
fail_dates <- list()
getSymbols("^GSPC", from = "1946-01-01")
sp500 <- as_tibble(Cl(GSPC), rownames = "Date")

all_dates <- seq(Sys.Date() + 1, Sys.Date() + 1 + years(100), by = "days")
weekdays_only <- all_dates[!weekdays(all_dates) %in% c("Saturday", "Sunday")]
weekdays<-data.frame(date = as.POSIXct(weekdays_only))

for(j in 1:trial_count) {
  sp_500_dist<-sp500%>%
    mutate(daily_growth=GSPC.Close/lag(GSPC.Close))%>%
    mutate(rand=runif(n()))%>%
    arrange(rand)%>%
    mutate(seqnum=row_number())%>%
    select(daily_growth,seqnum)%>%
    filter(!is.na(daily_growth))
  dist_max <- nrow(sp_500_dist)
  
  future <- weekdays%>%
    mutate(seqnum = sample(1:dist_max, n(), replace = TRUE))%>%
    left_join(sp_500_dist,by=c("seqnum"))%>%
    select(-seqnum)%>%
    mutate(daily_growth=ifelse(is.na(daily_growth),1,daily_growth))%>%
    mutate(portfolio_value = if_else(row_number() == 1, starting_value, NA_real_))
  
  for(i in 2:nrow(future)) {
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
  
  print(paste("Trial", j, "completed at",Sys.time()))
}

fail_years <- tibble(fail_year = fail_dates)%>%
  mutate(fail_year=as.integer(fail_year))%>%
  group_by(fail_year) %>%
  summarise(fails=n())

yearly_summary <- tibble(year = (as.numeric(format(Sys.Date(), '%Y'))):(as.numeric(format(Sys.Date(), '%Y')) + 100))%>%
  left_join(fail_years,by=c("year"="fail_year"))%>%
  mutate(fails=ifelse(is.na(fails),0,fails))%>%
  mutate(success_prob = ifelse(row_number() == 1, trial_count-fails, NA_real_))%>%
  mutate(success_prob = cumsum(if_else(is.na(success_prob), -fails, success_prob)))%>%
  mutate(success_prob=success_prob*(100/trial_count))%>%
  mutate(retirement_length=year-as.numeric(format(Sys.Date(), '%Y')))

ggplot(yearly_summary, aes(x = retirement_length, y = success_prob)) +
  geom_line(color="red", size=2) +
  geom_hline(yintercept = 95, color = "black", size = .5) +
  geom_vline(aes(xintercept = breakeven), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success")+
  scale_y_continuous(limits = c(80, 100.1), breaks = seq(80, 100, by = 1), expand = c(0,0))+
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, by = 5), expand = c(0,0))+
  theme_minimal(base_rect_size = 0.5) +
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"))

#toggle between 1928, 1946, and 1970 as starting points (just with 4% to show that training data period won't have large effect)
#only randomize daily market growths every 100 trials
#remove holidays from future
#test 3%, 4%, and 5% withdrawal rates
#adjust monthly withdrawal by a) rebasing to x% of portfolio value each year and b) increasing by z% (inflation)