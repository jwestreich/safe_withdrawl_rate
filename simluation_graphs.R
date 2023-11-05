library(dplyr)
library(ggplot2)
folder_path<-"C:/Users/jwest/github/safe_withdrawl_rate/simulation_graphs/"

w3_t46_i0<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw3_training1946_inflation0_10000trials.csv")%>%
  mutate(withdrawl=3,
         training=1946,
         inflation=0)
w3_t46_i2<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw3_training1946_inflation2_10000trials.csv")%>%
  mutate(withdrawl=3,
         training=1946,
         inflation=2)
w4_t27_i0<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw4_training1927_inflation0_10000trials.csv")%>%
  mutate(withdrawl=4,
         training=1927,
         inflation=0)
w4_t46_i0<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw4_training1946_inflation0_10000trials.csv")%>%
  mutate(withdrawl=4,
         training=1946,
         inflation=0)
w4_t46_i2<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw4_training1946_inflation2_10000trials.csv")%>%
  mutate(withdrawl=4,
         training=1946,
         inflation=2)
w4_t70_i0<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw4_training1970_inflation0_10000trials.csv")%>%
  mutate(withdrawl=4,
         training=1970,
         inflation=0)
w5_t46_i0<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw5_training1946_inflation0_10000trials.csv")%>%
  mutate(withdrawl=5,
         training=1946,
         inflation=0)
w5_t46_i2<-read.csv("C:/Users/jwest/github/safe_withdrawl_rate/simluation_results/withdraw5_training1946_inflation2_10000trials.csv")%>%
  mutate(withdrawl=5,
         training=1946,
         inflation=2)

data<-rbind(w3_t46_i0,w3_t46_i2,w4_t27_i0,w4_t46_i0,w4_t46_i2,w4_t70_i0,w5_t46_i0,w5_t46_i2)

training_data<-data%>%
  filter(withdrawl==4 & inflation==0)%>%
  mutate(training=as.factor(training))%>%
  rename(`Start of\nTraining Period`=training)
training<-ggplot(training_data, aes(x = retirement_length, y = success_prob, color = `Start of\nTraining Period`)) +
  geom_line(size=1.2) +
  geom_vline(aes(xintercept = 30), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success")+
  scale_y_continuous(labels = scales::percent_format(scale = 1), limits = c(50, 100.1), breaks = seq(50, 100, by = 10), expand = c(0,0))+
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 50, by = 5), expand = c(0,0))+
  scale_color_manual(values = c("red", "#00BA38", "blue")) +
  ggtitle("Confidence of Success of 4% Rule\nby Different Training Periods\n") +
  theme_minimal(base_rect_size = 0.5) +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"),
        legend.title = element_text(hjust = 0.5))
ggsave(paste0(folder_path,"training.png"), plot = training)

withdrawl_data<-data%>%
  filter(training==1946 & inflation==0)%>%
  mutate(withdrawl=paste0(withdrawl,"%"))%>%
  rename(`Withdrawl Rate`=withdrawl)
withdrawl<-ggplot(withdrawl_data, aes(x = retirement_length, y = success_prob, color = `Withdrawl Rate`)) +
  geom_line(size=1.2) +
  geom_vline(aes(xintercept = 30), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success")+
  scale_y_continuous(labels = scales::percent_format(scale = 1), limits = c(50, 100.1), breaks = seq(50, 100, by = 10), expand = c(0,0))+
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 50, by = 5), expand = c(0,0))+
  scale_color_manual(values = c("red", "blue", "#00BA38")) +
  ggtitle("Confidence of Success of Withdrawl Rule\nby Different Withdrawl Rates\n") +
  theme_minimal(base_rect_size = 0.5) +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"),
        legend.title = element_text(hjust = 0.5))
ggsave(paste0(folder_path,"withdrawl.png"), plot = withdrawl)

inflation_w3_data<-data%>%
  filter(training==1946 & withdrawl==3)%>%
  mutate(inflation=paste0(inflation,"%"))%>%
  rename(`Long-Run\nInflation Rate`=inflation)
inflation3<-ggplot(inflation_w3_data, aes(x = retirement_length, y = success_prob, linetype = `Long-Run\nInflation Rate`)) +
  geom_line(color="#00BA38", size = 1.2) +
  geom_vline(aes(xintercept = 30), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success") +
  scale_y_continuous(labels = scales::percent_format(scale = 1), limits = c(50, 100.1), breaks = seq(50, 100, by = 10), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 50, by = 5), expand = c(0, 0)) +
  scale_linetype_manual(values = c("dashed", "solid")) +
  ggtitle("Confidence of Success of 3% Withdrawal Rule\nFactoring Inflation\n") +
  theme_minimal(base_rect_size = 0.5) +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"),
        legend.title = element_text(hjust = 0.5),
        legend.key.width = unit(1.5, "cm"))
ggsave(paste0(folder_path,"inflation3.png"), plot = inflation3)

inflation_w4_data<-data%>%
  filter(training==1946 & withdrawl==4)%>%
  mutate(inflation=paste0(inflation,"%"))%>%
  rename(`Long-Run\nInflation Rate`=inflation)
inflation4<-ggplot(inflation_w4_data, aes(x = retirement_length, y = success_prob, linetype = `Long-Run\nInflation Rate`)) +
  geom_line(color="blue", size = 1.2) +
  geom_vline(aes(xintercept = 30), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success") +
  scale_y_continuous(labels = scales::percent_format(scale = 1), limits = c(50, 100.1), breaks = seq(50, 100, by = 10), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 50, by = 5), expand = c(0, 0)) +
  scale_linetype_manual(values = c("dashed", "solid")) +
  ggtitle("Confidence of Success of 4% Withdrawal Rule\nFactoring Inflation\n") +
  theme_minimal(base_rect_size = 0.5) +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"),
        legend.title = element_text(hjust = 0.5),
        legend.key.width = unit(1.5, "cm"))
ggsave(paste0(folder_path,"inflation4.png"), plot = inflation4)

inflation_w5_data<-data%>%
  filter(training==1946 & withdrawl==5)%>%
  mutate(inflation=paste0(inflation,"%"))%>%
  rename(`Long-Run\nInflation Rate`=inflation)
inflation5<-ggplot(inflation_w5_data, aes(x = retirement_length, y = success_prob, linetype = `Long-Run\nInflation Rate`)) +
  geom_line(color="red", size = 1.2) +
  geom_vline(aes(xintercept = 30), color = "black", size = .5) +
  labs(x = "Length of Retirement", y = "Confidence of Success") +
  scale_y_continuous(labels = scales::percent_format(scale = 1), limits = c(50, 100.1), breaks = seq(50, 100, by = 10), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 50, by = 5), expand = c(0, 0)) +
  scale_linetype_manual(values = c("dashed", "solid")) +
  ggtitle("Confidence of Success of 5% Withdrawal Rule\nFactoring Inflation\n") +
  theme_minimal(base_rect_size = 0.5) +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "gray"),
        panel.grid.minor = element_line(color = "gray"),
        legend.title = element_text(hjust = 0.5),
        legend.key.width = unit(1.5, "cm"))
ggsave(paste0(folder_path,"inflation5.png"), plot = inflation5)
