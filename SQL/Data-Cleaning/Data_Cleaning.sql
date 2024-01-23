SELECT 
    *
FROM
    NashvilleHousing;
    
# Standardize date format

Select SaleDate, CONVERT(SaleDate, DATE)
FROM NashvilleHousing;

SELECT SaleDate
FROM NashvilleHousing;

# Populate property address data

Select *
FROM NashvilleHousing
# WHERE PropertyAddress is null
ORDER BY ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

-- Use temporary table to update property address


DROP TEMPORARY TABLE IF EXISTS UpdatePropertyAddress;
CREATE TEMPORARY TABLE UpdatePropertyAddress(
a_ParcelID VARCHAR(50), 
a_PropertyAddress VARCHAR(100), 
b_ParceID VARCHAR(50), 
b_Property_Address VARCHAR(100)
);

INSERT INTO UpdatePropertyAddress
(SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL);

UPDATE NashvilleHousing
INNER JOIN UpdatePropertyAddress
ON NashvilleHousing.ParcelID = UpdatePropertyAddress.a_ParcelID
SET NashvilleHousing.PropertyAddress = UpdatePropertyAddress.b_Property_Address;
                      
-- Returns no NULL values, shows that PropertyAddress has been updated

SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing;
-- WHERE PropertyAddress is NULL
-- ORDER BY ParcelID

-- USE SUBSTRING function to look at property address column at position one. Use LOCATE function to look 
-- for a specific string/char, in a particular column name, returning the char num  ',' is located at, 
-- so adding -1 at the end of the SUBSTRING function would take away the comma

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) AS City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(",", PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(",", PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity 
FROM NashvilleHousing;

-- USE SUBSTRING_INDEX instead of SUBSTRING to split the Owner Address

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',', -1) AS City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',', -1);

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT *
FROM NashvilleHousing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM NashvilleHousing; 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;
    
    
-- Remove Duplicates
-- Gives error 1288, saying target CTE of the DELETE is not updatable 

WITH Row_Num_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
					UniqueID
                    ) AS row_num
				
FROM NashvilleHousing)
DELETE 
FROM Row_Num_CTE
WHERE row_num > 1;

-- This is the code from Google BARD and it works 

DELETE FROM NashvilleHousing
WHERE UniqueID NOT IN (
    SELECT UniqueID
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                ORDER BY 
                    UniqueID
            ) AS row_num
        FROM NashvilleHousing
    ) subquery
    WHERE row_num = 1
    );

-- Delete Unused Columns

SELECT * 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

-- Check the final data cleaning results

SELECT * 
FROM NashvilleHousing;