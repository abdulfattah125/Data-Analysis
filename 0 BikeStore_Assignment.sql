-- Two schema sales, producation
--1) Display a list of all sales orders with staff id is 9
        -- all information on sales.orders
select *
from sales.orders 
where staff_id = 9

--2) Name all the customers who live in New York and provide a phone number.
select first_name + ' ' + last_name "Full Customer Name"
from sales.customers
where city = 'New York'
and phone is not null

--3)List all the customers names who ordered from store_id = 2.
    -- table customers & orders
	-- unique name of customer , don't need duplication
select distinct first_name + ' ' + last_name "Full Customer Name"
from sales.customers c inner join sales.orders o
on c.customer_id = o.customer_id
where o.store_id = 2

--4)List all staff names with discount > 0.05 Note: required reference to multiple tables.
     -- staffs >> orders >> order_items
select distinct s.first_name + ' ' + s.last_name as "Staff Full Name"
from sales.staffs s inner join sales.orders o
on s.staff_id = o.staff_id inner join sales.order_items i
on o.order_id = i.order_id
where i.discount > 0.05

--5) Display the names of the customers who ordered from Baldwin Bikes and Santa Cruz Bikes stores.
      -- customers >> orders >> stores 
select distinct c.first_name + ' ' + c.last_name "Full Customer Name"
from sales.customers c inner join sales.orders o
on c.customer_id = o.customer_id inner join sales.stores s
on o.store_id = s.store_id
where s.store_name in ('Baldwin Bikes' , 'Santa Cruz Bikes' )

--6) Display the item ID and name whose discount is more than 0.05 .
     -- sales.order_items >> production.products
select o.order_id , o.item_id , p.product_name
from sales.order_items o , production.products p
where o.product_id = p.product_id
and o.discount > 0.05
  
--11) How many total serving customer does BikeStore has ?
select COUNT(customer_id) "Total Serving Customer" 
from sales.customers

--12) How many total orders are there ?
select count(order_id) Total_Orders
from sales.orders
--13) Which store has the highest number of sales ?
select top 1 s.store_name , count(o.order_id) as no_of_order
from sales.orders o inner join sales.stores s
on o.store_id = s.store_id
group by s.store_name
order by no_of_order desc

--14) Which store the sales was highest and for which month ?
select top 1 s.store_name , year(o.order_date) Year , MONTH(o.order_date) as Month , sum(i.list_price * i.quantity * ( 1 - i.discount )) Total_Sales
from sales.stores s inner join sales.orders o
on s.store_id = o.store_id inner join sales.order_items i
on i.order_id = o.order_id
group by s.store_name , year(o.order_date) , MONTH(o.order_date) 
order by Total_Sales desc

--15) How many orders each customer has placed (give me top 10 customers) ?
select top 10 c.first_name + ' ' + c.last_name as Customer_Name
, COUNT(*) "No. Orders"
from sales.customers c inner join sales.orders o
on c.customer_id = o.customer_id
group by c.first_name + ' ' + c.last_name
order by [No. Orders] desc

--16) Which are the TOP 3 selling product ?
select  top 3 p.product_name , COUNT(i.order_id) "No. Orders"
from production.products p inner join sales.order_items i
on p.product_id = i.product_id
group by p.product_name
order by "No. Orders" desc

--17) Which was the first and last order placed by the customer who has placed the maximum number of orders ?
select top 1 with ties c.first_name + ' ' + c.last_name as Full_Name , COUNT(o.order_id) [No. Orders]
 , MAX(o.order_id) as Last_Order , MIN(o.order_id) as First_Order
from sales.customers c inner join sales.orders o
on c.customer_id = o.customer_id
group by c.first_name + ' ' + c.last_name
order by [No. Orders]  desc

--18) For every customer , which is the cheapest product and the most cost product which the customer has bought ?
select x.customer_id , [Full Name] , [The Most Cost Product] , x.product_name as [the Most Cost Product Name]  , [The Cheapest Product] , p.product_name as [The Cheapest Product Name]
from
(
select tab.customer_id , [Full Name] , [The Most Cost Product] , p.product_name , [The Cheapest Product]
from
(
select o.customer_id , c.first_name + ' ' + c.last_name as "Full Name" , MAX(p.list_price) [The Most Cost Product]
, MIN(p.list_price) [The Cheapest Product] 
from sales.orders o inner join sales.order_items i on o.order_id = i.order_id 
					inner join production.products p on i.product_id = p.product_id
					inner join sales.customers c on c.customer_id = o.customer_id
group by o.customer_id , c.first_name + ' ' + c.last_name
) tab inner join sales.orders o
on tab.customer_id = o.customer_id inner join sales.order_items i
on o.order_id = i.order_id inner join production.products p
on i.product_id = p.product_id
where [The Most Cost Product] = p.list_price
) x inner join sales.orders o
on x.customer_id = o.customer_id inner join sales.order_items i
on o.order_id = i.order_id inner join production.products p
on i.product_id = p.product_id
where [The Cheapest Product] = p.list_price
order by [the most cost product] desc

--19) Which product has ordered more than 100 times ?
select p.product_name , COUNT(distinct order_id) [No. Orders]
from sales.order_items i inner join production.products p
on i.product_id = p.product_id
group by p.product_name
having COUNT(distinct order_id) > 100

--20) The query retrieves order_date information ( return results are unique ), sorted in ascending order.
select distinct order_date
from sales.orders
order by order_date

--21) Query brand_id information and category_id ( return results are unique ).
select p.product_id , p.product_name , c.category_name , b.brand_name
from production.products p , production.categories c , production.brands b
where p.category_id = c.category_id and p.brand_id = b.brand_id
order by product_name

--22) Write a query to get all employee information with store_id equal to 1 and manager_id equal to 2, sorted in ascending order by first_name.
select *
from sales.staffs
where store_id = 1 and manager_id = 2
order by first_name

--23) Write a query that gets all product information with brand_id equal to 1 or 9, and has a price between 199.99 and 499.99.
select *
from production.products
where brand_id in ( 1 , 9 )
and list_price between 199.99 and 499.99

--24) Write a query that lists the names of the 5 products with the highest price provided that the product has a model_year equal to 2018.
select top 5 product_name , list_price
from production.products
where model_year = 2018
order by list_price desc

--25) Write a query to get all customer information (customers) with first_name has the end next character is 't' and zip_code starts with '11', sorted by first_name.
select *
from sales.customers
where first_name like '%t_' and zip_code like '11%'
order by first_name

--26) Write a query to get all product information has a price equal to 999.99 or 1999.99 or 2999.99.
select *
from production.products
where list_price in ( 999.99 , 1999.99 , 2999.99 )

--27) Write a query that returns the total number of products whose names start with 'Trek' and priced from 199.99 to 999.99.
select COUNT(distinct product_name) [The Total Number of Products]
from production.products
where product_name like 'Trek%'
and list_price between 199.99 and 999.99

--28) Write a query that returns product name, total price and total quantity of products for each product with the keyword 'Ladies' in the product name.
select product_name , SUM(p.list_price * s.quantity) as "Total Expected Sales AMT"
					, SUM(s.quantity) as "Total Quantity"
from production.products p inner join production.stocks s
on p.product_id = s.product_id
where product_name like '%Ladies%'
group by product_name

--29) Write a query to output information about orders that have a total net value greater than 20,000 on the sales.order_items table, know the net_ value calculated by the formula ( quantity * list_price * (1 - discount) )
select o.* , tab.[Total Net Value]
from
(
select order_id , sum (quantity * list_price * (1 - discount) ) as "Total Net Value"
from sales.order_items
group by order_id
having sum (quantity * list_price * (1 - discount) ) > 20000
) tab inner join sales.orders o
on tab.order_id = o.order_id

--30) Write a query to get product information (product_name), order code (order_id) with that product (if any), number of products (quantity) and daily orders transacted (order_date)
select p.product_name , o.order_id , i.quantity , o.order_date
from production.products p left outer join sales.order_items i
on p.product_id = i.product_id left outer join sales.orders o
on o.order_id = i.order_id

--31) Write a query to get brand information (brand_name) and average price (average_list_price) for all products with model_year of 2018.
select b.brand_name , AVG(p.list_price) Average_Price
from production.products p , production.brands b
where b.brand_id = p.brand_id
and p.model_year = 2018
group by b.brand_name

--32) Write a query to get information about order code (order_id), customer name (customer_name), store name (store_name), total product quantity (total_quantity) and total order value (total_net_value) knowing order value (net_value) calculated by the formula quantity * list_price * (1 - discount)
select c.first_name + ' ' + c.last_name "Customer Full Name" , s.store_name , o.order_id
, SUM(i.quantity) as "Total Product Quantity"
, SUM(i.quantity * i.list_price * (1 - i.discount)) "Total Net Value"
from sales.customers c inner join sales.orders o
on o.customer_id = c.customer_id inner join sales.stores s
on s.store_id = o.store_id inner join sales.order_items i
on i.order_id = o.order_id
group by c.first_name + ' ' + c.last_name , s.store_name , o.order_id

--33) Write a query to get information about products that have not been sold at any stores or are out of stock (quantity = 0), results should return store name and product name.
select distinct st.store_name , p.product_name
from sales.order_items i right outer join production.products p
on i.product_id = p.product_id left join production.stocks s
on p.product_id = s.product_id inner join sales.stores st
on s.store_id = st.store_id
where i.product_id is null or s.quantity = 0