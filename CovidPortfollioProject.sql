SELECT *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

-- Looking at Total Cases vs Total Deaths --
-- Shows likelihood of dying if you contract covid in your country--
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population --
-- Shows what percentage of population got Covid --
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PrecentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2



-- Looking at countries with highest infection rate compared to Population --
SELECT Location, population, Max(total_cases) as HightstInfectionCount, MAX((total_cases/population))*100 as PrecentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
--Where location like '%states%'
order by PrecentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population --
SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
--Where location like '%states%'
order by TotalDeathCount desc



--Breaking down by Continents with highest death count --
SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
--Where location like '%states%'
order by TotalDeathCount desc


--Global Numbers --

SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPrecentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPrecentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations --
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Use of CTE --
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as TotalPrecentVaccinated
From PopvsVac


-- Use of Temp Tables --

Drop table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PrecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as TotalPrecentVaccinated
From #PrecentPopulationVaccinated


--Creating View to store data for visualizations --


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



