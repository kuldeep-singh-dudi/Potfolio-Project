Select *
From project.dbo.nashvillehousing$


----------------------------------------------------------------------------------------------------------------------------
--standardize saledate column

Select SaleDate, CONVERT(Date,SaleDate)
From project.dbo.nashvillehousing$

UPDATE nashvillehousing$
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE nashvillehousing$
Add SaleDate2 Date;

UPDATE nashvillehousing$
SET SaleDate2 = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------
--populate properties adress data

Select *
From project.dbo.nashvillehousing$
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.nashvillehousing$ a
Join project.dbo.nashvillehousing$ b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null



UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.nashvillehousing$ a
Join project.dbo.nashvillehousing$ b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------
--breaking out address into individual columns (address,city,state)

Select PropertyAddress
From project.dbo.nashvillehousing$

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
From project.dbo.nashvillehousing$

ALTER TABLE nashvillehousing$
Add PropertySplitAddress NVarchar(255);

UPDATE nashvillehousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvillehousing$
Add PropertySplitCity NVarchar(255);

UPDATE nashvillehousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From project.dbo.nashvillehousing$

Select OwnerAddress
From project.dbo.nashvillehousing$

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From project.dbo.nashvillehousing$

ALTER TABLE nashvillehousing$
Add OwnerSplitAddress NVarchar(255);

UPDATE nashvillehousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing$
Add OwnerSplitCity NVarchar(255);

UPDATE nashvillehousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvillehousing$
Add OwnerSplitState NVarchar(255);

UPDATE nashvillehousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From project.dbo.nashvillehousing$


------------------------------------------------------------------------------------------------
--change y and n to yes and no in soldasvacant column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From project.dbo.nashvillehousing$
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From project.dbo.nashvillehousing$

UPDATE nashvillehousing$
SET SoldAsVacant=CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From project.dbo.nashvillehousing$
Group by SoldAsVacant
order by 2



-------------------------------------------------------------------------------------------------------------------------------------------------------------
--remove duplicates
--using cte
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID
	) row_num

From project.dbo.nashvillehousing$
)


--Select *
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress


DELETE
From RowNumCTE
Where row_num > 1



-----------------------------------------------------------------------------------------------------------
--delete unused columns

Select *
From project.dbo.nashvillehousing$

ALTER TABLE project.dbo.nashvillehousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE project.dbo.nashvillehousing$
DROP COLUMN SaleDate

Select *
From project.dbo.nashvillehousing$