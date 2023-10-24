use [SalesData.db];

select
	*
from
	pizza_sales$;

-- perfroming EDA on Pizza Sales based on the following problem statements

--1, Total Revenue

select
	round(sum(total_price),0) as Revenue
from
	pizza_sales$;
	


--2, Average Order value

select
	round(sum(total_price)/ count(distinct order_id),2) as order_value
from
	pizza_sales$;
	

--3, Average pizzas per order

select
	 round(sum(quantity) /count(distinct order_id),2) as pizzas_sales
from
	pizza_sales$;


--4, Percentage of sales of top 10 pizza and their pizza size contributions

select
	top(10)pizza_name,
	count(order_id) as total_orders,
	100 * sum(case when pizza_size = 'XXL' then 1 else 0 end)/count(order_id) as XXL_size_sales,
	100 * sum(case when pizza_size = 'XL' then 1 else 0 end)/count(order_id) as XL_size_sales,
	100* sum(case when pizza_size = 'L' then 1 else 0 end)/count(order_id) as large_size_sales,
	100 * sum(case when pizza_size = 'M' then 1 else 0 end)/count(order_id) as medium_size_sales,
	100 * sum(case when pizza_size = 'S' then 1 else 0 end)/count(order_id) as small_size_sales

from
	pizza_sales$
group by
	pizza_name
order by
	2 desc;


--5, Total Pizzas sold by pizza category

select
	pizza_category,
	SUM(quantity) as total_pizzas
from
	pizza_sales$
group by
	pizza_category
order by
	2 desc;


--6, Top 5 best sellers by total pizzas sold

select
	top(5)pizza_name,
	sum(quantity) as pizzas_sold
from
	pizza_sales$
group by
	pizza_name
order by
	2 desc;


--7, Bottom 5 Worst sellers by total pizzas sold
select
	top(5)pizza_name,
	sum(quantity) as pizzas_sold
from
	pizza_sales$
group by
	pizza_name
order by
	2 asc;

--8, MoM change in pizza sales with respect to 4 types of pizzas

select * from pizza_sales$;

select
	month(order_date) as Month,
	pizza_name,
	round(sum(total_price),2) as revenue,
	lag(sum(total_price)) over(order by month(order_date)) as prev_month_sales,
	round(100* (sum(total_price) - lag(sum(total_price)) over(partition by pizza_name order by month(order_date)))/lag(sum(total_price)) over(order by month(order_date)),2) as MoM_Change
from
	pizza_sales$
where
	pizza_name in ('The Mediterranean Pizza','The Mexicana Pizza','The Hawaiian Pizza','The Four Cheese Pizza')
group by
	month(order_date),
	pizza_name;
	
--9, Busiest day of the week: which day of the week there was highest number of pizza ordered

select
	datename(dw,order_date) as day_of_week,
	count(order_id) as total_orders
from
	pizza_sales$
group by
	datename(dw,order_date)
order by
	2 desc; 


-- some more questions for analysis:

-- Most Popular Pizza: Analyze the "pizza_name" column to determine which pizza name or category is ordered the most frequently.

select * from pizza_sales$;

select
	pizza_category,
	pizza_name,
	sum(quantity) as total_ordered,
	RANK() over(partition by pizza_category order by sum(quantity) desc) as rank_num
from
	pizza_sales$
group by
	pizza_name,pizza_category;


--Preferred Pizza Size: Determine the most commonly ordered "pizza_size" to understand customer preferences.
select
	datename(dw,order_date) as day_of_week,
	pizza_size,
	sum(quantity) as pizzas_sold,
	row_number() over(partition by datename(dw,order_date)  order by sum(quantity) desc) as row_num
from
	pizza_sales$
group by
	datename(dw,order_date), pizza_size
order by
	3 desc;
	

--Pizza Category Breakdown: Calculate the distribution of orders across different "pizza_category" types to see which categories are most popular.
select * from pizza_sales$;

select
	pizza_category,
	count(order_id) as total_orders
from
	pizza_sales$
group by
	pizza_category
order by
	2 desc;

--Top Selling Pizza Ingredients: Analyze the "pizza_ingredients" column to identify the most frequently used pizza ingredients.

select
	top(10)pizza_ingredients,
	count(order_id) as total_orders
from
	pizza_sales$
group by
	pizza_ingredients
order by
	2 desc;

--Time Analysis: Analyze the "order_time" to determine peak ordering hours or time periods.
select
	datepart(hour,order_time) as hour_of_the_day,
	count(order_id) as total_orders
from
	pizza_sales$
group by
	datepart(hour,order_time)
order by
	2 desc;

--Day and Time Analysis: Which Day of the week and at what time does the orders saw a peak.
select
	datename(dw,order_date) as day_of_week,
	datepart(hour,order_time) as hour_of_the_day,
	count(order_id) as total_orders,
	dense_rank() over(partition by datename(dw,order_date) order by count(order_id) desc) as rank_num
from
	pizza_sales$
group by
	datename(dw,order_date), datepart(hour,order_time);

--Customer Retention: Analyze the frequency of repeat "order_id" entries to understand customer loyalty and retention.
select * from pizza_sales$;

select
	distinct(order_id) as order_no,
	count(order_id) as no_orders
from
	pizza_sales$
group by
	order_id
order by
	2 desc;

with first_view as(
select
	order_id as order_no,
	min(order_date) as first_order_date
from
	pizza_sales$
group by
	order_id
)

select
	ps.*,
	fv.first_order_date,
	case when fv.first_order_date = ps.order_date then 1 else 0 end as first_flag,
	case when fv.first_order_date != ps.order_date then 1 else 0 end as repeat_flag
from
	pizza_sales$ ps
join
	first_view fv on order_no = order_id;
	

	


--Average Quantity per Order: Calculate the average quantity of pizzas ordered per order to understand customer buying behavior.
select
	pizza_name,
	sum(quantity)/count(order_id) as quantity_per_order
from
	pizza_sales$
group by
	pizza_name
order by
	2 desc;
	

--Price Sensitivity Analysis: Analyze how changes in "unit_price" or "total_price" affect order quantities and revenue.
select
	piza


--Revenue by Pizza Size: Calculate the revenue generated from each "pizza_size" to identify popular sizes and pricing segments.
select
	*,
	dense_rank() over(order by revenue desc) as rank_num
from
(
select
	distinct(pizza_name),
	(pizza_size),
	sum(total_price) over(partition by pizza_name,pizza_size) as revenue
from
	pizza_sales$
) as row_level;


--Ingredient Combination Analysis: Identify unique or popular "pizza_ingredients" combinations that are frequently ordered.
select * from pizza_sales$;

select
	top (10) (pizza_ingredients),
	count(order_id) as total_orders
from
	pizza_sales$
group by
	pizza_ingredients
order by
	2 desc;

--Seasonal Trends: Identify seasonal patterns in ordering behavior based on "order_date

select
	distinct(month) as month_no,
	pizza_name,
	total_orders
from
(
select
	pizza_name,
	month(order_date) as month,
	count(order_id) as total_orders,
	dense_rank() over(partition by pizza_name order by count(order_id) desc) as rank_num 
from
	pizza_sales$
group by
	pizza_name, month(order_date)
) as row_level
where
rank_num = 1
order by
	month asc;

-- These are the names of pizzas that were sold highest in the month
