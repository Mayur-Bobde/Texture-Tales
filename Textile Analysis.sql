select * from product_details;
select * from product_hierarchy;
select * from product_prices;
select * from product_sales;

-- 1.What was the total quantity sold for all products?
select ps.prod_id, pd.product_name, sum(ps.qty) as total_quantity_sold from product_sales ps
join product_details pd on pd.product_id= ps.prod_id
group by 1,2
order by 3 desc;


-- 2. What is the total generated revenue for all products before discounts?
select ps.prod_id, pd.product_name, sum(ps.qty*ps.price) as total_revenue from product_sales ps
join product_details pd on pd.product_id= ps.prod_id
group by 1,2
order by 3 desc;


-- 3.	What was the total discount amount for all products?
select ps.prod_id, pd.product_name, sum(ps.qty*ps.price*ps.discount)/100 as total_discount from product_sales ps
join product_details pd on pd.product_id= ps.prod_id
group by 1,2
order by 3 desc;


-- 4.How many unique transactions were there?
select count(distinct(txn_id)) as unique_transactions from product_sales;


-- 5.What are the average unique products purchased in each transaction?
with CTE as (select txn_id, count(distinct(prod_id)) as product_count from product_sales
group by 1)
select round(avg(product_count),0) as unique_product_count from cte;


-- 6.What is the average discount value per transaction?
With CTE as (select txn_id, sum(qty*price*discount)/100 as discount from product_sales
group by 1)
select round(avg(discount),2) as avg_discount_value from cte;


-- 7.What is the average revenue for member transactions and non-member transactions?
with CTE as (select txn_id, member , sum(qty*price) as revenue from product_sales 
group by 1,2)
select member,round(avg(revenue),1) as Avg_revenue from CTE
group by 1; 

-- 8.What are the top 3 products by total revenue before discount?
## FIRST APPROCH 
select ps.prod_id, pd.product_name, sum(ps.qty*ps.price) as total_revenue from product_sales ps
join product_details pd on pd.product_id= ps.prod_id
group by 1,2
order by 3 desc
limit 3;

## SECOND APPROCH
SELECT prod_id, product_name, total_revenue 
FROM (
SELECT ps.prod_id, pd.product_name, SUM(ps.qty * ps.price) AS total_revenue, 
RANK() OVER ( ORDER BY SUM(ps.qty * ps.price) DESC) AS revenue_rank FROM product_sales ps
JOIN product_details pd ON pd.product_id = ps.prod_id
GROUP BY ps.prod_id, pd.product_name
) subquery
WHERE revenue_rank <= 3;

-- 9.What are the total quantity, revenue and discount for each segment?
select pd.segment_name, sum(ps.qty) as quantity, sum(ps.qty*ps.price) as revenue, sum(ps.qty*ps.qty*ps.price) as discount from product_sales ps 
join product_details pd on pd.product_id = ps.prod_id
group by 1;


-- 10.What is the top selling product for each segment?
with CTE as (
select pd.segment_name, pd.product_name,sum(ps.qty),rank() over(partition by pd.segment_name order by sum(ps.qty) desc) as rnk from product_details pd
join product_sales ps on ps.prod_id = pd.product_id
group by 1,2)
select segment_name, product_name from CTE
where rnk=1;












