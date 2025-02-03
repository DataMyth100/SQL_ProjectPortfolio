select *
from layoffs_staging;

create table layoffs_staging
like layoffs ;
insert layoffs_staging
select *
from layoffs
;
-- 1. First Stage Is Remove Duplicate
with duplicate_cte as 
(
select *,
row_number() over(partition by company, location, industry, 
total_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)

select *
from duplicate_cte
where row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select*
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(partition by company, location, industry, 
total_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select*
from layoffs_staging2
where row_num > 1
;

delete 
from layoffs_staging2
where row_num > 1;

-- 2. Standardize Data
update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

select*
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'; 

select distinct country, trim(trailing '.' from country) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country) 
where country like 'United States%'
;
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
;
select *
from layoffs_staging2
;

alter table layoffs_staging2
modify column `date` date;

-- 3. Null/Blank Values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. Remove Unnecessary Columns/Rows 

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;