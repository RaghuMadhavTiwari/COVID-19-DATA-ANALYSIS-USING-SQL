-- 1. Total Cases vs Population

SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (SUM(new_deaths::FLOAT)/SUM(new_cases))*100 as DeathRate
FROM CovidDeaths
where continent is not null 
ORDER BY 1,2; 


-- 2. Continentwise Total Death Count

Select location, SUM(new_deaths::INT) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 3. Country with Highest Infection Rate

SELECT location, population, MAX(total_cases) AS HighesCasesCount, 
		MAX((total_cases::FLOAT/population)*100) as HighestPercPopInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY HighestPercPopInfected DESC; 

-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases::FLOAT/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected asc;

-- 5. Total population vs vaccinations

SELECT cd.continent, cd.location, cd.date, cv.new_vaccinations
FROM CovidDeaths as cd
JOIN CovidVaccinated as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cv.location is not null
ORDER BY 1,2,3;



