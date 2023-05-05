/*
Cleaning Data in SQL Queries
*/
select * from project..new

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From project..new

Update new
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE new
Add SaleDateConverted Date;

Update new
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select *
From project..new
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project..new a
JOIN project..new b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project..new a
JOIN project..new b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From project..new
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, -1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From project..new


ALTER TABLE new
Add PropertySplitAddress Nvarchar(255);

Update new
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE new
Add PropertySplitCity Nvarchar(255);

Update new
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select OwnerAddress
From project..new


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project..new

ALTER TABLE new
Add OwnerSplitAddress Nvarchar(255);

Update new
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE new
Add OwnerSplitCity Nvarchar(255);

Update new
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE new
Add OwnerSplitState Nvarchar(255);

Update new
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From project..new
group by SoldAsVacant

Select SoldAsVacant From project..new

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From project..new

Update new
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

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

From project..new
--order by ParcelID
)
Select *
From RowNumCTE


Where row_num > 1
Order by PropertyAddress

Select *
From project..new


ALTER TABLE project..new
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

