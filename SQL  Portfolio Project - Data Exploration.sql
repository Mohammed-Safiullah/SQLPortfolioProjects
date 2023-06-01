SELECT
	*
FROM
	CovidDeaths
WHERE
	continent is NOT NULL
ORDER BY 
	3,4

	
	-- Looking at Total Cases vs Total Deaths

SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	CovidDeaths
WHERE
	continent is NOT NULL
ORDER BY
	location,
	date

	-- Looking at Total Cases vs Total Deaths for United Kingdom
SELECT
	location,
	SUM(new_cases) as [TotalCases],
	SUM(cast(new_deaths as int)) as [TotalDeaths]
FROM
	CovidDeaths
WHERE
	location like '%Kingdom'
	and
	continent is NOT NULL
GROUP BY
	location



	-- Shows likeiyhood of dying if you contract covid in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) *100 as DeathPercentage
FROM
	CovidDeaths
WHERE
	location like '%kingdom'
ORDER BY
	1,
	2

	--Looking at Total Cases vs Population
	--Shows what Percentage of Population got covid
SELECT
	location,
	date,
	population,
	total_cases,
	total_deaths,
	round(((total_deaths/total_cases)*100),2) as DeathPercentage,
	round(((total_cases/population) * 100),2) as [PercentPopulationInfected]

FROM
	CovidDeaths
ORDER BY
	1,
	2

	--Looking at Highest Infection Rate compared to Population
SELECT
	location,
	population,
	MAX(total_cases) as [HighestInfectionCount],
	MAX(total_cases/population) *100  as [PercentPopulationInfected]
FROM
	CovidDeaths
GROUP BY
	location,
	population
ORDER BY
	4 DESC


	--Showing countries with highest death count per population
	-- WHERE Continent is NOT NULL

SELECT
	location,
	MAX(CAST(total_deaths as int)) as [Highest Death Count]
FROM
	CovidDeaths
WHERE
	continent is NOT NULL
GROUP BY
	location
ORDER BY
	2 DESC

	-- WHERE Continent is NULL
SELECT
	location,
	MAX(CAST(total_deaths as int)) as [Highest Death Count]
FROM
	CovidDeaths
WHERE
	continent is  NULL
GROUP BY
	location
ORDER BY
	2 DESC

	--Breaking things down by Continent
	--Showing highest death count by Continent

SELECT
	continent,
	MAX(CAST(total_deaths as int)) as [Highest Death Count]
FROM
	CovidDeaths
WHERE
	continent is  NOT NULL
GROUP BY
	continent
ORDER BY
	2 DESC
	
	--Global Numbers

SELECT
	date,
	Sum(new_cases) as [Total Cases],
	sum(cast(new_deaths as int)) as [Total Deaths],
	sum(cast(new_deaths as int))/Sum(new_cases) * 100 as 'Death Percentage Worldwide'
FROM
	CovidDeaths
WHERE
	continent is Not Null
GROUP BY
	date
ORDER BY
	date

	--Showing Total Death percentage worldwide
SELECT
	Sum(new_cases) as [Total Cases],
	sum(cast(new_deaths as int)) as [Total Deaths],
	sum(cast(new_deaths as int))/Sum(new_cases) * 100 as 'Death Percentage Worldwide'
FROM
	CovidDeaths
WHERE
	continent is Not Null

	--Joining CovidDeaths and CovidVaccination tables together
	--Looking at Total Population Vs Vaccinations
	
		--Creating a CTE for Population vs Vaccinations

 with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
 as
(
SELECT
	CDeaths.continent,
	CDeaths.location,
	CDeaths.date,
	population,
	CVax.new_vaccinations,
	sum(Convert(int,CVax.new_vaccinations)) OVER (Partition By CDeaths.location ORDER BY CDeaths.location, CDeaths.date) as RollingPeopleVaccinated
FROM
	CovidDeaths as CDeaths
JOIN
	CovidVaccinations as CVax
ON
	CDeaths.location = CVax.location and
	CDeaths.date = CVax.date
WHERE
	CDeaths.continent is not null
--ORDER BY
--	2,
--	3
)

Select
	*, (RollingPeopleVaccinated/Population) *100
From
	PopvsVac


	--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	CDeaths.continent,
	CDeaths.location,
	CDeaths.date,
	population,
	CVax.new_vaccinations,
	sum(Convert(int,CVax.new_vaccinations)) OVER (Partition By CDeaths.location ORDER BY CDeaths.location, CDeaths.date) as RollingPeopleVaccinated
FROM
	CovidDeaths as CDeaths
JOIN
	CovidVaccinations as CVax
ON
	CDeaths.location = CVax.location and
	CDeaths.date = CVax.date
--WHERE
--	CDeaths.continent is not null
--ORDER BY
--	2,
--	3

Select
	*, (RollingPeopleVaccinated/Population) *100
From
	#PercentPopulationVaccinated


--Creating a view to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT
	CDeaths.continent,
	CDeaths.location,
	CDeaths.date,
	population,
	CVax.new_vaccinations,
	sum(Convert(int,CVax.new_vaccinations)) OVER (Partition By CDeaths.location ORDER BY CDeaths.location, CDeaths.date) as RollingPeopleVaccinated
FROM
	CovidDeaths as CDeaths
JOIN
	CovidVaccinations as CVax
ON
	CDeaths.location = CVax.location and
	CDeaths.date = CVax.date
WHERE
	CDeaths.continent is not null
--ORDER BY
--	2,
--	3