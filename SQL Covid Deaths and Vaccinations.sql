
--select the data to be used 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['Covid-19Deaths']
where continent is not null
order by 1,2


-- looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..['Covid-19Deaths']
where location = 'zimbabwe'
order by 1,2
-- as of 13-07-2022 Zimbabwe has 255981 recorded cases of Covid  with 5565 deaths and one has a 2% chance of dying from Covid in Zimbabwe 


-- looking at Total Cases vs Population
-- shows what percentage of the population was infected 

select location, date, population,total_cases,  (total_cases/population)*100 as Infected_Population_Percentage
from PortfolioProject..['Covid-19Deaths']
where location = 'zimbabwe'
order by 1,2
-- as of 13-07-2022 1% of Zimbabwe's population has Covid


-- looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as Highest_Infection_Count,  MAX((total_cases/population))*100 as Infected_Population_Percentage
from PortfolioProject..['Covid-19Deaths']
where continent is not null
group by location, population
order by Infected_Population_Percentage desc
-- the Faeroe Islands have the highest infection rate with 65% of the population having got infected


-- looking at countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..['Covid-19Deaths']
where continent is not null
group by location
order by Total_Death_Count desc
-- United States has the highest number of deaths with 1023619 deaths 


-- Breaking things down by continent
-- looking at continents with the highest death count

select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..['Covid-19Deaths']
where continent is not null
group by  continent
order by Total_Death_Count desc


-- Global Numbers

select SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..['Covid-19Deaths']
where continent is not null
order by 1,2
-- total cases = 558361094, total deaths = 6321115 and death percentage = 1.1%


-- looking at vacinations

select *
from PortfolioProject..['Covid-19Deaths'] dea
Join PortfolioProject..['Covid-19Vaccinations'] vacc
    on dea.location = vacc.location
	and dea.date = vacc.date


-- looking at total populations vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
from PortfolioProject..['Covid-19Deaths'] dea
Join PortfolioProject..['Covid-19Vaccinations'] vacc
    on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2, 3



select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['Covid-19Deaths'] dea
Join PortfolioProject..['Covid-19Vaccinations'] vacc
    on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2, 3



-- using CTE

with popvsvac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['Covid-19Deaths'] dea
Join PortfolioProject..['Covid-19Vaccinations'] vacc
    on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
)
select *, (Rolling_People_Vaccinated/population)*100
from popvsvac



-- Temp table

Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_People_Vaccinated numeric
)
Insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['Covid-19Deaths'] dea
Join PortfolioProject..['Covid-19Vaccinations'] vacc
    on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null

select *, (Rolling_People_Vaccinated/population)*100
from #Percent_Population_Vaccinated

-- creating view to store data for later visaulizations

create View #Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['Covid-19Deaths'] dea
Join PortfolioProject..['Covid-19Vaccinations'] vacc
    on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null