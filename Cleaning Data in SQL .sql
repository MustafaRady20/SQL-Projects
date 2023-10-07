/* cleaning Data in SQL Queries */

SELECT * 
FROM data_analyst.dbo.nashvilleHousing
----------------------------------------------------------------------------
-- Standrize Date Formate

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM nashvilleHousing

AlTER TABLE nashvilleHousing 
ADD SaleDateConverted Date;

UPDATE nashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------
-- Populate Property address

SELECT a.ParcelID , a.PropertyAddress ,b.ParcelID , b.PropertyAddress,
isNULL(a.PropertyAddress ,b.PropertyAddress )
FROM nashvilleHousing a JOIN nashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a SET PropertyAddress = isNULL(a.PropertyAddress ,b.PropertyAddress )
FROM nashvilleHousing a JOIN nashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL



--------------------------------------------------------------------

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) 
AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM nashvilleHousing


-- ADD New Column To nashvilleHousing Table
ALTER TABLE nashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255)

-- Update PropertySplitAddress With new Values
UPDATE nashvilleHousing SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) 

-- ADD New Column To nashvilleHousing Table
ALTER TABLE nashvilleHousing 
ADD PropertySplitCity NVARCHAR(255)

-- Update PropertySplitCity With new Values
UPDATE nashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) 


-- SHOW Table After updates 
SELECT * 
FROM data_analyst.dbo.nashvilleHousing



SELECT OwnerAddress
FROM data_analyst.dbo.nashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM data_analyst.dbo.nashvilleHousing


ALTER TABLE data_analyst.dbo.nashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE data_analyst.dbo.nashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE data_analyst.dbo.nashvilleHousing 
ADD OwnerSplitState NVARCHAR(255)

UPDATE data_analyst.dbo.nashvilleHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE data_analyst.dbo.nashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

UPDATE data_analyst.dbo.nashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold As Vacant' filed


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM data_analyst.dbo.nashvilleHousing
GROUP BY SoldAsVacant

--

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM data_analyst.dbo.nashvilleHousing

--

UPDATE data_analyst.dbo.nashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

 

---------------------------------------------------------------------------------
-- DELETE DUPLICATE ROWS
	WITH RowNumCTE 
	AS (
	SELECT *, 
	ROW_NUMBER() OVER (
			  PARTITION BY ParcelID,
						   PropertyAddress,
						   SaleDate,
						   SalePrice,
						   LegalReference
			 ORDER BY UniqueID) row_num
	FROM data_analyst.dbo.nashvilleHousing

	)

DELETE 
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------
-- DELETE Unusable Columns

SELECT * FROM data_analyst.dbo.nashvilleHousing 


ALTER TABLE data_analyst.dbo.nashvilleHousing 
DROP COLUMN PropertyAddress, SaleDate , OwnerAddress, TaxDistrict