select *
from dbo.CovidDeaths$
where continent is NOT NULL
order by 3,4

--select *
--from dbo.CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from dbo.CovidDeaths$
order by 1,2

--Total cases vs total deaths percentage of people that died that had covid

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS 'DeathPercentage'
from dbo.CovidDeaths$
where location like '%nigeria%'
order by 1,2
-- shows likelihood of dying if you contract covid

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS 'DeathPercentage'
from dbo.CovidDeaths$
where location like '%nigeria%'
order by 1,2

-- covid cases vs population
--shows what percentage of population has covid

select location, date, total_cases, population,(total_cases/population)*100 AS 'CovidpopulationPercentage'
from dbo.CovidDeaths$
where location like '%nigeria%'
order by 1,2

--What country has highest covid rate compared to population

select location,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM dbo.CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--countries with highest death count per population

select location,MAX(cast(total_deaths as int)) AS TotalDeathCounts 
FROM dbo.CovidDeaths$
WHERE continent is not null
group by location
order by TotalDeathCounts desc

--Break it down by continent

select location, MAX(cast(total_deaths as int)) AS TotalDeathCounts 
FROM dbo.CovidDeaths$
WHERE continent is null
group by location
order by TotalDeathCounts asc


-- showing the continent with the highest death count

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCounts 
FROM dbo.CovidDeaths$
WHERE continent is not null
group by continent
order by TotalDeathCounts desc

-- breaking it to global numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--Total cases and deaths percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2

-- looking covid deaths vs covid vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
order by 1,2

--Break it down by continent

select location, MAX(cast(total_deaths as int)) AS TotalDeathCounts 
FROM dbo.CovidDeaths$
WHERE continent is null
group by location
order by TotalDeathCounts asc


-- showing the continent with the highest death count

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCounts 
FROM dbo.CovidDeaths$
WHERE continent is not null
group by continent
order by TotalDeathCounts desc

-- breaking it to global numbers



select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--Total cases and deaths percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2

-- looking covid deaths vs covid vaccination

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

         

