-- Written in mssql
select
    rd.brandCode,
    b.name as brandName,
    count(rd.partnerItemId) as transactionsLast6MonthUser,
    sum(rd.finalPrice) as totalSpendLast6MonthUser
from receipt_detail rd
    left join brand b
    on b.brandCode = rd.brandCode
    join receipt r
    on r._id = rd.receiptId
    join user u
    on u._id = r.userId
where u.created_date >= DATEADD('month', -6, GETDATE())
group by rd.brandCode, b.name
order by totalSpendLast6MonthUser desc

-- This query will list all brands available in receipt scan data and their corresponding spend and transaction count from users created within the last 6 months.
--    Brands are ordered by the highest spender to the least.
--    The code can be easily modified to sort by transaction count by changing the last line to 'order by transactionsLast6MonthUser desc'.

-- I decided to include all brands instead of just showing the top brand to provide more context and allow the stakeholder some room to explore the data.
---    In my experience, tightly defined questions like the one I sought to answer typically lead to additional questions. I have found that providing extra data gives the stakeholder the opportunity to answer any follow up questions without having to wait for new data.
---    If I wanted to pull just the top brand, I could start the query with 'select top 1 rd.brand code, ...' and end the code with 'order by [metric] desc'
---    If I wanted to pull the top brand for both transactions and spend, I could use CTEs to pull the top spend brand, then the top transaction brand, then union the metrics together in the parent select statement.

-- The user data set was corrupted, so I could not view the data set. 

-- includes items where needsFetchReview = TRUE
-- includes inactive users created within the last 6 months
-- includes all rewardsReceiptStatus
