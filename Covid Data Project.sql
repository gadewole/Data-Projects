
Select *
From [Portfolio project]..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From [Portfolio project]..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project]..CovidDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows the Likelihood of dying if you get covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at the total Cases Vs Population 
--Show the percentag eof the population that got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at countries with high infection rates compared to population 

Select location,population,	Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
From [Portfolio project]..CovidDeaths$
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Looking at deaths by continent

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continent with the highest death counts per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global data

Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int)) 
/Sum(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int)) 
/Sum(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--From [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table


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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated





--Creating view to store data for later visualizations
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated