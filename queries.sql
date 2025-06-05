/*запрос, который считает общее количество
покупателей из таблицы customers*/
SELECT COUNT(customer_id) AS customers_count
FROM
    customers;

/*Отчет о десятке лучших продавцов (продавцs,  
суммарная выручка и количество проведенных сделок),
отсортированы по убыванию выручки*/
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
GROUP BY e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;

/*Продавцы, чья средняя выручка за сделку меньше средней
выручки за сделку по всем продавцам.Таблица отсортирована
по выручке по возрастанию*/
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM
    sales AS s
LEFT JOIN
    products AS p
    ON s.product_id = p.product_id
LEFT JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
GROUP BY
    e.first_name,
    e.last_name
HAVING
    AVG(s.quantity * p.price) < (
        SELECT AVG(s2.quantity * p2.price)
        FROM sales AS s2
        INNER JOIN products AS p2
            ON s2.product_id = p2.product_id
    )
ORDER BY
    average_income ASC;

/* Выручка по дням недели. Имя и фамилия продавца,
   день недели и суммарная выручка.
   Отсортированы по порядковому номеру дня недели и seller */
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income,
    EXTRACT(ISODOW FROM s.sale_date) AS day_number
FROM
    sales AS s
LEFT JOIN
    products AS p
    ON s.product_id = p.product_id
LEFT JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
GROUP BY
    e.first_name,
    e.last_name,
    TRIM(TO_CHAR(s.sale_date, 'day')),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    day_number,
    seller;

/*Количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
Отсортирована по возрастным группам*/
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    COUNT(age) as age_count
from customers
group by age_category
order by age_category;

/* Количество уникальных покупателей и выручка,
которую они принесли. Сгруппированы по дате,
которая представлена в числовом виде ГОД-МЕСЯЦ.
Отсортированы по дате по возрастанию */
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
LEFT JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month ASC;

/*Покупатели,первая покупка которых была в ходе
проведения акций(акционные товары отпускали со
стоимостью равной 0).
Отсортирована по id покупателя*/
WITH first_zero_price_purchase AS (
    SELECT DISTINCT ON (s.customer_id)
        s.customer_id,
        s.sale_date AS first_date,
        s.sales_person_id
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    WHERE p.price = 0
    ORDER BY s.customer_id, s.sale_date
)

SELECT
    f.first_date AS sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_zero_price_purchase AS f
INNER JOIN customers AS c ON f.customer_id = c.customer_id
INNER JOIN employees AS e ON f.sales_person_id = e.employee_id
ORDER BY c.customer_id;
