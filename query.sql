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
    join user_ u
    on u._id = r.userId
where u.created_date >= DATEADD('month', -6, GETDATE())
group by rd.brandCode, b.name
order by totalSpendLast6MonthUser desc

--includes items where needsFetchReview = TRUE
--includes inactive users created within the last 6 months
--includes all rewardsReceiptStatus