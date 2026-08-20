use portfolioproject;
Select *
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 3,4;



-- Select Data that we are going to be starting with

Select Location, new_date, total_cases, new_cases, total_deaths, population
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, new_date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
--Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, max(cast(Total_deaths as signed )) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent,MAX(cast(Total_deaths as signed )) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

SELECT DISTINCT continent
FROM PortfolioProject.CovidDeaths;

--Global Numbers
Select new_date, sum(new_cases),sum(cast(new_deaths as signed))
,(sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by new_date
order by 1,2;


--Total Cases
Select sum(new_cases),sum(cast(new_deaths as signed))
,(sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
-- Group by new_date
order by 1,2;

--looking total population vs vaccinations (Joining the two tables together)
Select dea.continent, dea.location, dea.new_date,dea.population, vac.new_vaccinations
from portfolioproject.coviddeaths as dea
join portfolioproject.covidvaccinations vac
on dea.location = vac.location
and dea.new_date = vac.new_date
where dea.continent is not null
order by 2,3;


Select dea.continent, dea.location, dea.new_date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location,dea.new_date) as TotalVaccinations,
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
on dea.location = vac.location
and dea.new_date = vac.new_date
where dea.continent is not null
order by 2,3;

--Use CTE (Common Table Expression) to calculate the total vaccinations per country over time

with popvsvac (continent, location, new_date, population, new_vaccinations, TotalVaccinations) as 
(Select dea.continent, dea.location, dea.new_date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location,dea.new_date) as TotalVaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
on dea.location = vac.location
and dea.new_date = vac.new_date
where dea.continent is not null
-- order by 2,3
)
select *, (totalvaccinations/population)*100 as PercentPopulationVaccinated
from popvsvac


--- TEMP Tables
-- drop temporary table if exists percentagepopvaccinated;
Create temporary table percentagepopvaccinated
(
    continent nvarchar(250), 
    location varchar(100), 
    new_date date, 
    population int,
    new_vaccinations int, 
    TotalVaccinations int
);

insert into percentagepopvaccinated
(continent, location, new_date, population, new_vaccinations, TotalVaccinations)
Select 
    dea.continent, 
    dea.location, 
    dea.new_date,
    NULLIF(dea.population, '')                as population,
    NULLIF(vac.new_vaccinations, '')           as new_vaccinations,
    sum(cast(NULLIF(vac.new_vaccinations, '') as signed))
        over (partition by dea.location order by dea.location, dea.new_date) as TotalVaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac 
    on dea.location = vac.location
    and dea.new_date = vac.new_date;

select *, (totalvaccinations/population)*100 as percentpopulation_vaccinated
from percentagepopvaccinated;

-- creating view to store data for late data visualizations

create VIEW percentagepopvaccinatedview as
Select 
    dea.continent, 
    dea.location, 
    dea.new_date,
    NULLIF(dea.population, '')                as population,
    NULLIF(vac.new_vaccinations, '')           as new_vaccinations,
    sum(cast(NULLIF(vac.new_vaccinations, '') as signed))
        over (partition by dea.location order by dea.location, dea.new_date) as TotalVaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac 
    on dea.location = vac.location
    and dea.new_date = vac.new_date
where dea.continent is not null
-- order by 2,3;

SELECT * FROM portfolioproject.percentagepopvaccinatedview;