
use `order-directory`;

/*
4) Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.
*/


SELECT Count(t2.cus_gender) AS NoOfCustomers,
       t2.cus_gender
FROM   (SELECT a.cus_id,
               a.cus_gender,
               a.ord_amount,
               a.cus_name
        FROM   (SELECT ord.*,
                       cust.cus_gender,
                       cust.cus_name
                FROM   customer AS cust
                       JOIN order AS ord
                         ON ord.cus_id = ord.cus_id
                WHERE  ord_amount >= 3000)a
        GROUP  BY a.cus_id,
                  a.cus_gender,
                  a.ord_amount,
                  a.cus_name) AS t2
GROUP  BY t2.cus_gender; 



/*
5) Display all the orders along with product name ordered by a customer having Customer_Id=2
*/
SELECT 
    product.pro_name, `order`.*
FROM
    `order`,
    supplier_pricing,
    product
WHERE
    `order`.cus_id = 2
        AND `order`.pricing_id = supplier_pricing.pricing_id
        AND supplier_pricing.pro_id = product.pro_id;






/*
6) Display the Supplier details who can supply more than one product.
*/
SELECT 
    supplier.*
FROM
    supplier
WHERE
    supplier.supp_id IN (SELECT 
            supp_id
        FROM
            supplier_pricing
        GROUP BY supp_id
        HAVING COUNT(supp_id) > 1)
GROUP BY supplier.supp_id;




/*
7) Find the least expensive product from each category and print the table with category id, name, product name and price of the product
*/
SELECT category_id,
       cat_name,
       Min(price)
FROM   (SELECT cat_id            AS 'Category_Id',
               pro_name          AS 'Product_Name ',
               Min(a.supp_price) 'Price'
        FROM   (SELECT prod.pro_id,
                       prod.pro_name,
                       prod.pro_desc,
                       prod.cat_id,
                       price.supp_price
                FROM   product prod
                       JOIN supplier_pricing price
                         ON prod.pro_id = price.pro_id
                ORDER  BY prod.pro_id ASC)a
        GROUP  BY pro_id,
                  pro_name,
                  cat_id
        ORDER  BY cat_id ASC)b
       JOIN category cat
         ON cat.cat_id = b.category_id
GROUP  BY category_id,
          cat_name 




/*
8) Display the Id and Name of the Product ordered after “2021-10-05”.
*/
SELECT product.pro_id,
       product.pro_name
FROM   `order`
       INNER JOIN supplier_pricing
               ON supplier_pricing.pricing_id = `order`.pricing_id
       INNER JOIN product
               ON product.pro_id = supplier_pricing.pro_id
WHERE  `order`.ord_date > '2021-10-05'; 




/*
9) Display customer name and gender whose names start or end with character 'A'.
*/

SELECT 
    customer.cus_name, customer.cus_gender
FROM
    customer
WHERE
    customer.cus_name LIKE 'A%'
        OR customer.cus_name LIKE '%A';



/*
10) Create a stored procedure to display supplier id, name, rating and Type_of_Service. For Type_of_Service, If rating =5, print “Excellent
Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” else print “Poor Service”.
*/
CREATE PROCEDURE report()
select report.supp_id,
       report.supp_name,
       report.average,
       CASE
              WHEN report.average = 5 THEN 'Excellent Service'
              WHEN report.average > 4 THEN 'Good Service'
              WHEN report.average > 2 THEN 'Average Service'
              ELSE 'Poor Service'
       END AS type_of_service
FROM   (
                  SELECT     final.supp_id,
                             supplier.supp_name,
                             final.average
                  FROM       (
                                      SELECT   test2.supp_id,
                                               sum(test2.rat_ratstars) / count(test2.rat_ratstars) AS average
                                      FROM     (
                                                          SELECT     supplier_pricing.supp_id,
                                                                     test.ord_id,
                                                                     test.rat_ratstars
                                                          FROM       supplier_pricing
                                                          INNER JOIN
                                                                     (
                                                                                SELECT     `order`.pricing_id,
                                                                                           rating.ord_id,
                                                                                           rating.rat_ratstars
                                                                                FROM       `order`
                                                                                INNER JOIN rating
                                                                                ON         rating.`ord_id1` = `order`.ord_id) AS test
                                                          ON         test.pricing_id = supplier_pricing.pricing_id) AS test2
                                      GROUP BY supplier_pricing.supp_id) AS final
                  INNER JOIN supplier
                  WHERE      final.supp_id = supplier.supp_id) AS report

