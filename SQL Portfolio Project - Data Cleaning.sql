SELECT
	*
FROM
	NashvilleHousing

--Standardize the date format
SELECT
	SaleDate, CONVERT(date, SaleDate)
FROM
	NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT
	SaleDateConverted
FROM
	NashvilleHousing
----------------------------------------------------------------------------------------------------------------

-- Populate the Property Address data
SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	NashvilleHousing a
JOIN 
	NashvilleHousing b
ON
	a.ParcelID = b.ParcelID and 
	a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null
ORDER BY
	a.ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	NashvilleHousing a
JOIN 
	NashvilleHousing b
ON
	a.ParcelID = b.ParcelID and 
	a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null
--------------------------------------------------------------------------------------

--Breaking out address into individual columns (address, city, columns)
SELECT
	PropertyAddress
FROM
	NashvilleHousing


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM
	NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT
	*
FROM
	NashvilleHousing

--Splitting the Owner Address

SELECT
	OwnerAddress
FROM
	NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM	
	NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT
	*
FROM 
	NashvilleHousing


------------------------------------------------------------------------------------------------------------------------

--Change Y and N to 'YES' and 'NO' in 'Sold as Vacant' Field

SELECT 
	Distinct(SoldAsVacant), COUNT(SoldasVacant)
FROM 
	NashvilleHousing

GROUP BY
	SoldAsVacant
ORDER BY
	2

SELECT
	SoldAsVacant,
	CASE
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
	END
FROM	
	NashvilleHousing
WHERE
	SoldAsVacant = 'Y' or SoldAsVacant = 'N'

Update NashvilleHousing
SET SoldAsVacant = CASE
						When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
					END

--------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES
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

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate