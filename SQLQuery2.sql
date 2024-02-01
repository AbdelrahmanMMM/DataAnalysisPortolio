select * 
from PortfolioProject.dbo.NashvilleHousing

--Standarize date format
select saleDate, convert(date, saleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add saleDateConverted date;

update PortfolioProject.dbo.NashvilleHousing
set saleDateConverted = convert(date,saleDate)

select * 
from PortfolioProject.dbo.NashvilleHousing



--Testing if there are null values in the columns
select *
from PortfolioProject.dbo.NashvilleHousing
where uniqueID is null

select *
from PortfolioProject.dbo.NashvilleHousing
where ParcelID is null

select *
from PortfolioProject.dbo.NashvilleHousing
where LandUse is null

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
--There are 29 rows where PropertyAddress is null
--We found out that there are 'Null' values in the PropertyAddress column
--Mabye there are duplicates and one of the duplicates has the right PropertyAddress
--We should not remove duplicates at first because we may delete the row that has the right PropertyAddress not the one that has the 'Null' value
--We will make mirror between the table to put the right address next to the 'Null' value
--It seems that ParcelID should be unique( every parcel is sold once in the sheet we will check that) and the duplicate of it has the PropertyAddress = 'Null'
with uniqueIdTable as (
select distinct(uniqueID) as realUniqueID
from PortfolioProject.dbo.NashvilleHousing
)
select count(realUniqueId)
from uniqueIdTable
--The number of Distinct(uniqueId)=56477 -->1

select count(uniqueId) as uniqueIDCount1
from PortfolioProject.dbo.NashvilleHousing
--The number of uniqueId = 56477         -->2
--from 1, 2 then uniqueId column is really unique/ distinct


--Doing the same with the parcelID
with parcelIDTable as (
select distinct(parcelID) as realparcelID
from PortfolioProject.dbo.NashvilleHousing
)
select count(realparcelID)
from parcelIDTable
--The number of Distinct(parcelID)=48559 -->1

select count(parcelID) as parcelIDCount1
from PortfolioProject.dbo.NashvilleHousing
--The number of parcelID = 56477         -->2
--from 1, 2 then parcelID column has duplicates which means that the parcel may be sold multiple times


--Doing the same with the PropertyAddress(it should have the same number as parcelID
with PropertyAddressTable as (
select distinct(PropertyAddress) as realPropertyAddress
from PortfolioProject.dbo.NashvilleHousing
)
select count(realPropertyAddress)
from PropertyAddressTable
--The number of Distinct(PropertyAddress)=45068 -->1

select count(PropertyAddress) as PropertyAddressCount1
from PortfolioProject.dbo.NashvilleHousing
--The number of PropertyAddress = 56448         -->2
--UniqueIdCount(Distinct-Real),ParcelIDCount,PropertyAddressCount
--56477 56477 , 48559 56477, 45068 56448
-- ParcelIDCount(real)-PropertyAddressCount(real)=56477-56448=29 null values
-- ParcelIDCount(distinct)-PropertyAddressCount(distinct)=48559-45068=3491 //I don't get why their numbers are different that much ;(
-- Number of duplicates for the ParcelId = real-distinct=56477-48559=7918 duplicate


--from 1, 2 then PropertyAddress column has duplicates which means that the parcel may be sold multiple times




--Logically the PropertyAddress is connected to ParcelID so if we have the same ParcelID we 
--should have  the same PropertyAddress so we will search for same ParcelID so that it may
--have the PropertyAddress so we could fill the null values in the propertyAddress column

select * 
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
where a.PropertyAddress is null
and b.PropertyAddress is not null

update a
set a.PropertyAddress = b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
where a.PropertyAddress is null
and b.PropertyAddress is not null

--Checking if there are null values in the other columns
select *
from PortfolioProject.dbo.NashvilleHousing
where OwnerName is null
--The ownerName has nullValues
--The ownerName isn't connected to the ownerAddress as he may left his home and the new inhabitant is included in our sheet(he made a deal to sell his house) so the ownerName isn't connected to the ownerAddress always

--We can analyze this dataset so we can predict the price of certain parcels according to the data we have, the time that has many deals in the year, the optimum Acreage that most people would like to buy, the best specification that customers want in their deal parcel(number of bedrooms, number of fullBaths, number of HalfBaths)

select * 
from PortfolioProject.dbo.NashvilleHousing a


--There are null values for ownerName but we can't restore it or conclude it from the data
--The null values in the other columns doesn't worry me


--Now we need to split the PropertyAddress to make use of the address and the city that are concatenated together
--Using substring

select PropertyAddress,
substring(PropertyAddress, 1,charindex(',',PropertyAddress)-1),
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1,charindex(',',PropertyAddress)-1)

Alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


--Now we want to split the OwnerAddress to (OwnerSplitAddress, OwnerSplitCity, OwnerSplitState)
select OwnerAddress,
parseName(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress,
parseName(replace(ownerAddress,',','.'),2) as OwnerSplitCity,
parseName(replace(ownerAddress,',','.'),1) as OwnerSplitState
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress varchar(255);

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity varchar(255);

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState varchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = parseName(replace(OwnerAddress,',','.'),3) 

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = parseName(replace(ownerAddress,',','.'),2)

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = parseName(replace(ownerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing

--Replacing 'Y' and 'N' with 'Yes' and 'No' in SoldAsVacant column

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else soldAsVacant
end as SoldAsVacantModified
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else soldAsVacant
end

select SoldAsVacant
from PortfolioProject.dbo.NashvilleHousing
where SoldAsVacant = 'Y' or SoldAsVacant = 'N'
--No Result so we are good

select *
from PortfolioProject.dbo.NashvilleHousing

--Removing duplicates from the table
--We have done so after concluding the Null values in the PropertyAddress so we may remove more duplicate(before doing that the 'Null' value was the only difference in the row
with row_num_table as (
select *,
row_number()over(partition by parcelID, SaleDate, SalePrice, OwnerName order by parcelID) as row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *
from row_num_table
where row_num>1

with row_num_table as (
select *,
row_number()over(partition by parcelID, SaleDate, SalePrice, OwnerName order by parcelID) as row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete 
from row_num_table
where row_num>1

--ReRunning the above select we have no result so that is good

--Removing unused columns
select * 
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column LandUse, LegalReference;

