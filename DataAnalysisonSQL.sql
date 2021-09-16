'''
CREATE TABLE mytable(
   iso_code                           VARCHAR(8) NOT NULL PRIMARY KEY
  ,continent                          VARCHAR(13)
  ,location                           VARCHAR(32) NOT NULL
  ,date                               DATE  NOT NULL
  ,population                         INTEGER 
  ,total_cases                        INTEGER 
  ,new_cases                          INTEGER 
  ,new_cases_smoothed                 NUMERIC(10,3)
  ,total_deaths                       INTEGER 
  ,new_deaths                         INTEGER 
  ,new_deaths_smoothed                NUMERIC(9,3)
  ,total_cases_per_million            NUMERIC(10,3)
  ,new_cases_per_million              NUMERIC(9,3)
  ,new_cases_smoothed_per_million     NUMERIC(8,3)
  ,total_deaths_per_million           NUMERIC(8,3)
  ,new_deaths_per_million             NUMERIC(7,3)
  ,new_deaths_smoothed_per_million    NUMERIC(7,3)
  ,reproduction_rate                  NUMERIC(5,2)
  ,icu_patients                       INTEGER 
  ,icu_patients_per_million           NUMERIC(7,3)
  ,hosp_patients                      INTEGER 
  ,hosp_patients_per_million          NUMERIC(8,3)
  ,weekly_icu_admissions              NUMERIC(8,3)
  ,weekly_icu_admissions_per_million  NUMERIC(7,3)
  ,weekly_hosp_admissions             NUMERIC(9,3)
  ,weekly_hosp_admissions_per_million NUMERIC(8,3)
);

COPY CovidDeaths from 'C:\Program Files\PostgreSQL\13\data\data1\Data\All files for Restoring Database\CSV files\CovidDeaths.csv'
CSV HEADER;

DROP TABLE CovidVaccinated;
CREATE TABLE CovidVaccinated(
   iso_code                              VARCHAR(8) NOT NULL 
  ,continent                             VARCHAR(13)
  ,location                              VARCHAR(32) NOT NULL
  ,date                                  DATE  NOT NULL
  ,new_tests                             INTEGER 
  ,total_tests                           INTEGER 
  ,total_tests_per_thousand              NUMERIC(9,3)
  ,new_tests_per_thousand                NUMERIC(7,3)
	,new_tests_smoothed 				INTEGER
	,new_tests_smoothed_per_thousand    NUMERIC
	,positive_rate 						NUMERIC
	,tests_per_case   					NUMERIC
	,tests_units 						VARCHAR(15)
	,total_vaccinations					BIGINT
	,people_vaccinated 					BIGINT
	,people_fully_vaccinated			BIGINT
	,total_boosters 					INTEGER
	,new_vaccinations					INTEGER
	,new_vaccinations_smoothed			INTEGER
	,total_vaccinations_per_hundred		NUMERIC
	,people_vaccinated_per_hundred		NUMERIC
	,people_fully_vaccinated_per_hundred	NUMERIC	
	,total_boosters_per_hundred			NUMERIC
	,new_vaccinations_smoothed_per_million	INTEGER	
	,stringency_index					NUMERIC
	,population_density					NUMERIC
	,median_age							NUMERIC
	,aged_65_older						NUMERIC
	,aged_70_older						NUMERIC
	,gdp_per_capita						NUMERIC
	,extreme_poverty					NUMERIC
	,cardiovasc_death_rate				NUMERIC
	,diabetes_prevalence				NUMERIC
	,female_smokers						NUMERIC
	,male_smokers						NUMERIC
	,handwashing_facilities				NUMERIC
	,hospital_beds_per_thousand			NUMERIC
	,life_expectancy					NUMERIC
	,human_development_index			NUMERIC
	,excess_mortality 					NUMERIC);

COPY CovidVaccinated from 'C:\Program Files\PostgreSQL\13\data\data1\Data\All files for Restoring Database\CSV files\CovidVaccinations.csv'
CSV HEADER;
	
SELECT * FROM CovidDeaths
ORDER BY 3,4;

SELECT * FROM CovidVaccinated
ORDER BY 3,4;
	
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date;

SELECT location, date, total_cases, total_deaths, (total_deaths::FLOAT/total_cases)*100 as DeathPercentage
FROM CovidDeaths
ORDER BY location, date; 

SELECT location, date, total_cases, total_deaths, (total_deaths::FLOAT/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location='India'
ORDER BY location, date; 

-- Total Caases vs Population
SELECT location, date, total_cases, population, (total_cases::FLOAT/population)*100 as PercentPopInfected
FROM CovidDeaths
WHERE location='India'
ORDER BY location, date; 

-- Country with Highest Infection Rate
SELECT location, MAX(total_cases) AS HighesCasesCount, population, 
		MAX((total_cases::FLOAT/population)*100) as HighestPercPopInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY HighestPercPopInfected DESC; 

-- India Highest Infection Rate

SELECT location, MAX(total_cases) AS HighesCasesCount, population, 
		MAX((total_cases::FLOAT/population)*100) as HighestPercPopInfected
FROM CovidDeaths
GROUP BY location, population
HAVING location ='India'
ORDER BY HighestPercPopInfected DESC; 


-- Countrywise Highest Death Count
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC; 

-- Continentwise Highest Death Count
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC; 


-- Global death and cases , datewise
SELECT date, SUM(total_cases),SUM(total_deaths), AVG((total_deaths::FLOAT/total_cases)*100) as AvgDeathPercentage
FROM CovidDeaths
WHERE location is not null
GROUP BY date
ORDER BY date;


-- Global death and cases , datewise
SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_Deaths, 
      (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathsPercentage 
FROM CovidDeaths
WHERE location is not null
GROUP BY date
ORDER BY date;


-- joining the tables
SELECT *
FROM CovidDeaths as cd
JOIN CovidVaccinated as cv
ON cd.location = cv.location AND cd.date = cv.date;

-- total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cv.new_vaccinations
FROM CovidDeaths as cd
JOIN CovidVaccinated as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cv.location is not null
ORDER BY 1,2,3;


-- USING CTE
WITH popvsvacc (Continent, Location, Date, Population, New_Vaccinations, CummilativePopVaccinated) as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummilativePopVaccinated
FROM CovidDeaths as cd
JOIN CovidVaccinated as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *,(CummilativePopVaccinated::FLOAT/Population)*100 as "Rate of Vaccination"
FROM popvsvacc


-- working with temp tables 
DROP TABLE if exists percentage_population_vaccinated;
CREATE TEMPORARY TABLE percentage_population_vaccinated(
   Continent varchar(15), Location varchar(32), Date date, Population integer,
	New_Vaccinations integer, CummilativePopVaccinated numeric
);
INSERT INTO percentage_population_vaccinated (Continent, Location, Date, Population, New_Vaccinations, CummilativePopVaccinated)
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummilativePopVaccinated
FROM CovidDeaths as cd
JOIN CovidVaccinated as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null


SELECT *,(CummilativePopVaccinated::FLOAT/Population)*100 as "Rate of Vaccination"
FROM percentage_population_vaccinated;


-- Creating views for visualization

CREATE VIEW PercentPopVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummilativePopVaccinated
FROM CovidDeaths as cd
JOIN CovidVaccinated as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null


select * from PercentPopVaccinated;


''' 


	
	
	
	
	
	
	
	
	
	
	
	
	
	

