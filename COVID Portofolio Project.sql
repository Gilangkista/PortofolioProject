select * 
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortofolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1, 2


-- looking at Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- looking at indonesia DeathPercentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location like '%indonesia%' and continent is not null
order by 1, 2


-- looking at Total Cases vs Population
select location, date, population, total_cases, (total_cases/population) * 100 as CasesPercentage
from PortofolioProject..CovidDeaths
where location like '%indonesia%' and continent is not null
order by 1, 2

-- Looking at country with highest infection rate compared to popuation
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPupulationInfected
from PortofolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPupulationInfected desc

-- Showing Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

-- Global numbers total cases, deaths, deathpercentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2


--JOIN 2 TABLES
select *
from PortofolioProject..CovidDeaths as dea
join PortofolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.date, vac.new_vaccinations
from PortofolioProject..CovidDeaths as dea
join PortofolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths as dea
join PortofolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths as dea
join PortofolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinated
from PopvsVac

--USE TEMP TABLE
drop table if exists PercentagePopulationVaccinated
create table PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths as dea
join PortofolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PopulationVaccinatedPercentage
from PercentagePopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths as dea
join PortofolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated