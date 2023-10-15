SELECT *
FROM Project1.dbo.NashvilleHousing

-- Standarized date format
SELECT SaleDate, ConvertedSaleDate--, CONVERT(date, SaleDate) 
FROM Project1.dbo.NashvilleHousing

UPDATE Project1.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Project1.dbo.NashvilleHousing
ADD ConvertedSaleDate date;

UPDATE Project1.dbo.NashvilleHousing
SET ConvertedSaleDate = CONVERT(date, SaleDate)

-- Populate property address
SELECT *
FROM Project1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project1.dbo.NashvilleHousing a
JOIN Project1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project1.dbo.NashvilleHousing a
JOIN Project1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out property address into individual column (address, city, state)
-- CHARINDEX buat nyari di index berapa letak char yang kita cari)
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as AddressSplit, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as CitySplit
FROM Project1.dbo.NashvilleHousing

ALTER TABLE Project1.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Project1.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Project1.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Project1.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Breaking out owner address into individual column (address, city, state)
-- substring pusing bro jd yg ini splitnya pake parsename aja
-- nvarchar vs varchar:
	--varchar (variable-length character string): bisa nampung data char sampe 8k bytes/char. 
		--varchar nyimpen 8 bits data.
	--nvarchar (unicode-length character string): bisa nampung data char sampe 8k bytes juga. 
		--tapi, nvarchar nyimpen data sbg utf-16 / 16bits / 2bytes/char. jadi max cuma bs nyimpen 4k char

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
FROM Project1.dbo.NashvilleHousing

ALTER TABLE Project1.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255), 
OwnerSplitCity NVARCHAR(255), 
OwnerSplitState NVARCHAR(255);

UPDATE Project1.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE Project1.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE Project1.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant
FROM Project1.dbo.NashvilleHousing

SELECT SoldAsVacant, COUNT(SoldAsVacant) --REPLACE(SoldAsVacant, 'Y', 'Yes'), REPLACE(SoldAsVacant, 'N', 'No')
FROM Project1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END as RenameYN
FROM Project1.dbo.NashvilleHousing

UPDATE Project1.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

-- remove duplicates
-- cara 1: pake cte, terus pake windows function

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID) as row_num
FROM Project1.dbo.NashvilleHousing
)

--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- Delete unused column
SELECT *
FROM Project1.dbo.NashvilleHousing

ALTER TABLE Project1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project1.dbo.NashvilleHousing
DROP COLUMN SaleDate