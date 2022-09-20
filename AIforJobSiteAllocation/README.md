What if we can use AI to predict what is the best site where the glidein should be spawned?
Some sites give information about the number of resources that are going to provide for the job, while some others don’t.
We want to allocate the glidein to the site that provide the largest amount of resources while minimizing the probability of failure.
- Predict the amount of CPU and Memory that is going to be provided from each site: 𝐶𝑃𝑈𝑃𝑟𝑜𝑣𝑖𝑑𝑒𝑑,𝑀𝑒𝑚𝑜𝑟𝑦𝑃𝑟𝑜𝑣𝑖𝑑𝑒𝑑
- Consider the sites for which the resources provided are enough for our job: 𝐶𝑃𝑈𝑅𝑒𝑞𝑢𝑒𝑠𝑡𝑒𝑑 ≤ 𝐶𝑃𝑈𝑃𝑟𝑜𝑣𝑖𝑑𝑒𝑑 and 𝑀𝑒𝑚𝑜𝑟𝑦𝑅𝑒𝑞𝑢𝑒𝑠𝑡𝑒𝑑 ≤ 𝑀𝑒𝑚𝑜𝑟𝑦𝑃𝑟𝑜𝑣𝑖𝑑𝑒𝑑.
- Calculate the probability of failure of each site: 𝑃_𝑓𝑎𝑖𝑙𝑢𝑟𝑒
- Calculate a cumulative score that allows us to take this decision

The memory and CPU amount forecasting is performed using a time series analysis (analysis in the time_series_analysis folder).
The probability calculation and failure prediction is performed with probablistic classifiers (analysis in the classification folder).
A scraper script is present in order to extract data.

Datasets can be found at: https://zenodo.org/record/7097223#.YynPwi9aZQI.
Download the datasets and place them in the data folder. 
The raw dataset should be autonomously scraped.
