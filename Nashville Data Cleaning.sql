/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM NashvilleHousing



-- Standardize Date Format


Select SaleDateUpdated, 
       CONVERT(Date, SaleDate)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateUpdated Date;

Update NashvilleHousing
SET SaleDateUpdated = CONVERT(Date, SaleDate)
  


-- This function allows you to pull the part of the date you are interested in.


Select getdate() as actual_date,
       DATEPART(day,getdate()) as date_day,
	   DATEPART(month,getdate()) as date_month,
	   DATEPART(year,getdate()) as date_year
From NashvilleHousing
 


--Populate Property Address Data


SELECT Propertyaddress
FROM NashvilleHousing
where PropertyAddress is null


SELECT *
FROM NashVilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress,
       ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
    ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] != nh2.[UniqueID ]
WHERE nh1.PropertyAddress is null

UPDATE nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress) 
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
    ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] != nh2.[UniqueID ]
WHERE nh1.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, city, state)

 
Select PropertyAddress,
	   LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) as PropertySplitAddress,
	   RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) as PropertySplitCity
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

Select *
From NashvilleHousing
  
--Owner Address

/*
Select OwnerAddress,
	   LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress)-1) as PropertySplitAddress,
	   LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress)-1,REPLACE(OwnerAddress, ',', '.')) as PropertySplitCity,
	   RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',', PropertyAddress)) as PropertySplitState
From NashvilleHousing 
*/

Select
     PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Lets add an email address for each Owner Name using CTE

WITH CTE_email as(
              Select PropertyAddress,
			         OwnerSplitState,
	          LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) as PropertySplitAddress,
	          RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) as PropertySplitCity
              From NashvilleHousing)
Select PropertySplitAddress,
       PropertySplitCity,
	  LOWER(CONCAT(REPLACE(PropertySplitAddress,' ', ''), '.', PropertySplitCity, '@', OwnerSplitState, '.com')) as email
From CTE_email


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

--Using the CASE statement
Select SoldAsVacant,
      CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	       WHEN SoldAsVacant = 'N' THEN 'NO'
		   ELSE SoldAsVacant
	  END 
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	       WHEN SoldAsVacant = 'N' THEN 'NO'
		   ELSE SoldAsVacant
	  END 

	  

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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing

              


-- Delete Unused Columns

Select *
From NashvilleHousing
Order by [UniqueID ]

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate, SaleDateConverted




