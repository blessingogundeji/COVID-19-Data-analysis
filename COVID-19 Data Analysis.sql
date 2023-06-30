
----ANALYSIS OF THE WORLD COVID19 DATA TO DRAW KEY INSIGHTS ON THE DATA
----Data Soure (Our World in Data)---

----The queries also captures some insights on the total cases vs Total deaths in Nigeria, total cases by population and 
----the Country In Africa with the Highest Infection Rates compared to population---


---Viewing the COVID-19 Death Table

SELECT *
FROM CovidDeaths
ORDER BY 3,4

---Viewing the COVID-19 Vaccinations Table

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

---Exploring the COVID-19 Death Table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

---Looking at total_cases Vs total_deaths---
---This query shows the likelihood of a patient dying if they contract COVID-19 in their Country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%'
ORDER BY 1,2

---Looking at the total cases VS the Population
-----This query shows the percentage of people that contracted and died from COVID19 in Nigeria

SELECT location, Population, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 AS infectionratebypopulation
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%'
ORDER BY 1,2

----Country with the Highest Infection Rates compared to population ---

SELECT location, Population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population))*100 AS infectionratebypopulation
FROM CovidDeaths
---WHERE Location LIKE '%STATES%'
GROUP BY location, Population
ORDER BY Highestinfectioncount DESC

----Country In Africa with the Highest Infection Rates compared to population ---

SELECT location, Population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population))*100 AS infectionratebypopulation
FROM CovidDeaths
WHERE Location LIKE '%Africa%'
GROUP BY location, Population
ORDER BY infectionratebypopulation DESC

---Showing Countries with the Highest Death Counts---

SELECT location, Population, MAX(CAST(total_deaths AS INT)) AS Totaldeaths
FROM CovidDeaths
GROUP BY location, Population
ORDER BY Totaldeaths DESC

---Exploring death rate data by continents---

SELECT continent, SUM(Population) AS Population, MAX(CAST(total_deaths AS INT)) AS Totaldeaths
FROM CovidDeaths
GROUP BY Continent
HAVING Continent is not NULL
ORDER BY Totaldeaths DESC

---Total COVID-19 cases 

SELECT SUM(new_cases)AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_deaths, SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
---WHERE Location LIKE '%Nigeria%'
WHERE Continent IS NOT NULL
---GROUP BY date
ORDER BY 1,2

---EXPLORING THE VACCINATIONS AND DEATH TABLES

SELECT *
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date

---Exploring Total population Vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3

---Exploring further

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM( CAST (v.new_vaccinations AS INT)) OVER ( PARTITION BY d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3


---USING Common Table Expressions (CTE)

WITH PopVsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM( CAST (v.new_vaccinations AS INT)) OVER ( PARTITION BY d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date
WHERE d.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population) * 100 AS percentagevaccinated
FROM PopVsVac

---Creating a Temporary Table of %Population Vaccinated

CREATE Table #percentPopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)
INSERT INTO #percentPopulationvaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM( CAST (v.new_vaccinations AS INT)) OVER ( PARTITION BY d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date
WHERE d.continent IS NOT NULL

SELECT *, (rollingpeoplevaccinated/population) * 100 AS percentagevaccinated
FROM #percentPopulationvaccinated

---CREATING VIEW QUERIES FOR VISUALISATION
---1.
CREATE VIEW Deaths AS
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths

---2
CREATE VIEW Death_Percentage AS
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%'

---3
CREATE VIEW infection_rate AS
SELECT location, Population, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 AS infectionratebypopulation
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%'

---4
CREATE VIEW Total_infection_count AS
SELECT location, Population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population))*100 AS infectionratebypopulation
FROM CovidDeaths
GROUP BY location, Population

---5
CREATE VIEW infection_count_Africa AS
SELECT location, Population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population))*100 AS infectionratebypopulation
FROM CovidDeaths
WHERE Location LIKE '%Africa%'
GROUP BY location, Population

---6
CREATE VIEW Total_deaths AS
SELECT location, Population, MAX(CAST(total_deaths AS INT)) AS Totaldeaths
FROM CovidDeaths
GROUP BY location, Population

---7
CREATE VIEW Total_deaths_byContinent as
SELECT continent, SUM(Population) AS Population, MAX(CAST(total_deaths AS INT)) AS Totaldeaths
FROM CovidDeaths
GROUP BY Continent
HAVING Continent is not NULL

---8
CREATE VIEW NewdeathsVsNewcases as
SELECT SUM(new_cases)AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_deaths, SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Continent IS NOT NULL

---9
CREATE VIEW Newvaccinations as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3

---10
CREATE VIEW Newvaccinations as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM( CAST (v.new_vaccinations AS INT)) OVER ( PARTITION BY d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
ON V.location = D.location
AND V.date = D.date
WHERE d.continent IS NOT NULL











