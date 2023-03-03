
select * 
from dbo.NashvilleHousing

--Standardize Date Format
select SaleDate,convert(date,SaleDate) 
from dbo.NashvilleHousing

update dbo.NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table dbo.NashvilleHousing
add SaleDateConverted date

update dbo.NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--Populate Property Address data
select *
from dbo.NashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is NULL

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is NULL

--Breaking out Address into Individual Columns (Address,city,state)
select PropertyAddress
from dbo.NashvilleHousing

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

update dbo.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select *
from dbo.NashvilleHousing

--OwnerAddress
select OwnerAddress
from dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

update dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from dbo.NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from dbo.NashvilleHousing

update dbo.NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

--Remove Duplicates
with RowNumCTE as(
select *,
	row_number()over(partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	order by UniqueID) row_num
from dbo.NashvilleHousing
)

select *
from RowNumCTE 
where row_num >1
--order by PropertyAddress

--Delete Unused Columns

select *
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table dbo.NashvilleHousing
drop column SaleDate

