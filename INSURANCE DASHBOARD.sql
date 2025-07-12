create database project1;
use project1;


------- 1-No of Invoice by Account Exe
select `Account Executive`, count(Invoice_number)
 `No. of ivoice` from Invoice
group by `Account Executive`
order by `No. of ivoice` desc;
 
------- 2-Yearly Meeting Count   
SELECT 
YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS year,
COUNT(*) AS meeting_count
FROM 
meeting
GROUP BY 
year
ORDER BY 
year;

--------- 3.1Cross Sell--Target, Achieve, new
------- 3.1New-Target,Achive,new
---------- 3.1Renewal-Target, Achieve , new
SELECT  
f.income_class,
-- Combined Target (Sum of all budgets)
SUM(ib.`Cross sell bugdet` + ib.`New Budget`+ ib.`Renewal Budget`) AS Target,
-- Combined Achieve (Sum of amounts from brokerage and fees)
SUM(COALESCE(b.`Amount`,0) + COALESCE(f.`Amount`, 0)) AS Achieve,
-- Combined New (Sum of amounts from invoice)
SUM(COALESCE(i.`Amount`, 0)) AS New
FROM fees f
LEFT JOIN `individual budgets` ib ON f.`Account Exe ID` = ib.`Account Exe ID`
LEFT JOIN brokerage b ON f.`Account Exe ID` = b.`Account Exe ID`
LEFT JOIN invoice i ON f.`Account Exe ID` = i.`Account Exe ID` 
GROUP BY f.income_class;

------- 4. Stage Funnel by Revenue
select stage, sum(revenue_amount) 
Revenue from opportunity
group by stage
order by Revenue desc;

--------- 5. No of meeting By Account Exe
select `Account Executive`, 
count(`Account Exe ID`) `No. Of Meetings` from meeting
group by `Account Executive`;
    
------ 6- Top Open Opportunity
select opportunity_name, sum(revenue_amount) 
Revenue from opportunity
WHERE stage IN ('Propose Solution', 'Qualify Opportunity')
group by opportunity_name
order by Revenue desc
limit 4;
------ 6- Top Open Opportunity
SELECT COUNT(*) AS TOTAL_OPEN_OPPORTUNITIES
FROM project1
WHERE stage IN ('Propose Solution', 'Qualify Opportunity');






----------- ----------------------------------------------Policy Dashboard KPI----------------------------------------------------------------------------------

---- 1-Total Policy
select status, count(`Policy ID`) `Number Of Policies` from `policy details` 
group by status;

---- 2-Total Customers
select `policy type`, count(`Customer ID`) `No. Of Customers` from `policy details`
group by `policy type`;

----- 3-Age Bucket Wise Policy Count
select case 
when age between 18 and 25 then "18-25"
when age between 26 and 35 then "26-35"
when age between 36 and 45 then "36-45"
when age between 46 and 55 then "46-55"
when age between 56 and 65 then "56-65"
when age between 66 and 75 then "66-75"
when age >75 then "75+"
end as `Age Group`, count(`policy type`) `Policy Count`
from `customer information` c join `policy details` p on c.`customer id` = p.`customer id`
group by `Age Group`;

------ 4-Gender Wise Policy Count
select gender, count(`policy id`) from 
`customer information` c join `policy details` p on c.`customer id` = p.`customer id`
group by gender;

----- 5-Policy Type Wise Policy Count
select `Policy Type`, count(`Policy ID`) from `policy details`
group by `Policy Type`;

------ 6-Policy Expire This Year
select case 
when year(`Policy End Date`)= year(now()) then year(`Policy End Date`)
end as year,
 count(`Policy ID`) `NO. Of Policies` from `policy details`
 group by year;
 
 ------ 7-Premium Growth Rate
 WITH yearly_premiums AS (
    SELECT 
        YEAR(`Policy Start Date`) AS year,
        SUM(`Premium Amount`) AS total_premium
    FROM `policy details`
    GROUP BY YEAR(`Policy Start Date`)
)
SELECT 
    year,
    total_premium,
    LAG(total_premium) OVER (ORDER BY year) AS previous_year_premium,
    ROUND(
        (total_premium - LAG(total_premium) OVER (ORDER BY year)) / 
        NULLIF(LAG(total_premium) OVER (ORDER BY year), 0) * 100, 
        2
    ) AS premium_growth_rate_percentage
FROM yearly_premiums
ORDER BY year;
 
 ------ 8-Claim Status Wise Policy Count
 select `Claim Status`, count(`Policy ID`) `No. Of Policies`
 from claims
 group by `Claim Status`;
 
 ------ 9-Payment Status Wise Policy Count
 select `Payment Status`, count(`Policy ID`) `No. Of Policies` from `payment history`
 group by `Payment Status`;
 
 ----- 10-Total Claim Amount
 select `Policy Type`, sum(`Claim Amount`) `Total Claim Amount` 
 from claims c join `policy details` p on c.`Policy ID`= p.`Policy ID`
 group by `Policy Type`;

