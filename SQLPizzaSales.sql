Use Pizza_sales

Select * from order_details
Select * from orders
Select * from pizza_types
Select * from pizzas



--Retrieve the total number of orders placed.

Select COUNT(order_id)As Total Orders
from orders

--Calculate the total revenue generated from pizza sales.
select Sum(P.price * O.quantity) As total_revenue 
from pizzas as P join order_details as O 
on P.pizza_id = O.pizza_id 

--Identify the highest-priced pizza.
Select Top 1 O.name, P.price as highest_priced_pizza
from pizzas as P join pizza_types as O 
on P.pizza_type_id = O.pizza_type_id
Order By P.price desc



--Identify the most common pizza size ordered.
Select Top 5 P.Size as Most_common_pizza_size , Count(O.order_details_id) As Quantity 
from pizzas as P join order_details as O 
on P.pizza_id = O.pizza_id
group by P.Size
order By Quantity Desc


--List the top 5 most ordered pizza types along with their quantities.

Select Top 5 P.name, Sum(O.quantity) as Sum_Quantity
from pizza_types P join pizzas Q 
On P.pizza_type_id = Q.pizza_type_id join order_details O on Q.pizza_id = O.pizza_id
group by P.name
Order By Sum_Quantity desc


--Join the necessary tables to find the total quantity of each pizza category ordered.
Select Sum(O.quantity) As Total_Quantity, P.category
from pizza_types P join pizzas Q 
On P.pizza_type_id = Q.pizza_type_id join order_details O on Q.pizza_id = O.pizza_id
group by P.category
Order By Total_Quantity Desc

--Determine the distribution of orders by hour of the day.
Select DATEPART(HOUR, orders.time), Count(order_id) as Total_orders
from orders
group by DATEPART(HOUR, orders.time)
order by  DATEPART(HOUR, orders.time) 

 
--Join relevant tables to find the category-wise distribution of pizzas.
Select category, COUNT(pizza_types.name) As grouped
from pizza_types
Group by category

--Group the orders by date and calculate the average number of pizzas ordered per day.
Select Avg (QTY) from (Select SUM(D.quantity) As QTY, O.date 
from Orders As O Join order_details As D
on O.order_id = D.order_id
group by O.date) As Ordered

--Determine the top 3 most ordered pizza types based on revenue.
Select TOP 3 P.name, SUM(O.quantity*Q.price) As total_revenue
From pizza_types P join pizzas Q on P.pizza_type_id = Q.pizza_type_id Join order_details O on Q.pizza_id= Q.pizza_id
Group by P.name
order by total_revenue desc


--Calculate the percentage contribution of each pizza type to total revenue.

Select pizza_types.category, Round(SUM(order_details.quantity*pizzas.price)/(select Round(Sum(order_details.quantity*pizzas.price),2) As total_sales
												from pizzas join order_details  
												on pizzas.pizza_id = order_details.pizza_id)*100,2) As total_revenue
From pizza_types  join pizzas  on pizza_types.pizza_type_id = pizzas.pizza_type_id Join order_details on pizzas.pizza_id= order_details.pizza_id
Group by pizza_types.category
order by total_revenue desc



--Analyze the cumulative revenue generated over time.
SELECT 
    derived_table.date, 
    SUM(total_revenue) OVER(ORDER BY Orders.date) AS Cum_sales 
FROM (
    SELECT 
        Orders.date,
        SUM(order_details.quantity * pizzas.price) AS total_revenue
    FROM  
        pizzas 
    JOIN 
        order_details ON pizzas.pizza_id = order_details.pizza_id 
    JOIN 
        orders ON order_details.order_id = orders.order_id
    GROUP BY 
        orders.date
) AS derived_table(date, total_revenue);


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.


	WITH RankedPizza AS (
    SELECT 
        category, 
        Name, 
        Sum_Quantity,
        RANK() OVER (PARTITION BY category ORDER BY Sum_Quantity DESC) AS Rn
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name, 
            SUM(order_details.quantity * pizzas.price) AS Sum_Quantity
        FROM 
            pizza_types  
        JOIN 
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
        JOIN 
            order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_types.name, pizza_types.category
    ) AS a
)
SELECT 
    category, 
    Name, 
    Sum_Quantity,
    Rn
FROM 
    RankedPizza
WHERE 
    Rn <= 3;
