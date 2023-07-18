
SELECT *
From PortfolioProject..CovidDeath 
Where continent is not null
order by 3,4

SELECT *
From PortfolioProject..CovidVaccinations
order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath 
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath 
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of popuation got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath 
Where location like '%states%'
order by 1,2

-- Looking at country with highest infection rate compared to poulation

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath 
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath 
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath 
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continent with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath 
--Where location like '%states%'
Where continent is null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath 
--Where location like '%states%'
Where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulatedVaccinated
Create Table #PercentPopulatedVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulatedVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulatedVaccinated


-- Creating a View to store data for later

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated