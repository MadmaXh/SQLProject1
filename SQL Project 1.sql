select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Look at Total cases vs Total deaths in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPresentage
from PortfolioProject..CovidDeaths
where location like '%lanka%'
order by 1,2


-- Look at Total cases vs Population

select location, date, total_cases,population, (total_cases/population)*100 As PatientPresentage
from PortfolioProject..CovidDeaths
where location like '%lanka%'
order by 1,2

--Looking at coutries with highest infection rates

select location, population, max(total_cases) AS InfectionCount, MAX((total_cases/population))*100 As PatientPresentage
from PortfolioProject..CovidDeaths
--where location like '%lanka%'
GROUP BY location, population
order by PatientPresentage DESC


--Countries with highest Deaths

select location, max(CAST (total_deaths AS int)) AS DeathCount, MAX((total_deaths/population))*100 As DeathPresentage
from PortfolioProject..CovidDeaths
--where location like '%lanka%'
where continent is not null
GROUP BY location
order by DeathCount DESC

--Break down by continents

select location, max(CAST (total_deaths AS int)) AS DeathCount, MAX((total_deaths/population))*100 As DeathPresentage
from PortfolioProject..CovidDeaths
--where location like '%lanka%'
where continent is null
GROUP BY location
order by DeathCount DESC


--Global Numbers date wise

select date, SUM(new_cases) as NewCases, SUM(CAST (new_deaths as int)) as NewDeaths, (SUM(CAST (new_deaths as int))/SUM(new_cases))*100 
as DeathPresentageperDay
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,2

--Lets join 2 Tables

Select *
From PortfolioProject..CovidDeaths dea -- renamed as dea
join PortfolioProject..CovidVaccinations vac
On dea.date = vac.date
and dea.location = vac.location

-- population vs vaccination

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea -- renamed as dea
join PortfolioProject..CovidVaccinations vac
On dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
Order by 2,3

 --Total vaccination count date wise for each country vs population

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccineCount
--,(VaccineCount/dea.population)*100 
--Cant use created column name for calculation need to useeither CTE or Temp table
From PortfolioProject..CovidDeaths dea -- renamed as dea
join PortfolioProject..CovidVaccinations vac
On dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
Order by 2,3

--Total population vs vaccination presentage country wise and date wise 
--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations,VaccineCount)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccineCount
From PortfolioProject..CovidDeaths dea -- renamed as dea
join PortfolioProject..CovidVaccinations vac
On dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
--Order by 2,3
)
Select *, (VaccineCount/Population)*100 as VaccinePresentage
From PopvsVac

--USE Temp Table
DROP table if exists #PopvsVac
Create Table #PopvsVac
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
VaccineCount numeric	
)

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccineCount
From PortfolioProject..CovidDeaths dea -- renamed as dea
join PortfolioProject..CovidVaccinations vac
On dea.date = vac.date
and dea.location = vac.location
--where dea.continent is not null
--Order by 2,3

Select * , (VaccineCount/Population)*100 as VaccinePresentage
From #PopvsVac


--Creating Views to store data for later visualizations



Create View PopvsVacView as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccineCount
From PortfolioProject..CovidDeaths dea -- renamed as dea
join PortfolioProject..CovidVaccinations vac
On dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null

Select * from PopvsVacView