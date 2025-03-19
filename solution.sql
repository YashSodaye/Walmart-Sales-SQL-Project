select count(*) from walmart

--drop table walmart

--Exploratory Data Analysis (EDA) with SQL

select * from walmart

select distinct payment_method 
from walmart

select 
	payment_method, 
	count(*) as total_count
from walmart
group by payment_method

select count(distinct Branch)   -- column name by default converted into lower case so we've to change the column name 
from walmart					-- with lower case , so drop table in line 3

select count(distinct branch)	-- after changing the column name in lower case using pandas in python
from walmart					-- and again the data is imported

select max(quantity)
from walmart

select min(quantity)
from walmart

select distinct city
from walmart

select count(distinct city)
from walmart

select distinct category
from walmart

select count(distinct category)
from walmart

select max(unit_price)
from walmart

select min(unit_price)
from walmart

select max(rating)
from walmart

select 
	rating,
	count(*)
from walmart
group by rating
order by rating desc

select 
	profit_margin,
	count(*)
from walmart
group by profit_margin
order by profit_margin desc

select max(total)
from walmart

--Business Problems

select * from walmart

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method

select 
	payment_method,
	count(*) as total_number_of_transaction,
	sum(quantity) as total_no_quantity_sold
from walmart 
group by payment_method

-- Project Question #2: Identify the highest-rated category in each branch, Display the branch, category, and avg rating

select *
from
(
	select
		branch,
		category,
		avg(rating) as avg_rating,
		rank() over(partition by branch order by avg(rating) desc) as rank
	from walmart
	group by 1,2
)
where rank = 1

-- Q3: Identify the busiest day for each branch based on the number of transactions

select *
from
	(
		select 	
			branch,
			to_char(to_date(date,'DD/MM/YY') , 'day')as day_name,
			count(*) as no_of_transactions,
			rank() over(partition by branch order by count(*) desc) as rank
		from walmart
		group by 1,2
	)
where rank = 1

-- Q4: Calculate the total quantity of items sold per payment method

select
	payment_method,
	sum(quantity) as total_item_sold
from walmart
group by 1

-- Q5: Determine the average, minimum, and maximum rating of categories for each city

select 
	city,
	category,
	avg(rating) as avg_rating,
	min(rating) as min_rating,
	max(rating) as max_rating
from walmart
group by 1,2

-- Q6: Calculate the total profit for each category by considering total profit as
-- (unit_price * quantity * profit_margin)
-- List the category and total_profit , ordered from highest to lowest profit.

select
	category,
	sum(total) as total_revenue,
	sum(total * profit_margin) as profit
from walmart
group by 1


-- Q7: Determine the most common payment method for each branch

select *
from
	(
		select
			branch,
			payment_method,
			count(*),
			rank() over(partition by branch order by count(*) desc) as rank
		from walmart
		group by 1,2
	)
where rank = 1

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
-- Find out which of the shift and number of invoices

select 
	branch,
case
		when extract(hour from(time::time)) < 12 then 'Morning'
		when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end day_time,
	count(*)
from walmart
group by 1,2
order by 1,3 desc

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year 
--(e.g., 2022 to 2023)

select * from walmart

with revenue_2022
as
(
	select
		branch,
		sum(total) as revenue
	from walmart 
	where extract(year from to_date(date,'DD-MM-YY')) = 2022
	group by 1
),

revenue_2023
as 
(
	select
		branch,
		sum(total) as revenue
	from walmart 
	where extract(year from to_date(date,'DD-MM-YY')) = 2023
	group by 1
)

select
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	round(
		(ls.revenue-cs.revenue)::numeric /
		ls.revenue::numeric * 100,
		2) as rev_dec_ratio
from revenue_2022 as ls	
join
revenue_2023 as cs
on ls.branch = cs.branch
where 
	ls.revenue > cs.revenue
order by 4 desc
limit 5