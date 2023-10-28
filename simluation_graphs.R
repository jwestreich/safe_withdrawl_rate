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