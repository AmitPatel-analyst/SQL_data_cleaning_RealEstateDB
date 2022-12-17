/* SQL DATA CLEANING using Nashville housing prices database */
select top 10* from Nashville_Housing

--Converting sale date format
select SaleDate, CONVERT(Date,SaleDate) from Nashville_Housing

-- add SaleDateconv column 
alter table Nashville_Housing
add SaleDateconv date

update Nashville_Housing
set SaleDateconv =CONVERT(Date,SaleDate);

--Removing null from property address
select * 
from Nashville_Housing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

select * from Nashville_Housing
where ParcelID = '044 05 0 135.00'

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- check PropertyAddress is not null
select * from Nashville_Housing
where PropertyAddress is null  -- it should not showing any null 

--Breaking property address into address, city, state
select PropertyAddress
from Nashville_Housing

select PropertyAddress,
		SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1) as PropAddress
		,RIGHT(PropertyAddress, CharIndex(',',REVERSE(PropertyAddress)) - 1) as PropCity
from Nashville_Housing

alter table Nashville_Housing
add PropAddress nvarchar(255)

update Nashville_Housing
set PropAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1)

alter table Nashville_Housing
add PropCity nvarchar(255)

update Nashville_Housing
set PropCity = RIGHT(PropertyAddress, CharIndex(',',REVERSE(PropertyAddress)) - 1)

Select PropertyAddress,PropAddress,PropCity from Nashville_Housing

--Breaking down Owner address

select OwnerAddress
from Nashville_Housing

Select
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From    Nashville_Housing

alter table Nashville_Housing
add OwnerAdd nvarchar(255)

update Nashville_Housing
set OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

alter table Nashville_Housing
add OwnerCity nvarchar(255)

update Nashville_Housing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

alter table Nashville_Housing
add OwnerState nvarchar(255)

update Nashville_Housing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select OwnerAdd,OwnerCity,OwnerState
from Nashville_Housing

--Convert 'SoldAsVacant' column to Yes/No 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
order by 2

select	SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 else SoldAsVacant end                   -- compulsory put else col name otherwise null value showing
from	 Nashville_Housing

update Nashville_Housing
set SoldAsVacant = CASE	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 else SoldAsVacant end 

		-- now check columns data 				 
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
order by 2

--Removing duplicate records

Select 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY	UniqueID 
					) as row_num , *
From Nashville_Housing
order by ParcelID

with row_num as(
Select 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY	UniqueID 
					) as row_num , *
From Nashville_Housing
 )

select * from row_num 
where row_num >1

-- delete now that duplicate rows
with row_num as(
Select 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY	UniqueID 
					) as row_num , *
From Nashville_Housing
 )

select * from row_num 
where row_num >1
