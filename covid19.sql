SELECT * 
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--SELECT * 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data

Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

--Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--order by 1,2

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--and continent is not null 
--order by 1,2
--Had a problem with nvarchar/
 
 --Shows the likelihood of dying if you get covid in your country.

Select Location, date, total_cases,total_deaths,(CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)*100) as [DeathsOverTotal]
from PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2

-- Total Cases vs Population
--percentage of population got covid

Select Location, date, total_cases,population,(CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population)*100) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2


-- countries with highest infection rate
Select Location,population, MAX(total_cases)as HighestInfectionCount,MAX((CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population))*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%India%'
group by location, population
order by PercentPopulationInfected desc


--death count

Select Location, MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%India%'
group by location
order by TotalDeathCount desc


--- by continent
--highest death count continet
Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%India%'
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select date ,sum(new_cases), sum(cast(new_deaths as int)) , sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
group by date
order by 1,2



Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

----------------------
--Joins
--Total Population vs Vaccinations

-----------
Select dea.continent ,dea.location , dea.date ,dea.population , vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100- this cant be used here we need to create a new temp table- create CTE
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


---- temp table
--Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data

Create view 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
from PercentPopulationVaccinated