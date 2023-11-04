library(quantmod)
library(dplyr)
library(tibble)
library(lubridate)
library(ggplot2)
library(timeDate)
library(webshot)
library(kableExtra)
folder_path<-"C:/Users/jwest/github/safe_withdrawl_rate/sp500_dist_graphs/"

training_periods <- c("1927-01-01", "1946-01-01", "1970-01-01")

for (training_period in training_periods) {
  training_year <- year(as.Date(training_period))
  getSymbols("^GSPC", from = training_period)
  df_name <- paste("sp_500", training_year, sep = "_")
  
  assign(df_name, as_tibble(Cl(GSPC), rownames = "Date") %>%
           mutate(Date = as.Date(Date)) %>%
           mutate(daily_growth = (GSPC.Close / lag(GSPC.Close) - 1)) %>%
           mutate(yearly_growth = GSPC.Close / lag(GSPC.Close, 252) - 1) %>%
           mutate(yearly_growth = ifelse(year(Date) != year(lag(Date)), yearly_growth, NA)) %>%
           mutate(training = training_year) %>%
           filter(!is.na(daily_growth))
  )
}
sp_500_all<-rbind(sp_500_1927,sp_500_1946,sp_500_1970)

sp_500_noout<-sp_500_1946%>%
  mutate(daily_growth=ifelse(daily_growth<(-.05),-.05,daily_growth))%>%
  mutate(daily_growth=ifelse(daily_growth>.05,.05,daily_growth))

hist<-ggplot(sp_500_noout, aes(x = daily_growth)) +
  geom_histogram(binwidth = 0.0015, fill="#4795DB") +  
  geom_vline(aes(xintercept = 0), color = "red") +
  xlim(-.05, .05) +
  xlab("Daily Growth") +
  ylab("") +
  ggtitle(paste0("Distribution of S&P 500 Daily Growth\n1946 to 2023"))+
  scale_x_continuous(labels = scales::percent_format(scale = 100, accuracy = 1), breaks = seq(-0.05, 0.05, by = 0.01))+
  theme_classic()+
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank()
  )
ggsave(paste0(folder_path,"hist_1946.png"), plot = hist)

boxplot_data<-sp_500_all%>%
  filter(!is.na(yearly_growth))%>%
  mutate(training=as.factor(training))

box<-boxplot_data %>%
  ggplot(aes(x = training, y = yearly_growth)) +
  geom_boxplot(outlier.shape = NA)+
  geom_hline(yintercept = 0, color = "red") +
  ylab("Yearly Growth")+
  ggtitle(paste0("Distribution of S&P 500 Annual Growth\nDifferent Training Periods"))+
  scale_y_continuous(limits = c(-0.5, 0.5),
                     labels = scales::percent_format(scale = 100),
                     breaks = seq(-0.5, 0.5, by = 0.1)) +
  xlab("Start of Training Period") +
  theme_classic()+
  theme(
    plot.title = element_text(hjust = 0.5)
  )
ggsave(paste0(folder_path,"boxplot.png"), plot = box)

summary_table <- sp_500_all %>%
  group_by(training) %>%
  summarise(
    Minimum = sprintf("%.2f%%", round(100 * min(daily_growth, na.rm=T), 2)),
    `5th Percentile` = sprintf("%.2f%%", round(100 * quantile(daily_growth, 0.05, na.rm=T), 2)),
    `25th Percentile` = sprintf("%.2f%%", round(100 * quantile(daily_growth, 0.25, na.rm=T), 2)),
    Median = sprintf("%.2f%%", round(100 * median(daily_growth, na.rm=T), 2)),
    Mean = sprintf("%.2f%%", round(100 * mean(daily_growth, na.rm=T), 2)),
    `75th Percentile` = sprintf("%.2f%%", round(100 * quantile(daily_growth, 0.75, na.rm=T), 2)),
    `95th Percentile` = sprintf("%.2f%%", round(100 * quantile(daily_growth, 0.95, na.rm=T), 2)),
    Maximum = sprintf("%.2f%%", round(100 * max(daily_growth, na.rm=T), 2)),
    `Standard Deviation` = sprintf("%.2f%%", round(100 * sd(daily_growth, na.rm=T), 2))
  ) %>%
  rename(`Start of Training Data` = training)

dist_table<-kable(summary_table, format = "html", caption = "<span style='color:black;'>Summary Statistics of S&P 500 Daily Growth Rates</span>") %>%
  kable_styling()






example_simulations<-data.frame()
getSymbols("^GSPC", from = "1946-01-01")
sp500 <- as_tibble(Cl(GSPC), rownames = "Date")

for(j in 1:10) {
  sp_500_dist<-sp500%>%
    mutate(daily_growth=GSPC.Close/lag(GSPC.Close))%>%
    mutate(rand=runif(n()))%>%
    arrange(rand)%>%
    mutate(seqnum=row_number())%>%
    select(daily_growth,seqnum)%>%
    filter(!is.na(daily_growth))
  dist_max <- nrow(sp_500_dist)
  
  federal_holidays <- as.Date(holidayNYSE(2022:2073))
  all_dates <- seq(Sys.Date() + 1, Sys.Date() + 1 + years(50), by = "days")
  weekdays_only <- all_dates[!weekdays(all_dates) %in% c("Saturday", "Sunday")]
  weekdays_no_holidays <- weekdays_only[!weekdays_only %in% federal_holidays]
  weekdays <- data.frame(date = as.POSIXct(weekdays_no_holidays))
  
  future<-weekdays%>%
    mutate(seqnum = sample(1:dist_max, n(), replace = TRUE))%>%
    left_join(sp_500_dist, by=c("seqnum"))%>%
    mutate(daily_growth=ifelse(is.na(daily_growth),1,daily_growth))%>%
    mutate(value = if_else(row_number() == 1, 1, NA_real_))
  
  for(i in 2:nrow(future)) {
   future$value[i]=future$value[i-1]*future$daily_growth[i]
  }

  future<-future%>%mutate(sim=j)
  example_simulations=rbind(example_simulations,future)
  print(j)
}

growth_7<-example_simulations%>%
  filter(sim==1)%>%
  mutate(sim=0)%>%
  mutate(sim=as.factor(sim))%>%
  mutate(year=row_number()/252)%>%
  mutate(value=ifelse(row_number()>1,NA,value))
growth_7$value <- cumprod(c(growth_7$value[1], rep(1.000269594, nrow(growth_7) - 1)))

example_sim_graph<-example_simulations%>%
  mutate(sim=as.factor(sim))%>%
  group_by(sim)%>%
  mutate(year=row_number()/252)%>%
  rbind(growth_7)

example_50yr<-ggplot(example_sim_graph %>% filter(value <= 50), aes(x = year, y = value, color = sim)) +
  geom_line() +
  scale_color_manual(values = c("red", "orange", "gold", "green", "darkgreen", "blue", "purple", "gray", "brown", "cyan", "black"))+
  labs(x = "Year", y = "Growth Rate")+
  ggtitle("Examples of Simulated S&P 500 Growth\n50 Year View") +
  theme_classic()+
  guides(color = FALSE)
#ggsave(paste0(folder_path,"example_50yr.png"), plot = example_50yr)

example_30yr<-ggplot(example_sim_graph %>% filter(year <= 30 & value <= 25), aes(x = year, y = value, color = sim)) +
  geom_line() +
  scale_color_manual(values = c("red", "orange", "gold", "green", "darkgreen", "blue", "purple", "gray", "brown", "cyan", "black"))+
  labs(x = "Year", y = "Growth Rate") +
  ggtitle("Examples of Simulated S&P 500 Growth\n30 Year View") +
  theme_classic() +
  guides(color = FALSE)+
  scale_x_continuous(breaks = seq(0, 30, by = 5))
#ggsave(paste0(folder_path,"example_30yr.png"), plot = example_30yr)

example_10yr<-ggplot(example_sim_graph %>% filter(year <= 10), aes(x = year, y = value, color = sim)) +
  geom_line() +
  scale_color_manual(values = c("red", "orange", "gold", "green", "darkgreen", "blue", "purple", "gray", "brown", "cyan", "black"))+
  labs(x = "Year", y = "Growth Rate") +
  ggtitle("Examples of Simulated S&P 500 Growth\n10 Year View") +
  theme_classic() +
  guides(color = FALSE)+
  scale_x_continuous(breaks = seq(0, 10, by = 1))
#ggsave(paste0(folder_path,"example_10yr.png"), plot = example_10yr)
