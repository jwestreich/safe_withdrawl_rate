# Probabilistic Forecasting to Assess Validity of 4% Withdrawl Rule for Retirement

Some late night in college, I fell down a YouTube rabbit hole about [FIRE](https://en.wikipedia.org/wiki/FIRE_movement). FIRE stands for Financially Independent, Retire Early. The idea goes like this: sacrifice as much as you can when you start working in order to save and invest as much money as you can as quickly as possible; figure out how much money you would like to live on annually in retirement; save/invest until you have 25x that amount; stop working; withdraw only 4% of your savings each year, and you should be able to safely have a 30-year retirement. This idea has had validity in the personal finance community for several years because of some analysis of stock market trends over the past several decades. It has been demonstrated that there has *never* been a 30-year period where this would have failed. Even if you stopped working at the peak of the market, right before a crash, and consistently only withdrew 4% of your savings each year, you would have enough money to last 30 years.

While this analysis used methods that I'm sure the original creators of it believed was sound, there has been one significant limitation: the analysis is deterministic, instead of probabilistic. These methods assume that the stock market in the future will move in the exact same ways that they have in the past. While the past is informative of the future, it is not the future itself. Instead, the analysis in this repository is probabilitic: the past performance of the stock market is used to create many different simulations of what the future stock market could do. With enough simulations, a probability of success can be calculated for the 4% withdrawl rule, as well as some variants and changing some assumptions.

## Methods
### Creating a Forecast of the Stock Market
Let's define what measure of the stock market we're going to use. Most Americans use mutual funds, target retirment funds, or bonds (usually a combination of these) for their retirement savings. For this analysis, we are going to use *just* the growth of the S&P 500 as a measure of the general "market" that Americans are investing in for their retirement. This is one of the limitations of this analysis. There were too many risk-levels someone retiring could have that would influence what their savings would be in. Target retirement funds can have significant amounts of their assets in bonds, espcially as the target date gets closer. In future versions of this analysis, I would like to incorporate lower-risk investing strategies. For now, we will go forward with just investing in the S&P 500, knowing that this may make the forecast more volatile than expected.

The daily closing value of the S&P 500 can be imported into R. This is where we can use the past to inform our forecast of the future. Every day, the value of the S&P 500 moves by a measurable amount. Usually, the daily change is very small. I calculated the daily change of every day since the end of 1927 to fall of 2023. This was used to create a distribution of daily changes of the market. The histogram shows that most of the daily changes are right around 0 (note: the histogram shows the distribution from 1946-2023; more on that in the next section). Anything greater than a 3% change (positive or negative) in a single day is very rare. 

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/hist_1946.png)

With all these daily changes, I assigned each day a random integer from 1 to the total number of observations I had in my dataset (without replacement). Then, I created a table with a row for each day the stock market was open for the next 50 years (removing all weekends and NYSE-recognized holidays). I also assigned each of these days a random integer with the same range as before (with replacement). We can do a left merge on this dataset of the future to the table of daily changes in the market. Now, each day in the future for the next 50 years has a random daily change in the market. Daily change amounts that were more common in the past are going to be more common in this forecast. Here are 10-year, 30-year, and 50-year views of 10 examples. The black line in the graphs shows what a constant 7% annual growth would look like, for some context.

![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/example_10yr.png)
![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/example_30yr.png)
![](https://github.com/jwestreich/safe_withdrawl_rate/blob/main/sp500_dist_graphs/example_50yr.png)

### Simulating a Retirement
Now we can run a simulation. Let's assume a person has some random amount of money (we can just use 1 million dollars to keep things simple, the amount won't matter). All of that money is invested in the S&P 500, and every day the value of their savings will change based on the forecasted market. The only other time the value changes is on the first of each month, when they withdraw one twelfth of 4% of the amount they started at ($3,333.33 for our simulated one million dollars). We can also adjust the withdrawl amount with inflation. As long as the value stays above zero dollars, the retiree is successfully using the withdrawl rate rule. If the value ever drops to below zero dollars, the retiree is not successfully using the withdrawl rate rule.

There are three parameters that can be changed in the simluation: 1) the withdrawl rate can be changed, this analysis will show what a 3%, 4%, and 5% withdrawl rate will look like; 2) the inflation rate can be changed; this analysis will show what 0% and 2% inflation will look like; and 3) the time period of training data used to simulate 

To get a good picture of the probability, for each

### Different Training Data Periods

## Results



### Different Withdrawl Rates


### Bringing in Inflation


## Conclusion
