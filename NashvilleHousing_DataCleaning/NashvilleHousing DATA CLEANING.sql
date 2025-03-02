USE project1

SELECT *
FROM project1..NashvilleHousing

--------------------------------------------------------------------------------------------

-- Standardize Date Format "Convert Date"

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM project1..NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(DATE,Saledate)

--SELECT CONVERT(DATE,Saledate) as convertdate
--FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaledateConverted DATE

UPDATE NashvilleHousing
SET SaledateConverted = CONVERT(DATE,Saledate)

SELECT SaleDate, SaledateConverted
FROM project1..NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM project1..NashvilleHousing
WHERE ParcelID = '025 07 0 031.00'

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1..NashvilleHousing a
JOIN project1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1..NashvilleHousing a
JOIN project1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT *
FROM project1..NashvilleHousing
WHERE PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as adress,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as city
FROM project1..NashvilleHousing

ALTER TABLE project1..NashvilleHousing
ADD AdressSplited NVARCHAR(255); 

UPDATE project1..NashvilleHousing
SET AdressSplited = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE project1..NashvilleHousing
ADD CitySplited NVARCHAR(255); 

UPDATE project1..NashvilleHousing
SET CitySplited = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------

SELECT OwnerAddress, PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2), 
PARSENAME(Replace(OwnerAddress, ',','.'),1) 
FROM project1..NashvilleHousing

ALTER TABLE project1..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);


UPDATE project1..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3),
	OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM project1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count(SoldAsVacant) 

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant 
END
FROM project1..NashvilleHousing

UPDATE project1..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant 
END
FROM project1..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RownumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				 ORDER BY
					UniqueID
					) as row_num
FROM project1..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM project1..NashvilleHousing

ALTER TABLE project1..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate,OwnerAddress