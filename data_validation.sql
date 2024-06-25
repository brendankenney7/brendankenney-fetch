---------------------------------------------------------
-- Exploring structure of each data set

--Findings: Product-level (barcode) data which identifies product attributes, including brand name.
select *
from brand

--Findings: Information about a user's scanned receipt. Includes a nested object which lists product-level data for each individual item on a receipt. "Barcode" or "brandCode" could be used a key to connect to the brand dataset.
select *
from receipt

--Findings: Data corrupted. Field information assumed from instruction information.
select *
from user

--New table created from the nested object 'rewardsReceiptItemList'.
--- See 'detail_flatten.ipynb' for information on how the object was flattened.
--Findings: Includes item level information and can be used to link "brand" to receipt. Also can be used to calculate brand-specifc spend and transactions.

select *
from receipt_detail

---------------------------------------------------------
--Investigation of brandCode relationship to receipt_detail and brand tables

--Findings: brandCode is a text value. Not all entries in brand have a brandCode value  
select distinct _id, brandCode
from brand;

--Findings: Not all barcode values have a brandCode
select distinct _id, barcode, brandCode
from brand

-- Findings: rewardsProductPartnerId is a key for cpg, not item or brand.
select distinct rd.rewardsProductPartnerId, cpg, b.brandCode
from receipt_detail rd
join brand b 
on rd.brandCode = b.brandCode

--------------------------------------------------------
--Investigating barcode and brandCode and as a key

--Findings: barcode seems like a more ideal joinable key than brandCode if joining receipt_detail and brand. This is because brand seems to be a list of items and their brand details, not a list of brands.
select distinct barcode
from receipt_detail
order by barcode desc

select distinct barcode
from brand
order by barcode desc

--Findings: brand has more barcodes than receipt_detail
select count(distinct barcode)
from receipt_detail

select count(distinct barcode)
from brand


--Are all barcodes found in receipt_detail also in brand?
  --Findings: Of 569 barcodes in receipt_detail, only 17 are in Brand
  select distinct rd.barcode,
       b.name
from receipt_detail rd
 join brand b 
    on rd.barcode = b.barcode

--Findings: Of 228 brandCodes in receipt_detail, only 41 are also in brand.
  --Brand is not worth joining to receipt_detail. It adds very little information, if any, and would decrease performance of the query.
  select distinct rd.brandCode,
       b.name
from receipt_detail rd
 join brand b 
    on rd.brandCode = b.brandCode


  
---------------------------------------------------------
--investigation of null brandCode in receipt detail
--Findings: Of 568 items in receipt_detail, 293 do not have a brandCode. This will lead to some gaps in reporting.
with null_table as (
select count(distinct barcode)
from receipt_detail
where brandCode IS NULL),

not_null_table as (
select count(distinct barcode)
from receipt_detail
)

select *
from null_table
UNION
select *
from not_null_table

  
-- Of the 293 items without a brandCode, 237 have an item description. This could be used to derive brandCode and fill in data gaps.
with null_table as (
select count(distinct barcode)
from receipt_detail
where brandCode IS NULL
and description <> 'ITEM NOT FOUND'),

all_missing_bc_table as (
select count(distinct barcode)
from receipt_detail
where brandCode IS NULL
)

select *
from null_table
UNION
select *
from all_missing_bc_table

---------------------------------------------------------
--investigation of relationship between finalPrice and quantityPurchased

--Findings: finalPrice is likely unitPrice * quantityPurchased, but not a conclusive finding.
-- There is a lot of inconsistency with pricing.
  -- Ex. A purchase of 5 'Annie's Macaroni & Cheese Shells, 6 Oz' was $50. Seems high for a per unit cost of boxed Mac and Cheese. A Google search shows Walmart selling the item for about $3 each.
  -- A purchase of 2 'JIF CRMY PNT BTR JAR 40 OZ' was $2, which seems extremely low, even if $2 was the per unit cost. A Google search shows this item at about $8 per unit
  -- Suggests there may be an error if using this field to sum spend by brand. Some brands may be over represented, while others under represented.
--Additionally, all price fields seem to have the same value. What is the actual final price?

select barcode,
       itemPrice,
       priceAfterCoupon,
       discountedItemPrice,
       finalPrice,
       quantityPurchased,
       description
from receipt_detail
where description <> 'ITEM NOT FOUND'
and quantityPurchased > 1


-- Findings: Of the 222 items with values for all 4 price fields, all 4 price fields match eachother for all 222 items
--- Suggests another possible data error where item prices are not properly calculated.
select barcode,
       case when itemPrice = priceAfterCoupon and itemPrice = discountedItemPrice and itemPrice = finalPrice then 1 else 0 end as check,
       itemPrice,
       priceAfterCoupon,
       discountedItemPrice,
       finalPrice,
       quantityPurchased,
       description
from receipt_detail
where description <> 'ITEM NOT FOUND'
and quantityPurchased > 1
and itemPrice is not null
and priceAfterCoupon is not null
and discountedItemPrice is not null
and finalPrice is not null




