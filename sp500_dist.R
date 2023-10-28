library(quantmod)
library(dplyr)
library(tibble)
library(lubridate)
library(ggplot2)
library(timeDate)

training_period<-"1970-01-01"
training_year<-year(training_period)
folder_path<-"C:/Users/jwest/github/safe_withdrawl_rate/sp500_dist_graphs/"

getSymbols("^GSPC", from = training_period)
sp_500_dist <- as_tibble(Cl(GSPC), rownames = "Date")%>%
  mutate(daily_growth=(GSPC.Close/lag(GSPC.Close)-1))%>%
  filter(!is.na(daily_growth))

sp_500_noout<-sp_500_dist%>%
  mutate(daily_growth=ifelse(daily_growth<(-.05),-.05,daily_growth))%>%
  mutate(daily_growth=ifelse(daily_growth>.05,.05,daily_growth))

hist<-ggplot(sp_500_noout, aes(x = daily_growth)) +
  geom_histogram(binwidth = 0.0015, fill="#4795DB") +  
  geom_vline(aes(xintercept = 0), color = "red") +
  xlim(-.05, .05) +
  xlab("Daily Growth") +
  ylab("") +
  ggtitle(paste0("Distribution of S&P 500 Daily Growth\n",training_year," to 2023"))+
  scale_x_continuous(labels = scales::percent_format(scale = 100, accuracy = 1), breaks = seq(-0.05, 0.05, by = 0.01))+
  theme_classic()+
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank()
  )
ggsave(paste0(folder_path,"hist_",training_year,".png"), plot = hist)

box<-ggplot(sp_500_dist, aes(y = daily_growth)) +
  geom_boxplot(outlier.shape = NA) +
  geom_hline(yintercept = 0, color = "red") +
  ylab("Daily Growth")+
  ggtitle(paste0("Distribution of S&P 500 Daily Growth\n",training_year," to 2023"))+
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
ggsave(paste0(folder_path,"box_",training_year,".png"), plot = box)

summary_table <- sp_500_dist %>% 
  summarise(
    min = min(daily_growth, na.rm = TRUE),
    perc_5 = quantile(daily_growth, 0.05, na.rm = TRUE),
    perc_25 = quantile(daily_growth, 0.25, na.rm = TRUE),
    median = median(daily_growth, na.rm = TRUE),
    mean = mean(daily_growth, na.rm = TRUE),
    perc_75 = quantile(daily_growth, 0.75, na.rm = TRUE),
    perc_95 = quantile(daily_growth, 0.95, na.rm = TRUE),
    max = max(daily_growth, na.rm = TRUE),
    std_dev = sd(daily_growth, na.rm = TRUE)
  )
