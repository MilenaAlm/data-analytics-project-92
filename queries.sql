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
