
--- 1.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year ---
SELECT 
  CustomerId, 
  STR_TO_DATE(Bank_DOJ, '%d-%m-%Y') AS Bank_DOJ,
  Surname, 
  EstimatedSalary
  FROM customerinfo
WHERE QUARTER(STR_TO_DATE(Bank_DOJ, '%d-%m-%Y')) = 4
ORDER BY EstimatedSalary DESC
LIMIT 5;

---  3.Calculate the average number of products used by customers who have a credit card ---
select  avg(numofproducts) as avg_product
from bank_churn b
where HasCrCard=1;

---- 5.Compare the average credit score of customers who have exited and those who remain ---
select e.Exitcategory,avg(bc.CreditScore) as avg_credict_score
from bank_churn bc
join exitcustomer e on bc.Exited=e.Exitid
group by e.Exitcategory;

----  6.Which gender has a higher average estimated salary and how does it relate to the number_of_active account-----

select GenderCategory,round(avg(EstimatedSalary),2) as Avg_estimated_sal,
count(bc.CustomerId) as Active_Customers
from customerinfo ci
join gender g on ci.genderID=g.genderID
join bank_churn bc on bc.customerID=ci.customerID
join activecustomer ac on  bc.IsActiveMember=ac.ActiveID
where ActiveCategory='Active Member'
group by GenderCategory;

---- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate ---


   with CreditScoreSegment as ( select CustomerId, Exited,
    case when creditscore between 781 and 850 then 'Excellent'
        when creditscore between 701 and 780 then 'Very Good'
        when creditscore between 611 and 700 then 'Good'
        when creditscore between 510 and 610 then 'Fair' else 'Poor'
    end as CreditScoreSegment
    from bank_churn)
    
select CreditScoreSegment,
    avg(case when Exited = 1 then 1 else 0 end) as Exit_Rate
from creditscoresegment
group by creditscoresegment
order by exit_rate desc
limit 1;

---- 8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years ----
select g.GeographyLocation,count(GeographyLocation) as active_caustomer
from customerinfo c
join bank_churn bc on c.CustomerId=bc.CustomerId
join geography g on c.GeographyID=g.GeographyID
where bc.IsActiveMember=1 and bc.Tenure>5
group by g.GeographyLocation;

---- 11.Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it ----

SELECT  
  YEAR(STR_TO_DATE(Bank_DOJ, '%d-%m-%Y')) AS Year,
  MONTH(STR_TO_DATE(Bank_DOJ, '%d-%m-%Y')) AS Month,
  COUNT(*) AS Customers_Joined
FROM customerinfo 
GROUP BY 
  YEAR(STR_TO_DATE(Bank_DOJ, '%d-%m-%Y')),
  MONTH(STR_TO_DATE(Bank_DOJ, '%d-%m-%Y'))
ORDER BY 
  Year, Month;


---- 15.Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value ----
select geo.GeographyLocation, gn.GenderCategory,
round(avg(c.estimatedsalary),2) as Avg_salary,
rank() over (partition by GeographyLocation 
order by avg(c.EstimatedSalary) desc) as 'Rank'
from customerinfo c
join geography geo on c.geographyid = geo.geographyid
join gender gn on gn.genderid=c.genderid
group by geo.geographylocation, gn.GenderCategory
order by geo.geographylocation;

--- 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).---

select
case when c.age between 18 and 30 then '18-30'
	 when c.age between 30 and 50 then '30-50'
else '50+' 
end as age_bucket,round(avg(b.Tenure),2) as Avg_Tenure
from customerinfo c
join bank_churn b on c.CustomerId=b.CustomerId
where b.exited=1
group by case when c.age between 18 and 30 then '18-30'
	 when c.age between 30 and 50 then '30-50'
else '50+' 
end;

----- 20.According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket ----
with age_buck_count as (select
case when c.age between 18 and 30 then '18-30'
	 when c.age between 30 and 50 then '30-50'
else '50+' 
end as age_bucket,count(b.HasCrCard) as creditcard_holders
from customerinfo c
join bank_churn b on c.CustomerId=b.CustomerId
where b.HasCrCard=1 
group by case when c.age between 18 and 30 then '18-30'
	 when c.age between 30 and 50 then '30-50'
else '50+' 
end)
select age_bucket,creditcard_holders
from age_buck_count
where creditcard_holders<(select avg(creditcard_holders)
                            from age_buck_count);
                            
 ---- 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL ----
 
 select CustomerId, 
Tenure,
Balance, 
NumOfProducts,
HasCrCard,
IsActiveMember,
Exited,(select e.exitcategory  from
           exitcustomer e where e.ExitID=bc.Exited) as exitcategory
from bank_churn bc;

---- Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.---
   select c.CustomerId, c.Surname as Last_name,  
    case when b.isactivemember = 1 then 'active' 
    else 'inactive' end as activitystatus
from customerinfo c
join bank_churn b on c.customerid = b.customerid
where c.surname like '%on'
order by c.surname;
---- 26.	Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns. One more point to consider is that the data in the Exited Column is absolutely correct and accurate---
select * 
from bank_churn b 
join customerinfo c on b.customerid = c.customerid
where b.exited =1 and b.isactivemember =1;


----- subjective----
----- 9.	Utilize SQL queries to segment customers based on demographics and account details.---

select GeographyLocation, 
    case when estimatedsalary < 50000 then 'Low'
        when estimatedsalary < 100000 then 'Medium'
        else 'High'end as Income_Segment, GenderCategory ,
    count(c.customerid) as NumberofCustomers
from customerinfo c

join geography g on c.geographyid = g.geographyid
join gender gn on c.genderid=gn.genderid
group by  geographylocation, Income_Segment, GenderCategory
order by geographylocation;

----- 14.In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”? ----
alter table Bank_Churn
rename column HasCrCard to Has_creditcard ;

select * from bank_churn
