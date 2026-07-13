show  databases
use walmart_data

show tables
select * from walmart
select payment_method, count(*) from walmart group by payment_method
select count(*) from walmart
select count(distinct Branch) from walmart
select max(quantity) from walmart

-- Business Problems
-- Q.1 Find different payment methods and number of transactions, number of quantity sold
select 
	payment_method, 
    count(*) as n_payments,
    sum(quantity) as n_qty_sold
from walmart 
group by payment_method

-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category and avg rating.

select *
from
(	select
		Branch,
		category,
		avg(rating) as avg_rating,
        rank() over(partition by Branch order by avg(rating) desc) as rnk
	from walmart
	group by Branch, category
) as r
where rnk = 1

-- Q.3 Identify the busiest day for each branch based on the number of transactions.

select *
from
(select 
	Branch,
    DAYNAME(str_to_date(date, '%d/%m/%y')) as day_name,
    count(*) as n_transactions,
    rank() over(partition by Branch order by count(*) desc) as rnk
from walmart
group by Branch, day_name
) as r
where rnk=1

-- Q.4 Calculate the total quantity of items sold per payment method. List payment method and total quantity.

select 
	payment_method, 
    sum(quantity) as n_qty_sold
from walmart 
group by payment_method

-- Q.5 Determine the average, minimum and maximum rating of products for each city. 
-- List the city, average_rating, min_rating and max_rating.

select 
	City,
	category,
    min(rating) as  min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by City, category
	
-- Q.6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

select
	category,
    sum(total),
    sum(total * profit_margin) as profit
from walmart
group by category
order by profit desc

-- Q.7 Display the most common payment method for each branch. Display branch and preferred payment method.

with cte
as
(select
	Branch,
    payment_method,
    count(*) as total_trans,
    rank() over (partition by branch order by count(*) desc) as rnk
from walmart
group by Branch, payment_method
)
select *
from cte
where rnk=1

-- Q.8 Catgorise sales into 3 group Morning, Evening and Afternoon. Find out each of the shift and number of invoices

SELECT
    branch,
    CASE
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_orders
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, total_orders DESC;

-- Q.9 Identify 5 branch with highest decrease ratio in revenue complre to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
