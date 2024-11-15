-- Data Cleaning
SELECT *
FROM world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or  blank Values
-- 4. Remove any Columns

-- making duplicate table for data cleaning
CREATE TABLE layoffs_cleaning
LIKE world_layoffs.layoffs; 

SELECT *
FROM layoffs_cleaning;

INSERT layoffs_cleaning
SELECT *
FROM layoffs;


-- 1. Remove Duplicates

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_cleaning
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_cleaning2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_cleaning2;

INSERT INTO  layoffs_cleaning2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_cleaning;

DELETE # deletes the duplicates
FROM layoffs_cleaning2
WHERE row_num > 1;

SELECT * #checking for duplicates after delete
FROM layoffs_cleaning2
WHERE row_num > 1;

-- 2. Standardize the Data
-- removing unnecessary spaces
SELECT company, TRIM(company)
FROM layoffs_cleaning2;

UPDATE layoffs_cleaning2
SET company = TRIM(company);

-- updating words that are the same by written differently
SELECT DISTINCT(industry)
FROM layoffs_cleaning2
ORDER BY 1;

SELECT *
FROM layoffs_cleaning2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_cleaning2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- removing unnecessary characters at the end of words
SELECT DISTINCT(country)
FROM layoffs_cleaning2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_cleaning2
ORDER BY 1;

UPDATE layoffs_cleaning2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- changing `date` datatype from text to date
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_cleaning2;

UPDATE layoffs_cleaning2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_cleaning2
MODIFY COLUMN `date` DATE;


-- 3. Null Values or  blank Values
SELECT *
FROM layoffs_cleaning2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_cleaning2
WHERE industry IS NULL OR industry = '';

-- populating null values
SELECT *
FROM layoffs_cleaning2
WHERE company = 'Airbnb';

UPDATE layoffs_cleaning2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_cleaning2 t1
JOIN layoffs_cleaning2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_cleaning2 t1
JOIN layoffs_cleaning2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. Remove any unnecessary Columns/Rows
DELETE
FROM layoffs_cleaning2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_cleaning2
DROP COLUMN row_num;

SELECT *
FROM layoffs_cleaning2;