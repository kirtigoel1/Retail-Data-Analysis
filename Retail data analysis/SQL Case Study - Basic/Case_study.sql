--Data Preparation and Understanding

---Q1---
select  'Customer$' as tbl_name , count(*) as no_of_records from Customer$
Union ALL
select 'prod_cat_info$' ,count(* )from prod_cat_info$
Union all
select 'transactions$', count(*) from Transactions$

--Q2--

select count(transaction_id)
as return_transactions from Transactions$
where total_amt <0

--Q3--

select
convert(date,tran_date, 105) as 
converted_date 
from Transactions$

--Q4--
select 
datediff(YEAR,min(tran_date),max(tran_date))as _years,
datediff(month,min(tran_date),max(tran_date))as _months,
datediff(day,min(tran_date),max(tran_date))as _days
from Transactions$

--Q5--
select prod_cat 
from prod_cat_info$
where 
prod_subcat in (select prod_subcat from prod_cat_info$ where prod_subcat = 'DIY')




---data analysis---

--Q1--
select top 1 
Store_type,
count(*)
 from 
 Transactions$
group by Store_type
order by 1

--Q2--

select gender, 
count(Gender)
 from Customer$
 group by gender

 --Q3--

select city_code , 
count(customer_id) as CNT 
from Customer$
 group by city_code
 order by count(customer_id) desc

 --Q4--
 
 select 
 count (prod_subcat) as Cnt 
 from 
 prod_cat_info$
 where prod_cat = 'books'


--Q5--

select
max(Qty) 
as max_order_quantity
from Transactions$ 



---Q6 What is the net total revenue generated in categories Electronics and books--

 SELECT  prod_cat , sum(total_amt-Tax) as Net_Revenue FROM prod_cat_info$ a
 inner join Transactions$ b
 on a.prod_cat_code = b.prod_cat_code 
 and a.prod_sub_cat_code = b.prod_subcat_code
 where prod_cat in ('books' , 'Electronics')
 group by prod_cat 


Q7-- How many customers have >10 transactions with us, excluding returns?--

select a.customer_id ,
count(transaction_id)cnt 
from 
Customer$ A
INNER JOIN
Transactions$ B
ON A.customer_Id = B.cust_id 
where Qty > 0
group by a.customer_id 
having  count(transaction_id) >10 

-- 8. what is the combined revenue earned from the electronics and clothing from flagship stores.

select
sum(total_amt) as Combined_Revenue 
from
transactions$ a
inner join prod_cat_info$ b 
on
a.prod_cat_code = b.prod_cat_code
and 
a.prod_subcat_code = b.prod_sub_cat_code
where 
prod_cat in ('Electronics', 'Clothing') 
and Store_type = 'flagship store'

/* 9. what is the total revenue generated from male in electronics category ? 
output should display total revenue by product sub-cat */

 select prod_subcat ,
 sum(total_amt)as total_revenue 
 from 
 Customer$ a
 inner join
 Transactions$ b
 on a.customer_Id = b.cust_id
 inner join
 prod_cat_info$ c 
 on b.prod_cat_code= c.prod_cat_code
 and
 b.prod_subcat_code = c.prod_sub_cat_code
 where prod_cat = 'electronics' 
 and Gender = 'M'
 group by prod_subcat

 /*10.What is percentage of sales and returns by product sub category;--
 display only top 5 sub categories in terms of sales? */

select sales.prod_subcat_code, [%sales],  [%return] 
from (select Top 5 prod_subcat_code, sum(total_amt)/(select sum(total_amt) as total_revenue  from Transactions$
where total_amt > 0)*100 as [%sales]
from Transactions$
where total_amt > 0
group by prod_subcat_code
order by 2 desc) as sales
left join 
(select prod_subcat_code, sum(total_amt)/(select sum(total_amt) as total_revenue  from Transactions$
where total_amt < 0)*100 as [%return]
from Transactions$
where total_amt < 0
group by prod_subcat_code) as _return
on sales.prod_subcat_code = _return.prod_subcat_code

/*11. For all customers aged between 25 to 35 years find what is the net total revenue
generated by these consumers in last 30 days of transactions from max transaction 
date available in the data?*/

select cust_id, required_revenue from (select cust_id, tran_date, sum(total_amt) as required_revenue,
max(tran_date) as _maxdate
from Transactions$
group by cust_id, tran_date) as T
left join Customer$ as R
on T.cust_id = R.customer_Id
where DATEDIFF(Day,DOB,_maxdate)/365 between 25 and 35
and tran_date >= (Select dateadd(day,-30,max(tran_date)) from Transactions$)

--12. Which product category has seen the max value of returns in the last 3 months of transactions?
select top 1 prod_cat,
sum(qty)as total_returns
from
Transactions$ as a
join prod_cat_info$ as b 
on a.prod_cat_code = b.prod_cat_code 
and a.prod_subcat_code = b.prod_sub_cat_code
where Qty<0
and tran_date >=  (Select dateadd(day,-90,max(tran_date)) from Transactions$)
group by prod_cat
order by 2 


--13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select top 1 store_type , 
sum(total_amt) as total_sales, 
sum(qty) as total_qty 
from
Transactions$
where total_amt>0 and qty >0
group by store_type
order by total_sales desc, total_qty desc

--14.	What are the categories for which average revenue is above the overall average--

select prod_cat_code,
avg(total_amt) avg_revenue 
from Transactions$ 
group by prod_cat_code
having  avg(total_amt) > (select AVG(total_amt) as overall_revenue from Transactions$ )
order by 2 desc

/*15	Find the average and total revenue by each subcategory for the categories which are 
among top 5 categories in terms of quantity sold. */


select  prod_subcat_code, sum(total_amt), avg(total_amt)
from transactions$
where prod_cat_code in (select top 5 prod_cat_code
from transactions$
where Qty > 0
group by prod_cat_code
order by  sum(Qty) desc) 
group by prod_subcat_code;
 










 
