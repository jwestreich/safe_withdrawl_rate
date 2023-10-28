library(quantmod)
library(dplyr)
library(tibble)
library(lubridate)
library(ggplot2)
library(timeDate)

trial_count<-10
trial_size<-10
withdrawl_rate<-.04
starting_value<-1000000
inflation<-0

breakeven<-1/withdrawl_rate
fail_dates <- list()
getSymbols("^GSPC", from = "1927-01-01")
sp500 <- as_tibble(Cl(GSPC), rownames = "Date")

federal_holidays <- as.Date(holidayNYSE(2022:2173))
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

yearly_summary <- tibble(year = (as.numeric(format(Sys.Date(), '%Y'))):(as.numeric(format(Sys.Date(), '%Y')) + 100))%>%
  left_join(fail_years,by=c("year"="fail_year"))%>%
  mutate(fails=ifelse(is.na(fails),0,fails))%>%
  mutate(success_prob = ifelse(row_number() == 1, (trial_count*trial_size)-fails, NA_real_))%>%
  mutate(success_prob = cumsum(if_else(is.na(success_prob), -fails, success_prob)))%>%
  mutate(success_prob=success_prob*(100/(trial_count*trial_size)))%>%
  mutate(retirement_length=year-as.numeric(format(Sys.Date(), '%Y')))

sp_500_graph<-sp_500_dist%>%
  mutate(daily_growth=daily_growth-1)%>%
  mutate(daily_growth=ifelse(daily_growth<(-.05),-.05,daily_growth))%>%
  mutate(daily_growth=ifelse(daily_growth>.05,.05,daily_growth))

ggplot(sp_500_graph, aes(x = daily_growth)) +
  geom_histogram(binwidth = 0.0015, fill="#4795DB") +  
  geom_vline(aes(xintercept = 0), color = "red") +
  xlim(-.05, .05) +
  xlab("Daily Growth") +
  ylab("") +
  ggtitle("Distribution of S&P 500 Daily Growth")+
  scale_x_continuous(labels = scales::percent_format(scale = 100, accuracy = 1), breaks = seq(-0.05, 0.05, by = 0.01))+
  theme_classic()+
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank()
  )

ggplot(sp_500_dist, aes(y = daily_growth-1)) +
  geom_boxplot(outlier.shape = NA) +
  geom_hline(yintercept = 0, color = "red") +
  ylab("Daily Growth")+
  ggtitle("Distribution of S&P 500 Daily Growth") +
  scale_y_continuous(limits = c(-0.02, 0.02),
                     labels = scales::percent_format(scale = 100, accuracy = .5),
                     breaks = seq(-0.02, 0.02, by = 0.005)) +
  theme_classic()+
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.title.x=element_blank(),
    axis.text.x=element_blank(),
    axis.ticks.x=element_blank()
  )

ggplot(yearly_summary, aes(x = retirement_length, y = success_prob)) +
  geom_line(color="red", size=2) +
  geom_hline(yintercept = 95, color = "black", size = .5) +
  geom_vline(aes(xintercept = breakeven), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success")+
  scale_y_continuous(limits = c(0, 100.1), breaks = seq(0, 100, by = 10), expand = c(0,0))+
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 50, by = 5), expand = c(0,0))+
  theme_minimal(base_rect_size = 0.5) +
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"))

#test 3%, 4%, and 5% withdrawal rates