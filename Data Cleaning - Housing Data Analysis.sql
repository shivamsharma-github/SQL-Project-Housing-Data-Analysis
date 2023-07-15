-- Project - Data Cleaning In SQL

-- Looking at the data

SELECT TOP 10 *
FROM nashville_housing_data;


-- Standardize data format in SaleDate Column from DATETIME To Date 

ALTER TABLE nashville_housing_data
ALTER COLUMN SaleDate DATE;


-- Populate Property Address Data

SELECT *
FROM nashville_housing_data
WHERE PropertyAddress IS NULL;

SELECT a.ParcelID, a.PropertyAddress, B.ParcelID, B.PropertyAddress, 
ISNULL(A.PropertyAddress, B.PropertyAddress) AS missing_address
FROM nashville_housing_data A INNER JOIN nashville_housing_data B
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM nashville_housing_data A INNER JOIN nashville_housing_data B
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


-- Splitting PropertyAddress into individual columns (Address, City)

SELECT PropertyAddress
FROM nashville_housing_data;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PropertySplitAddress,
TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))) AS PropertySplitCity
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashville_housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE nashville_housing_data
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashville_housing_data
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)));


-- Splitting OwnerAddress into individual columns (Address, City, State)

SELECT OwnerAddress
FROM nashville_housing_data;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)) AS OwnerSplitCity,
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) AS OwnerSplitState
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashville_housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE nashville_housing_data
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashville_housing_data
SET OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2));

ALTER TABLE nashville_housing_data
ADD OwnerSplitState NVARCHAR(25);

UPDATE nashville_housing_data
SET OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1));


-- Replace values 'Y' & 'N' To 'Yes' & 'No' In SoldAsVacant Column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM nashville_housing_data
GROUP BY SoldAsVacant;


SELECT
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO' 
	ELSE SoldAsVacant
END
FROM nashville_housing_data; 


UPDATE nashville_housing_data
SET SoldAsVacant = CASE 
					WHEN SoldAsVacant = 'Y' THEN 'YES'
					WHEN SoldAsVacant = 'N' THEN 'NO' 
					ELSE SoldAsVacant
				   END;


-- Removing Duplicates from our data. Please note this is not advisable when working on real dataset.

WITH row_num_cte AS (
SELECT *, 
ROW_NUMBER() OVER(
		PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
		ORDER BY UniqueID) AS row_num
FROM nashville_housing_data)
DELETE
FROM row_num_cte
WHERE row_num > 1;


-- Removing unused columns from our data - It is not advisable to remove columns from original dataset

ALTER TABLE nashville_housing_data
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;



------------------------------------------ THE END -----------------------------------------