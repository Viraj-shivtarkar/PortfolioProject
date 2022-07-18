
select * 
from [SQL Project].dbo.Housing_data;

-- Date Formating

select SaleDate , CONVERT(date,SaleDate)
from [SQL Project].dbo.Housing_data;

update [SQL Project].dbo.Housing_data
set SaleDate = CONVERT(date,SaleDate);

alter table housing_data
add SaleDateConverted date;

update [SQL Project]..Housing_data
set SaleDateConverted = CONVERT(date,SaleDate);


-- Populate Property Address Data

Select  UniqueID, PropertyAddress
From [SQL Project]..Housing_data
Where PropertyAddress is null; -- Here we see that some Property Address are not field 

-- Hence to Populate the Property Address Data , We will use Self JOIN 
-- In this table we found that where ParcelID is same then the PropertyAddress are also same, but differentiate by UniqueID   

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
From [SQL Project]..Housing_data a
JOIN [SQL Project]..Housing_data b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-- by using ISNULL Funcition we can populate the PropertyAddress Data

update a 
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [SQL Project]..Housing_data a
JOIN [SQL Project]..Housing_data b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


-- Breaking Address Data into Individual colums (Address, City, State)

Select substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as NewAddress,  -- Substring help us to trim the data we want/ CharIndex help us to locate specific character 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From [SQL Project]..Housing_data;

alter table housing_data
add PropertySplitAddress Char(255);

update [SQL Project]..Housing_data
set PropertySplitAddress = substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1);

alter table housing_data
add PropertySplitAddressCity Char(255);

update [SQL Project]..Housing_data
set PropertySplitAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

select *
From [SQL Project]..Housing_data


-- Another way of Breaking Address Data into Individual colums (using OwnerAddress)

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerAddress  -- PARSENAME function returns the specific part of given string
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerCity
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerState
From [SQL Project]..Housing_data;

Alter Table [SQL Project]..Housing_data  -- OwnerAddress
Add OwnerSplitAddress char(255);

Update [SQL Project]..Housing_data
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3); 

Alter Table [SQL Project]..Housing_data  -- OwnerCity
Add OwnerCityAddress char(255);

Update [SQL Project]..Housing_data
set OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);  

Alter Table [SQL Project]..Housing_data  -- OwnerCity
Add OwnerStateAddress char(255);

Update [SQL Project]..Housing_data
set OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);  


-- In the Column SoldAsVacant we can see some data in 'Y' an 'N'
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [SQL Project]..Housing_data
group by SoldAsVacant
Order by 2;

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From [SQL Project]..Housing_data;

Update [SQL Project]..Housing_data
set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End;

Select * 
From [SQL Project]..Housing_data;


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [SQL Project]..Housing_data
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From [SQL Project]..Housing_data;


-- Delete Unused Columns


ALTER TABLE [SQL Project]..Housing_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

Select *
From [SQL Project]..Housing_data;
