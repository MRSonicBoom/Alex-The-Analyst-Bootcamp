SELECT *
FROM coviddeaths
ORDER BY 3,4;

# Select the data we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

# Looking at total cases vs  total deaths
# Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%states%'
ORDER BY 1,2;

# Looking at total cases versus the population
# Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%states%'
ORDER BY 1,2;

# Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc;

# Showing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as signed)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;

# Lets break things down by continent

SELECT location, MAX(cast(total_deaths as signed)) as TotalDeathCount
FROM coviddeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;

# Showing continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as signed)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

# Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location
    AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

# USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location
    AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopvsVac;

# TEMP TABLE

CREATE TEMPORARY TABLE PercentPopulationVaccination
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO PercentPopulationVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location
    AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PercentPopulationVaccination;

# Create View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location
    AND  dea.date = vac.date
WHERE dea.continent is not null
#ORDER BY 2,3;
