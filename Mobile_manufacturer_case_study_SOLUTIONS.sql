/***********************************************************************************************************************************
                                       ANSWERS TO "MOBILE_MANUFACTURER" CASE STUDY
***********************************************************************************************************************************/
/*    DATABASE OF NAME "Mobile_manufacturer_case_study" is created and it is used for solving the below questions         */

/*            Using the database "Mobile_manufacturer_case_study"                                                                  */

USE Mobile_manufacturer_case_study

/*     Viewing the records of the tables present in the database "Mobile_manufacturer_case_study"      */

select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from DIM_CUSTOMER 
select * from DIM_DATE 
select * from DIM_LOCATION 
select * from FACT_TRANSACTIONS 

/* Combining the tables "DIM_MODEL" and "DIM_MANUFACTURER" using LEFT-JOIN and a new table of name "dim_model_manufacture"  
   So that this table can be used in future reference to solve the below questions                                      */

select t1.IDModel,t1.Model_Name,t1.Unit_price,t2.IDManufacturer,t2.Manufacturer_Name into dim_model_manufacture
from DIM_MODEL t1
left join DIM_MANUFACTURER t2
on t1.IDManufacturer=t2.IDManufacturer


/*  Viewing the records of the created table "dim_model_manufacture"   */

select * from dim_model_manufacture 

/*  Here, in the "Mobile_manufacturer_case_study" ,the schema is the type of STAR SCHEMA i.e.,
	the tables "DIM_CUSTOMER","DIM_DATE","DIM_LOCATION","DIM_MODEL","DIM_MANUFACTURER" 
	all these tables are connected to one single table "FACT_TRANSACTIONS",
	
	So, to solve the questions easily here I've created a combined table of name "DIM_FINAL"
	by joinig all those linked tables "DIM_DATE","DIM_CUSTOMER","dim_model_manufacture" and "DIM_LOCATION"
	
	Despite joining the tables again and again with respect to each question, I found this as a simpler method i.e.
	Tables once joined as "DIM_FINAL" can be used to solve all the questions
	
	And, since the number of records in "DIM_FINAL", the combined table are just 300, I choose this method
	If, the combined table contains many rows, then it would be hard to run and would take more run time,
	in that case joining sepeately with respect to each question can be done.     */

/* Creating a table "DIM_FINAL", by joining "DIM_DATE","DIM_CUSTOMER","dim_model_manufacture" and "DIM_LOCATION"  */

select t1.IDModel,t4.Model_Name,t4.IDManufacturer,t4.Manufacturer_Name,
t1.IDCustomer,t3.Customer_Name,t3.Email,t3.Phone,t1.IDLocation,t5.ZipCode,t5.Country,
t5.[State],t5.City,t1.[Date],t2.[YEAR],t2.[MONTH],t2.[QUARTER],t1.TotalPrice,t1.Quantity into DIM_FINAL

from FACT_TRANSACTIONS t1
left join DIM_DATE t2 on t1.[Date]=t2.[DATE]
left join DIM_CUSTOMER t3 on t1.IDCustomer=t3.IDCustomer
left join dim_model_manufacture t4 on t1.IDModel=t4.IDModel
left join DIM_LOCATION t5 on t1.IDLocation=t5.IDLocation


/* Viewing the records of the table "DIM_FINAL"  */

select * from DIM_FINAL

/*	1. List all the states in which we have customers who have bought cell phones from 2005 till today.  */

select distinct [state] as [States of customers who brought phones from 2005 to till today] from DIM_FINAL
where [date] between '2005-01-01' and GETDATE()

/*	2. What state in the US is buying more 'Samsung' cell phones?   */

select top(1) [state] as [State with buying MAX samsung phones],count(manufacturer_name) as [Count of MAX samsung phones] 
from DIM_FINAL
where Manufacturer_Name='samsung' and country='us'
group by [state]
order by [Count of MAX samsung phones] desc

/*	3. Show the number of transactions for each model per zip code per state. */

select [State],ZipCode,IDModel, count(idmodel) as [Number of transactions for each ID-MODEL wrt state and zipcode]from DIM_FINAL
group by [state],zipcode,idmodel
order by [Number of transactions for each ID-MODEL wrt state and zipcode] desc

/*	4. Show the cheapest cell phone?  */
select top(1) manufacturer_name+' '+model_name as [Cheapest cell phone] from DIM_FINAL
order by TotalPrice asc

/*	5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. */

select concat(manufacturer_name,' ',idmodel) [ID-Model in top 5 manufacturers by sales], 
sum(totalprice)/sum(quantity) as [AVG Price of each model in Top 5 manufacturers in sales] from DIM_FINAL
where manufacturer_name in (select top(5) manufacturer_name from DIM_FINAL group by manufacturer_name order by sum(quantity) desc)
group by manufacturer_name,IDModel
order by [AVG Price of each model in Top 5 manufacturers in sales] desc

/*	6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500 */

select Customer_name as [Customers with AVG amount spent higher than $500],
avg(totalprice) as [Average Amount spent in 2009] from DIM_FINAL
where [year]=2009
group by Customer_Name
having avg(totalprice)>500
order by [Average Amount spent in 2009] desc

/*	7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010 */

select * from (
select top(5) IDModel,model_name,sum(quantity) as Total_quantity from DIM_FINAL
where [year]='2008'
group by idmodel,model_name
order by Total_quantity desc)as a

intersect
select * from (
select top(5) IDModel,model_name,sum(quantity) as Total_quantity from DIM_FINAL
where [year]='2009'
group by idmodel,model_name
order by Total_quantity desc )as b

intersect
select * from (
select  top(5) IDModel,model_name,sum(quantity) as Total_quantity from DIM_FINAL
where [year]='2010'
group by idmodel,model_name
order by Total_quantity desc) as c

/*	8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with 
	   the 2nd top sales in the year of 2010. */

select * from (
select manufacturer_name [Top 2nd manufacturer wrt sales in 2009] from (
select manufacturer_name,sum(totalprice) [totalsales],DENSE_RANK() over(order by sum(totalprice) desc) as [rank] from DIM_FINAL
where [year]='2009' 
group by manufacturer_name) as a
where [rank]='2') as b
full outer join
(
select manufacturer_name [Top 2nd manufacturer wrt sales in 2010] from (
select manufacturer_name,sum(totalprice) [totalsales],DENSE_RANK() over(order by sum(totalprice) desc) as [rank] from DIM_FINAL
where [year]='2010' 
group by manufacturer_name) as c
where [rank]='2' ) as d on 1=1



/*	9. Show the manufacturers that sold cell phone in 2010 but didn't in 2009. */

select distinct manufacturer_name as [Manufacturers who sold phones in 2010 but didn't in 2009] from DIM_FINAL
where [year]='2010'
except
select distinct manufacturer_name from DIM_FINAL
where [year]='2009'

/*	10. Find top 100 customers and their average spend, average quantity by each year. 
		Also find the percentage of change in their spend. */

------Top 100 customer, Ordered (categorised) by Average Price spent------

------ Year to Year % difference is calculated for all the years with respect to transactions (where transactions are done)-------

select top(100) IDCustomer,  customer_name,[year],sum(totalprice) as [Total Sales of customer wrt year],
LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc) as [Total Sales of customer wrt Previous year of transaction],
sum(totalprice)-LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc) as [Price difference in sales from previous year of transaction to current year],
((sum(totalprice)-LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc))/LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc))*100 as [% difference in sales from prior year of transaction to curent year],
sum(quantity) as [Total quantity purchased wrt year],
avg(totalprice) as [AVG price spent], avg(quantity) as [AVG quantity purchased wrt year]
from DIM_FINAL
group by IDCustomer,customer_name,[year]
order by [AVG price spent] desc, customer_name asc

------ Can check the below reference version of code (with out Top 100 clasification) for better understanding---------

---Just for reference, [with out the Top 100] and ordered by Customer_name Ascending ---

select IDCustomer,  customer_name,[year],sum(totalprice) as [Total Sales of customer wrt year], 
LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc) as [Total Sales of customer wrt Previous year of transaction],
sum(totalprice)-LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc) as [Price difference in sales from previous year of transaction to current year],
((sum(totalprice)-LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc))/LAG(sum(totalprice),1) OVER(partition by customer_name order by [year] asc))*100 as [% difference in sales from prior year of transaction to curent year],
sum(quantity) as [Total quantity purchased wrt year],
avg(totalprice) as [AVG price spent], avg(quantity) as [AVG quantity purchased wrt year]
from DIM_FINAL
group by IDCustomer,customer_name,[year]
order by customer_name asc, [year] asc