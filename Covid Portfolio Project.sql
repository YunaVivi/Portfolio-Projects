select *
from dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from dbo.CovidVaccinations
--order by 3,4

--select Data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location = 'China'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
select location,date,population,total_cases,(total_cases/population)*100 as InfectionRate
from dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
select location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population)*100) as InfectionRate
from dbo.CovidDeaths
where continent is not null
Group by location,population
order by InfectionRate desc

--Showing Countries with Highest Death Count per Population
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


--Showing Continent with Highest Death Count per Population
select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
select SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--Group by date
order by 1,2

select *
from dbo.CovidVaccinations

--Join two tables
--Looking at Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
	RollongPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac(continent,location,date,population,new_vaccinations,RollongPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
	RollongPeopleVaccinated
	--,(RollongPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollongPeopleVaccinated/population)*100
from PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollongPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
	RollongPeopleVaccinated
	--,(RollongPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollongPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
	RollongPeopleVaccinated
	--,(RollongPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
