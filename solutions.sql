select * from credit_card_transcations;

select distinct city from credit_card_transcations;
select distinct card_type from credit_card_transcations;
select distinct exp_type from credit_card_transcations;
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


