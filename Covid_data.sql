Select *
From project..covid_deaths$
order by 3,4

Select *
From project..covid_vaccinations$
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths,population
From project..covid_deaths$
order by 1,2

--looking at total cases vs toal deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)
From project..covid_deaths$
Where location like '%states%'
order by 1,2

-- looking at the total cases vs population
--percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as casepercentage
From project..covid_deaths$
--Where location like '%india%'
order by 1,2

--looking countrys with highest infection rate compared to population

Select Location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentageofpopulation
From project..covid_deaths$
--Where location like '%india%'
Group by location,population
order by percentageofpopulation desc

--showing countries with the highest death count

Select Location, population, MAX(Cast(total_deaths as int)) as highestdeathcount
From project..covid_deaths$
--Where location like '%india%'
Where continent is not null
Group by location,population
order by highestdeathcount desc

--lets breakdown by continent

Select location, MAX(Cast(total_deaths as int)) as highestdeathcount
From project..covid_deaths$
--Where location like '%india%'
Where continent is null
Group by location
order by highestdeathcount desc

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From project..covid_deaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2
--looking at total population vs vaccination

Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated
From project..covid_deaths$ dea
Join project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--use cte

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..covid_deaths$ dea
Join project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--using temp table to do calculations on the table in previous query

Drop Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvacccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentpopulationvacccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..covid_deaths$ dea
Join project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percentpopulationvacccinated
--creating view to store data for later visualization

Create View RollingPeopleVaccinated as
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated
From project..covid_deaths$ dea
Join project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null




--these are the queries which will further used for visualisation purposes

--here we have taken sum of new cases and sum of new deaths then calculated the death percentage 

--1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project..covid_deaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--2

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From project..covid_deaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From project..covid_deaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From project..covid_deaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


--5

Select Location, date, population, total_cases, total_deaths
From project..covid_deaths$
--Where location like '%states%'
where continent is not null 
order by 1,2


--6

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From project..covid_deaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..covid_deaths$ dea
Join project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac