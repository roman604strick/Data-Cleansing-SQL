-- Cleaning data using SQL queries
SELECT *
FROM dbo.HouseSetTwo


-- Standardize Date Format using CONVERT function
SELECT SaleDateConverted, CONVERT(DATE,SaleDate) -- CONVERT function used to convert SalesDate to legitmate date
FROM dbo.HouseSetTwo

UPDATE housesettwo
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE housesettwo
ADD SaleDateConverted DATE;

UPDATE housesettwo
SET SaleDateConverted = CONVERT(DATE,SaleDate)




-- Populate Property Address data
SELECT *
FROM dbo.HouseSetTwo
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
FROM HouseSetTwo AS a
JOIN HouseSetTwo AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
-- saying when property address is null it will populate it into the other property update
-- joined the same id to itself wherer the ParcelID is the same but not the same row

UPDATE a
SET propertyaddress = ISNULL(A.propertyaddress, b.PropertyAddress) -- If the first propert address is null it will populate with the information in the second property address
FROM HouseSetTwo AS a
JOIN HouseSetTwo AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL




-- Breaking out address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM dbo.HouseSetTwo
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID

SELECT -- code below will look at property address and will got first value and go until first comma
SUBSTRING(Propertyaddress, 1, CHARINDEX(',' , Propertyaddress)-1 ) AS Address -- charindex will allow us to search for a specific value, one in the substring will go to first delimeter
, SUBSTRING(Propertyaddress, CHARINDEX(',' , Propertyaddress)+1 , LEN(PROPERTYADDRESS)) AS Address
FROM dbo.HouseSetTwo


ALTER TABLE housesettwo
ADD PropertSplitAddress NVARCHAR(255);

UPDATE housesettwo
SET PropertSplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',' , Propertyaddress)-1 )


ALTER TABLE housesettwo
ADD PropertySplitCity NVARCHAR(255);

UPDATE housesettwo
SET PropertySplitCity = SUBSTRING(Propertyaddress, CHARINDEX(',' , Propertyaddress)+1 , LEN(PROPERTYADDRESS))


SELECT *
FROM dbo.HouseSetTwo




SELECT OwnerAddress
FROM dbo.HouseSetTwo

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)-- PARSE ONLY USEFUL WITH PERIODS
, PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
, PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM dbo.HouseSetTwo
-- will break down results into address, city, state


ALTER TABLE housesettwo
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE housesettwo
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)



ALTER TABLE housesettwo
ADD OwnerSplitCity NVARCHAR(255);

UPDATE housesettwo
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)



ALTER TABLE housesettwo
ADD OwnerSplitState NVARCHAR(255);

UPDATE housesettwo
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

SELECT *
FROM HouseSetTwo





-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HouseSetTwo
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM HouseSetTwo


UPDATE HouseSetTwo
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END




-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM HouseSetTwo
--ORDER BY ParcelID
)


SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




--Delete unused columns
SELECT *
FROM HouseSetTwo


ALTER TABLE housesettwo
DROP COLUMN owneraddress, taxdistrict, propertyaddress, saledate