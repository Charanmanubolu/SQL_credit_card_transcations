select * from credit_card_transcations;

/*
write a query to print top 5 cities with highest spends and their 
percentage contribution of total credit card spends 
*/
WITH city_totals AS (
SELECT
city,
SUM(amount) AS total_city_spend
FROM credit_card_transcations
GROUP BY city
),
ranked_cities AS (
SELECT
city,
total_city_spend,
RANK() OVER(ORDER BY total_city_spend DESC) AS spend_rank,
CAST((total_city_spend * 1.0 / SUM(CAST(total_city_spend AS BIGINT)) OVER()) * 100 AS DECIMAL(10,2)) AS pct_contribution
FROM city_totals
)
SELECT
city,
total_city_spend,
pct_contribution
FROM ranked_cities
WHERE spend_rank <= 5;

-- write a query to print highest spend month and amount spent in that month for each card type

WITH MonthlyCardTotals AS (
    SELECT
        card_type,
        DATEPART(YEAR, transaction_date) AS transaction_year,
        DATEPART(MONTH, transaction_date) AS transaction_month,
        SUM(amount) AS total_amount
    FROM credit_card_transcations
    GROUP BY 
        card_type, 
        DATEPART(YEAR, transaction_date), 
        DATEPART(MONTH, transaction_date)
),
RankedMonthlyTotals AS (
    SELECT
      *,
        RANK() OVER(PARTITION BY card_type ORDER BY total_amount DESC) AS amount_rank
    FROM MonthlyCardTotals
)
SELECT 
    card_type,
    transaction_year,
    transaction_month,
    total_amount
FROM RankedMonthlyTotals
WHERE amount_rank = 1;

/*
 write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
*/
WITH CumulativeSpends AS (
    SELECT 
        *,
        SUM(amount) OVER(PARTITION BY card_type ORDER BY transaction_date,transaction_id ) AS running_total
    FROM credit_card_transcations
),
RankedMilestones AS (
    SELECT 
        *,
        RANK() OVER(PARTITION BY card_type ORDER BY running_total) AS milestone_rank
    FROM CumulativeSpends 
    WHERE running_total >= 1000000
)
SELECT * FROM RankedMilestones 
WHERE milestone_rank = 1;


-- write a query to find city which had lowest percentage spend for gold card type

WITH CityGoldSpends AS (
    SELECT 
        city, 
        SUM(amount) AS city_total_amount
    FROM credit_card_transcations 
    WHERE card_type = 'Gold'
    GROUP BY city
)
SELECT TOP 1 
    city,
    city_total_amount,
    (city_total_amount * 1.0 / SUM(city_total_amount) OVER()) * 100 AS spend_percentage
FROM CityGoldSpends 
ORDER BY spend_percentage ASC;

/*
write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type 
(example format : Delhi , bills, Fuel)
 */
WITH CityExpenseTotals AS (
    SELECT 
        city,
        exp_type,
        SUM(amount) AS total_amount
    FROM credit_card_transcations
    GROUP BY city, exp_type
),
RankedCityExpenses AS (
    SELECT 
        city,
        exp_type,
        total_amount,
        RANK() OVER(PARTITION BY city ORDER BY total_amount ASC) AS lowest_spend_rank,
        RANK() OVER(PARTITION BY city ORDER BY total_amount DESC) AS highest_spend_rank 
    FROM CityExpenseTotals
)
SELECT 
    city,
    MAX(CASE WHEN highest_spend_rank = 1 THEN exp_type END) AS highest_expense_type,
    MAX(CASE WHEN lowest_spend_rank = 1 THEN exp_type END) AS lowest_expense_type
FROM RankedCityExpenses
GROUP BY city
ORDER BY city;


