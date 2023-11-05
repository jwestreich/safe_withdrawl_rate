# Probabilistic Forecasting to Assess Validity of 4% Withdrawl Rule for Retirement

Some late night in college, I fell down a YouTube rabbit hole about [FIRE](https://en.wikipedia.org/wiki/FIRE_movement). FIRE stands for Financially Independent, Retire Early. The idea goes like this: sacrifice as much as you can when you start working in order to save and invest as much money as you can as quickly as possible; figure out how much money you would like to live on annually in retirement; save/invest until you have 25x that amount; stop working; withdraw only 4% of your savings each year, and you should be able to safely have a 30-year retirement. This idea has had validity in the personal finance community for several years because of some analysis of stock market trends over the past several decades. It has been demonstrated that there has *never* been a 30-year period where this would have failed. Even if you stopped working at the peak of the market, right before a crash, and consistently only withdrew 4% of your savings each year, you would have enough money to last 30 years.

While this analysis used methods that I'm sure the original creators of it believed was sound, there has been one significant limitation: the analysis is deterministic, instead of probabilistic. These methods assume that the stock market in the future will move in the exact same ways that they have in the past. While the past is informative of the future, it is not the future itself. Instead, the analysis in this repository is probabilitic: the past performance of the stock market is used to create many different simulations of what the future stock market could do. With enough simulations, a probability of success can be calculated for the 4% withdrawl rule, as well as some variants and changing some assumptions.

## Methods
### Creating a Forecast of the Stock Market
Let's define what measure of the stock market we're going to use. Most Americans use mutual funds, target retirment funds, or bonds (usually a combination of these) for their retirement savings. For this analysis, we are going to use *just* the growth of the S&P 500 as a measure of the general "market" that Americans are investing in for their retirement. This is one of the limitations of this analysis. There were too many risk-levels someone retiring could have that would influence what their savings would be in. Target retirement funds can have significant amounts of their assets in bonds, espcially as the target date gets closer. In future versions of this analysis, I would like to incorporate lower-risk investing strategies. For now, we will go forward with just investing in the S&P 500, knowing that this may make the forecast more volatile than expected.

The daily closing value of the S&P 500 can be imported into R. This is where we can use the past to inform our forecast of the future. Every day, the value of the S&P 500 moves by a measurable amount. Usually, the daily change is very small. I calculated the daily change of every day since the end of 1927 to fall of 2023. This was used to create a distribution of daily changes of the market. The histogram shows that most of the daily changes are right around 0 (note: the histogram shows the distribution from 1946-2023; more on that in the [next section](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/README.md#different-training-data-periods)). Anything greater than a 3% change (positive or negative) in a single day is very rare. 

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/hist_1946.png)

With all these daily changes, I assigned each day a random integer from 1 to the total number of observations I had in my dataset (without replacement). Then, I created a table with a row for each day the stock market was open for the next 50 years (removing all weekends and NYSE-recognized holidays). I also assigned each of these days a random integer with the same range as before (with replacement). We can do a left merge on this dataset of the future to the table of daily changes in the market. Now, each day in the future for the next 50 years has a random daily change in the market. Daily change amounts that were more common in the past are going to be more common in this forecast. Here are 10-year, 30-year, and 50-year views of 10 examples. The black line in the graphs shows what a constant 7% annual growth would look like, for some context.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/example_10yr.png)
![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/example_30yr.png)
![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/example_50yr.png)

### Simulating a Retirement
Now we can run a simulation. Let's assume a person has some random amount of money (we can just use 1 million dollars to keep things simple, the amount won't matter). All of that money is invested in the S&P 500, and every day the value of their savings will change based on the forecasted market. The only other time the value changes is on the first of each month, when they withdraw one twelfth of 4% of the amount they started at ($3,333.33 for our simulated one million dollars). We can also adjust the withdrawl amount with inflation. As long as the value stays above zero dollars, the retiree is successfully using the withdrawl rate rule. If the value ever drops to below zero dollars, the retiree is not successfully using the withdrawl rate rule. To get a probability of how successful using a withdrawl rate can be over time, each simulation is run 10,000 times.

There are three parameters that can be changed in the simluation: 1) the withdrawl rate can be changed, this analysis will show what a 3%, 4%, and 5% withdrawl rate will look like; 2) the inflation rate can be changed; this analysis will show what 0% and 2% inflation will look like; and 3) the time period of training data used to generate the distribution of daily changes in the market; this analysis will show what using 1927-2023, 1946-2023, and 1970-2023 as training data periods would look like.

### Different Training Data Periods
Before diving into the results in full, let's make things simpler by choosing just one time period to using training data. The three options selected are 1927-2023 (because this is the most data), 1946-2023 (because this excludes volatility from the Great Depression and WWII), and 1970-2023 (assuming that more recent decades of market trends will be more informative of the future than decades further back in the past). At first glance, it did not appear that shifting the training data period would have a large effect on the results. This box plot shows the distribution of the annual growth from three time periods.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/boxplot.png)

For those wanting to be more precise with this, here is a table showing different points in each distrutions daily growth rates.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/dist_table.png)

However, when running the simulation of the 4% withdrawl rule, assuming no inflation, there are noticeable differences. This graph shows that using training data from 1927 puts the probability of a successful 30-year retirement at about 83% (5 out of 6 times), while training data from 1946 puts the probability of a successful 30-year retirement at close to 95% (19 out of 20 times). My hypothesis for why 1927 does so poorly is because the years of the Great Depression must have dragged down the market in the simulation. 1970 likely does slightly worse than 1946 because it is not informed by strong market conditions in the 1950s and 1960s. 

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/training.png)

In order to give the 4% withdrawl rule the best shot of being a sound retirement strategy, this analysis will only use training data from 1946-2023 going forward.

## Results



### Different Withdrawl Rates


![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/withdrawl.png)

### Bringing in Inflation

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/inflation3.png)
![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/inflation4.png)
![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/inflation5.png)

## Conclusion
3% rule, sorry.
