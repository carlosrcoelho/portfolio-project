/*

Cleaning Data in SQL Queries

*/

select * from nashvilleHousing.nashville_housing;
-- ---------------------------------------------------------------

-- Atualizando a coluna SaleDate na tabela nashville_housing

select SaleDate 
from nashvilleHousing.nashville_housing;

UPDATE nashvilleHousing.nashville_housing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%Y-%m-%d');

-- Selecionando PropertyAddress que estão em branco
SELECT *
FROM nashvilleHousing.nashville_housing
WHERE PropertyAddress = '';

-- --------------------------------------------------------------------------------

-- Populando PropertyAddress que está vazio ('')

-- Selecionando PropertyAddress vazios
SELECT *
FROM nashvilleHousing.nashville_housing
WHERE PropertyAddress = '';

-- Verificando o ParcelID que estão repetidos e possui o mesmo PropertyAddress
select * from nashvilleHousing.nashville_housing
order by ParcelID;

-- Fazendo o preenchimento dos PropertyAddress vazios
UPDATE nashvilleHousing.nashville_housing a
JOIN nashvilleHousing.nashville_housing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '';

-- ---------------------------------------------------------------------------------------
-- Separando o endereço para colunas individual (Endereço, Cidade, Estado) - Usando SUBSTRING

select PropertyAddress 
from nashvilleHousing.nashville_housing;

-- Selecionando apenas o endereço, o -1 ele irá retirar a vírgula que separa das outras infos
select
substring(PropertyAddress, 1, locate(',', PropertyAddress) -1) as Address
from nashvilleHousing.nashville_housing; 

-- Selecionanto também a cidade, o +1 irá pegar após a virgula
select
substring(PropertyAddress, 1, locate(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress)) as City
from nashvilleHousing.nashville_housing; 

-- Add the Address column
ALTER TABLE nashvilleHousing.nashville_housing
ADD COLUMN Address VARCHAR(255);

-- Add the City column
ALTER TABLE nashvilleHousing.nashville_housing
ADD COLUMN City VARCHAR(255);

-- Update the Address column
UPDATE nashvilleHousing.nashville_housing
SET Address = substring(PropertyAddress, 1, locate(',', PropertyAddress) -1);

-- Update the City column
UPDATE nashvilleHousing.nashville_housing
SET City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress));

-- Separando o endereço para colunas individual (Endereço, Cidade, Estado) - Usando SUBSTRING_INDEX

select OwnerAddress
from nashvilleHousing.nashville_housing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', -1) AS InfoAfterComma
FROM nashvilleHousing.nashville_housing;

SELECT 
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS Street,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)) AS City,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS State
FROM nashvilleHousing.nashville_housing;

-- Add the Address column
ALTER TABLE nashvilleHousing.nashville_housing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

-- Add the City column
ALTER TABLE nashvilleHousing.nashville_housing
ADD COLUMN OwnerCity VARCHAR(255);

-- Add the State column
ALTER TABLE nashvilleHousing.nashville_housing
ADD COLUMN OwnerState VARCHAR(255);

-- Update the Address column
UPDATE nashvilleHousing.nashville_housing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

-- Update the City column
UPDATE nashvilleHousing.nashville_housing
SET OwnerCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1));

-- Update the State column
UPDATE nashvilleHousing.nashville_housing
SET OwnerState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

-- ---------------------------------------------------------------------------------------------------

-- Mudar o Y e o N da coluna 'SoldAsVancant'

select * 
from nashvilleHousing.nashville_housing;

-- Verificando os valores distintos
select distinct(SoldAsVacant)
from nashvilleHousing.nashville_housing;

-- Realizando a contagem dos valores
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvilleHousing.nashville_housing
group by SoldAsVacant
order by 2;

SELECT 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacant
FROM nashvilleHousing.nashville_housing;

UPDATE nashvilleHousing.nashville_housing
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- -----------------------------------------------------------------------

-- Remover Duplicados
select * 
from nashvilleHousing.nashville_housing;


-- A consulta retorna as linhas duplicadas dentro de cada grupo definido pelas colunas mencionadas e a ordenação pela coluna 'UniqueID'
SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM nashvilleHousing.nashville_housing
) AS subquery
WHERE row_num > 1;

-- Fazendo a remoção
DELETE FROM nashvilleHousing.nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM nashvilleHousing.nashville_housing
    ) AS subquery
    WHERE row_num > 1
);

-- -----------------------------------------------------------------------
-- Deletar Colunas que não serão usadas

select * 
from nashvilleHousing.nashville_housing;

-- removendo as colunas
ALTER TABLE nashvilleHousing.nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN OwnerCity,
DROP COLUMN OwnerSplitAddress;

-- alterando o nome da coluna OwnerState
ALTER TABLE nashvilleHousing.nashville_housing
CHANGE COLUMN OwnerState State VARCHAR(255);

ALTER TABLE nashvilleHousing.nashville_housing
DROP COLUMN SaleDate;



