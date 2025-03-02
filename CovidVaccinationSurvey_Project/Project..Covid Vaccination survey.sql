SELECT*
FROM project1..CovidDeaths
ORDER BY 3,4;

SELECT*
FROM project1..CovidVaccinations
ORDER BY 3,4;

-- Looking at Total Death Vs Total Cases
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases,4)*100 as DeathsPrecentage
FROM project1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Population Vs Total Cases
-- Show Precentage of Population Get Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PrecentagePopulationInfected
FROM project1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compare To Population

SELECT location, population, MAX(total_cases), MAX((total_cases)/population)*100 as PrecentagePopulationInfected
FROM project1..CovidDeaths
WHERE continent is not null
--WHERE LOCATION LIKE '%iraq%'
GROUP BY location, population
ORDER BY PrecentagePopulationInfected DESC

-- Showing Countries With Highest Death By Location

SELECT location, MAX(cast(total_deaths as int)) as  TotalDeath
FROM project1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeath DESC

-- Showing Countries With Highest Death By Continent

SELECT continent, MAX(cast(total_deaths as int)) as  TotalDeath
FROM project1..CovidDeaths
WHERE location is not null
GROUP BY continent
ORDER BY TotalDeath DESC

-- GLOBAL NUMBER OF The World

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- GLOBAL NUMBERs
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project1..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/population)*100 as VacPop_Rate
FROM popvsvac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(	
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..CovidDeaths dea
Join project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
GO

SELECT *
FROM PercentPopulationVaccinated

