ALTER TABLE walmart_sales RENAME COLUMN "Branch" TO branch; --Renaming the column

select * from walmart_sales

select count(*) from walmart_sales --Count Number of Rows

select distinct(payment_method) from walmart_sales --Distinct Type of payment method

select
	payment_method,
	count(*)
from walmart_sales
group by payment_method



select distinct branch,count(*) from walmart_sales
group by branch

select min(quantity) from walmart_sales

--Q1.Find different payment method and number of transaction, number of qty sold
select
	payment_method,
	count(*) as Number_of_Payments,
	sum(quantity) as Quantity_Sold
from walmart_sales
group by payment_method


select sum(quantity) from walmart_sales  --Calculate Total Quanity

--Q2. Identify the highest-rated category in each branch, displaying the branch, category
-- AVG Rating
select * 
from ( 	select 
		branch,
		category,
		avg(rating) as avg_rating,
		rank() over(partition by branch order by avg(rating)desc) as rank
	from walmart_sales
	group by 1,2
) as sub	
where rank = 1

--order by 1, 3 desc


-- Q3. Identify the busiest day for each branch based on the number of transactions.

--CONVERT THE DATE FORMATED
select 
	date,
	TO_DATE(date,'DD-MM-YY') as formated_date
from walmart_sales

-- Now extracting day name from the date
select 
	date,
	TO_CHAR(TO_DATE(date,'DD-MM-YY'),'day') as day_name
from walmart_sales

select *
from(
select
	branch,
	TO_CHAR(TO_DATE(date,'DD-MM-YY'),'day') as day_name,
	count(invoice_id) as Number_of_Trans,
	rank() over(partition by branch order by count(invoice_id) desc) as rank
from walmart_sales
group by 1,2
	) as sub
where rank = 1
--order by 1,3 desc

-- Q4. Determinve the average, minimum, and maximum rating of category for each city . List the city, 
-- average_rating, min_rating, and max_rating.

select * from walmart_sales


select *
from
(
select 
	city,
	category,
	avg(rating),
	rank() over(partition by city order by avg(rating) desc) as rank
	from walmart_sales
group by 1,2
) as sub
where rank = 1
-- order by 1,3 desc

select 
	city,
	category,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
from walmart_sales
group by 1, 2
order by 1


-- Q5. Calculate the total profit for each category by considering 
-- total Profit as (unit_price * quantity  * profit_margin).
-- List Category and total_profit, ordered from highest to lowest profit.

select 
	category,
	round(sum("Total_Price" * profit_margin)::numeric,3) as total_profit --casting in numeric
from walmart_sales
group by category
order by 2 desc

-- Q6 Determine the most common payment method for each branch. 
-- Display branch and the preferred_payment_method.

select * 
from
(
select 
	branch,
 	payment_method,
	count(payment_method),
 	rank() over(partition by branch order by count(payment_method)desc) as rank
from walmart_sales
group by 1,2
) as sub
where rank = 1

-- order by 1


-- Q7. Categorize sales into 3 group morning, afternoon, evening.
-- find out which of the shift and number of invoices

select * from walmart_sales

select 
time::time
from walmart_sales

select 
	branch,
	count(invoice_id),
	CASE
		WHEN EXTRACT(HOUR FROM time::time)<12 THEN  'Morning'
		WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'AfterNoon'
		ELSE 'Evening'
	END AS shift
From walmart_sales
group by 1,3
order by 1,2


-- Q8. Identify 5 branch with highest decrease ration in 
-- revenue compare to last year (current year 2023 and last year 2022)

select * from walmart_sales
-- Extract Year from Date
SELECT 
	 date,
 	 EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) AS year
FROM walmart_sales


--Extract  Revenue for Each Both the Year 2022 and 2023
SELECT 
	 branch,
	 sum("Total_Price") as Revenue,
 	 EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) AS year
FROM walmart_sales
where EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) between 2022 and 2023
group by 1,3


--Solution
with revenue_2022
as
(
SELECT 
	 branch,
	 sum("Total_Price") as Revenue
FROM walmart_sales
where EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) =2022
group by 1
),

revenue_2023
as
(
SELECT 
	 branch,
	 sum("Total_Price") as Revenue
FROM walmart_sales
where EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) =2023
group by 1
)

select 
	ls.branch,
	ls.revenue,
	cs.revenue,
	round((ls.revenue-cs.revenue)::numeric/ls.revenue::numeric * 100 ,2) as rev_dec_ratio
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue>cs.revenue
order by 4 desc
limit 5