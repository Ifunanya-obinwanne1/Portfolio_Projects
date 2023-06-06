/* COVID19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From [Data Exploration with SQL]..CovidDeaths
Where continent is not null
order by 3,4

--Select data to work with from CovidDeath Table

Select Location, date, total_cases, new_cases, total_deaths, population
From [Data Exploration with SQL]..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths for USA

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Data Exploration with SQL]..CovidDeaths
Where location like '%States%'
and continent is not null
Order by 1,2

--Likelihood of dying if you contract covid in USA.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Data Exploration with SQL]..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Total Cases vs Population
-- What percentage of population got covid

Select Location, date, Population, total_cases,(total_cases/population)*100 as InfectedPopulationPercent
From [Data Exploration with SQL]..CovidDeaths
--Where location like '%Nigeria%'
Order by 1,2


-- Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectedCount, MAX(total_cases/population)*100 as InfectedPopulationPercent
From [Data Exploration with SQL]..CovidDeaths
--Where location like '%Nigeria%'
Group by Location, population
Order by InfectedPopulationPercent desc


--Countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Data Exploration with SQL]..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--BREAK-DOWN BY Continent

--( more accurate with grouping with location)

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Data Exploration with SQL]..CovidDeaths
Where continent is null
Group by Location
Order by TotalDeathCount desc



--Continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Data Exploration with SQL]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Data Exploration with SQL]..CovidDeaths
where continent is not null 
Order by 1,2


-- Covid Vaccination Exploration

Select *
From [Data Exploration with SQL]..CovidVaccinations
order by 3,4



Select * 
From [Data Exploration with SQL]..CovidDeaths dea
Join [Data Exploration with SQL]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Total Population vs Vaccinations
--Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Exploration with SQL]..CovidDeaths dea
Join [Data Exploration with SQL]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE(Common_Table_Expression) to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Exploration with SQL]..CovidDeaths dea
Join [Data Exploration with SQL]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMPORARY TABLE
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
From [Data Exploration with SQL]..CovidDeaths dea
Join [Data Exploration with SQL]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create View to store data for visualizations
DROP View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Data Exploration with SQL]..CovidDeaths dea
Join [Data Exploration with SQL]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
