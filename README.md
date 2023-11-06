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

First, let's look at the results of the withdrawl rates, using training data form 1946-2023 and assuming no inflation. As we would expect, the safest withdrawl rate of 3% has the highest chance of probability at any point in a 50-year retirement, followed by the 4% withdrawl rate, and then the 5% withdrawl rate. The graph bolds the line at a 30-year retirement, so it's easy to see the probability of making a 30-year retirement work for each of these withdrawl rates. The 3% withdrawl rate has almost a 99% chance of lasting at least 30 years (failing 1 out of 100 times), the 4% withdrawl rate has just shy of a 95% chance of lasting at least 30 years (failing 1 out of 20 times), and the 5% withdrawl rate has about an 85% chance of lasting at least 30 years (failing 1 out of every 6 or 7 times).

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/withdrawl.png)

So far, this analysis bodes well for the 4% withdrawl rule. Even though it is not a guarantee that this withdrawl rate will last 30 years, neither is the more conservative withdrawl rate of 3%. The only way to really *guarantee* to not run out of money is to never spend more than you make. If the stock market can't provide guaranteed returns, there may be times to spend more than you make. If the market downturn happens for too long, a retirement can fail at any time. A 95% chance of success lends itself well to a comparison of statistical signifcance testing. In statistical testing, a relationship is found to be "[statistically significant](https://en.wikipedia.org/wiki/P-value)" if there is at least a 95% probability that the relationship did not happen by random chance. If the 4% withdrawl rule can hit that ever-sought-after 95% confidence, it's good enough for me.

### Bringing in Inflation

The problem with the above results were that they did not take into account the effect of inflation. Inflation has different and nuanced effects on the growth of the market. I'm going to assume that by capturing periods of both high and low inflation in the training data, I won't need to worry about this affect on how market growth was simulated. However, the amount withdrawn each month by the retiree will need to be adjusted.

In the first simulations, it was assumed that the retiree would calculate 4% of their savings, and withdraw one twelfth of that every month. If the cost of living went up by 10% one year, the amount withdrawn would stay constant. This isn't very realistic.

To compensate for that, I reran the simulations, this time adjusting the amount withdrawn each year. Now, instead of a constant amount, each year, the amount increases by 2% ([the Federal Reserve's target inflation rate](https://www.federalreserve.gov/faqs/economy_14400.htm)). If the retiree starts with one million dollars, they can withdraw ($1,000,000 * 4% withdrawl / 12 month) = $3,333 each month. In the next year, they can withdraw ($3,333 + ($3,333 * 2%)) = $3,400. This will go on until they run out of money. After 30 years, the monthly withdrawl amount would have gone from $3,333 to $6,037, nearly doubling. This will make having a successful retirement harder as time goes on.

The 3% rule is exactly where we want it to be. The 30-year mark is right at 95% chance of success, even after taking into account inflation. Increasing inflation from 0% to 2% brought the chance of success at 30 years down by 4 percentage points. We can also see that this shift is not parallel: in the first 15 years of retirement, there is almost no shift at all; the shift grows to 4 points by 30 years, and then hits about 10 points at 50 years. This is because the 2% inflation rate has a compounding effect. A 2% increase won't seem like much in the beginning, but over time, even that small rate can start to really add up.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/inflation3.png)

The shift is more dramatic for the 4% withdrawl rate. At 30 years, the chance of success moves from 95% with no inflation to less than 85% with 2% inflation. This means that applying the 4% rule, under these conditions, will result in a retirement that lasts 30 years about five in six times.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/inflation4.png)

The story is even worse for the 5% rule: with inflation, only a 68% chance of success. If you tried using the 5% withdrawl rule, assuming constant 2% inflation, you would only be able to last 30 years about two out of three times. If you wanted to stretch it out to 50 years, it's about 50-50.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/simulation_graphs/inflation5.png)

## Limitations
Here are some limiations of this analysis:

* Only using S&P 500 growth to predict growth of retirement savings, forgetting about target retirement funds and bonds, which may be safer investments
* Assuming a constant 2% rate of inflation, instead of trying to probabilistically forecast inflation in a similar fashion to forecasting market growth
* Not taking into account the possibility of Social Security income or other types of income during retirement

## Conclusion

While there are certainly some limitations to this first version of analysis, the results seem reasonable enough to justify using a probabilistic analysis to complement the already done deterministic analysis. Other recent financial analysts have indicated that the 4% rule may be outdated, with one analysis by [Morningstar](https://www.cnbc.com/2021/11/11/the-4percent-rule-a-popular-retirement-income-strategy-may-be-outdated.html) in particular advocating for a 3.3% withdrawl rule (which is pretty close to what this analysis concluded).

My goal with this analysis was to expand the methods used to evaluate the usefulness of the 4% rule, and help inform people how much money they may need to retire. While I may have talked about 30-year retirements in this write-up because that is a conventional "standard" retirement length, I've stretched the visuals out to 50 years. If someone is looking at an early retirement (if you're reading a GitHub README file about the 4% rule, you probably are), 30 years may not be enough. Hopefully the information here is enough to provide results to make a more informed decision about the right time to retire.

Again, this is only the start. I hope to continue this analysis to bridge some of the gaps created by the limitations. For now, here is my final, affirmative conclusion:
**If your entire retirement savings are in the S&P 500, you withdraw 3% of that starting amount per year, increasing the amount by 2% each year, there is a 95% chance that your retirement will last at least 30 years.**
