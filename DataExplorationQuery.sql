SELECT *
FROM Project1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Project1.dbo.CovidVaccinations$
--ORDER BY 3,4

-- Select data that we're gonna using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1.dbo.CovidDeaths$
ORDER BY 1,2

-- Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1.dbo.CovidDeaths$
--WHERE location like '%indonesia%'
ORDER BY 1,2

-- Total cases vs population
SELECT location, date, population, total_cases, (total_deaths/population)*100 as DeathPercentage
FROM Project1.dbo.CovidDeaths$
--WHERE location like '%indonesia%'
ORDER BY 1,2

-- Country with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX(total_cases/population)*100 as PercentPopulationInfected
FROM Project1.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population
--SELECT location, MAX(total_deaths) as TotalDeathsCount
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Project1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- Break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Project1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

-- Continent with highest deaths count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Project1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

-- Global numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM Project1.dbo.CovidDeaths$
--WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total population vs vaccinations
SELECT d.continent, d.location, d.date,
	d.population, v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) OVER(Partition by d.location ORDER BY d.location, d.date)
	as RollingPeopleVaccinated/
  --SUM(CONVERT(int, v.new_vaccinations))
FROM Project1.dbo.CovidDeaths$ d
JOIN Project1.dbo.CovidVaccinations$ v
	ON d.location = v.location AND
	d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3