---------------------------------------------------------
-- Exploring structure of each data set
select *
from brand

select *
from receipt_detail

select *
from receipt

select *
from user

---------------------------------------------------------
--Investigation of brandCode between receipt_detail and brand tables
select distinct _id, brandCode
from brand;

select distinct rewardsProductPartnerId, brandCode
from receipt_detail

select distinct _id, barcode, brandCode
from brand

select distinct rd.rewardsProductPartnerId, cpg
from receipt_detail rd
join brand b 
on rd.brandCode = b.brandCode

---------------------------------------------------------
-- Looking into the relationship between name and brandCode
-- Found that about 35% of non-test "name" values do not have associated brandCode values
select distinct name, brandCode
from brand
order by name

---------------------------------------------------------
--investigation of null brandCode in receipt detail
--Findings: almost half of items do not have a brand code
with null_table as (
select count(barcode)
from receipt_detail
where brandCode IS NULL),

not_null_table as (
select count(barcode)
from receipt_detail
where brandCode IS NOT NULL)

select *
from null_table
UNION
select *
from not_null_table




