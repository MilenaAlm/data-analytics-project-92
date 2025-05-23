"customers_count"
19759



  
select 
concat(first_name, ' ', last_name) as seller ,
COUNT (sales_id) as operations,
ROUND (SUM (quantity * price), 0) as income
from sales s 
left join products p 
on s.product_id = p.product_id
left join employees e 
on s.sales_person_id= e.employee_id
group by first_name, last_name
order by income desc
limit 10



  
WITH overall_avg AS (
    SELECT AVG(quantity * price) AS avg_income
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
)
select 
concat(first_name, ' ', last_name) as seller ,
ROUND(AVG(quantity * price), 0) AS average_income
from sales s 
left join products p 
on s.product_id = p.product_id
left join employees e 
on s.sales_person_id= e.employee_id
group by first_name, last_name
HAVING 
    AVG(quantity * price) < (SELECT avg_income FROM overall_avg)
ORDER BY 
    average_income ASC;


select 
concat(first_name, ' ', last_name) as seller ,
TRIM (TO_CHAR(sale_date, 'Day')) day_of_week,
ROUND (SUM (quantity * price), 0) as income
from sales s 
left join products p 
on s.product_id = p.product_id
left join employees e 
on s.sales_person_id= e.employee_id
group by first_name, last_name , 
TRIM(TO_CHAR(s.sale_date, 'Day')), EXTRACT(ISODOW FROM s.sale_date)
order by EXTRACT(ISODOW FROM s.sale_date), seller

select
CASE
	WHEN age BETWEEN 16 AND 25 THEN '16-25'
	WHEN age BETWEEN 26 AND 40 THEN '26-40'
	WHEN age > 40 THEN '40+'
	end  as age_category ,
	COUNT(age) as age_count
from customers c
group by age_category
ORDER by age_category 

