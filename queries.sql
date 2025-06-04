-- запрос, который считает общее количество покупателей из таблицы customers
select 
COUNT (customer_id)   as customers_count
from customers

/*Отчет о десятке лучших продавцов (продавцs,  суммарная выручка и количество проведенных сделок),
отсортированы по убыванию выручки*/
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

/*Продавцы, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
 Таблица отсортирована по выручке по возрастанию*/
SELECT 
    concat(first_name, ' ', last_name) as seller,
    FLOOR(AVG(quantity * price)) AS average_income
FROM sales s 
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN employees e ON s.sales_person_id = e.employee_id
GROUP BY first_name, last_name
HAVING AVG(quantity * price) < (
    SELECT AVG(quantity * price)
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
)
ORDER BY average_income ASC;

/*Выручка по дням недели. Имя и фамилия продавца, день недели и суммарная выручка. 
Отсортированы по порядковому номеру дня недели и seller*/
SELECT 
    concat(first_name, ' ', last_name) as seller,
    TO_CHAR(sale_date, 'day') as day_of_week,
    ROUND(SUM(quantity * price), 0) as income
FROM sales s 
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN employees e ON s.sales_person_id = e.employee_id
GROUP BY 
    first_name, 
    last_name, 
    TO_CHAR(s.sale_date, 'day'),  
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY 
    EXTRACT(ISODOW FROM s.sale_date), 
    seller;

/*Количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
Отсортирована по возрастным группам*/
select
CASE
	WHEN age BETWEEN 16 AND 25 THEN '16-25'
	WHEN age BETWEEN 26 AND 40 THEN '26-40'
	WHEN age > 40 THEN '40+'
	end  as age_category ,
	COUNT(age) as age_count
from customers c
group by age_category
ORDER by age_category;

/*Количество уникальных покупателей и выручка, которую они принесли. Сгруппированы по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
Отсортированы по дате по возрастанию*/
select
to_char (sale_date, 'YYYY-MM') as selling_month,
COUNT(DISTINCT customer_id) as total_customers,
ROUND(SUM (quantity * p.price), 0) as income
from sales s
left join products p
on s.product_id = p.product_id
group by selling_month;

/*Покупатели, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0). 
Отсортирована по id покупателя*/
WITH first_zero_price_date AS (
    SELECT 
        s.customer_id,
        MIN(s.sale_date) AS first_date,
        MIN(s.sales_person_id) AS sales_person_id
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE p.price = 0
    GROUP BY s.customer_id
)
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    f.first_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_zero_price_date f
JOIN customers c ON f.customer_id = c.customer_id
JOIN employees e ON f.sales_person_id = e.employee_id
ORDER BY c.customer_id;
