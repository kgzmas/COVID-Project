-- Select the data that we are going to use for analysis
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.coviddeaths
order by 1, 2


-- Check data types and alter data types
alter table PortfolioProject.dbo.coviddeaths
alter column total_deaths int;

-- Total cases vs. Total deaths -> death rate
select location, date, total_cases, total_deaths, (cast(total_deaths as float) / nullif(cast(total_cases as float), 0))*100 as death_rate 
from PortfolioProject.dbo.coviddeaths
where location like '%states%'
order by 1, 2

-- Total cases vs. Population in the united states
select location, date, total_cases, total_deaths, population, (cast(total_cases as float) / cast(population as float))*100 as infection_rate,
(cast(total_deaths as float) / nullif(cast(total_cases as float), 0))*100 as death_rate 
from PortfolioProject.dbo.coviddeaths
where location like 'United States'
order by 1, 2


-- Highest infection rate
select location, max(total_cases) as highestcase, population, max((cast(total_cases as float)) / cast(population as float))*100 as infection_rate
from PortfolioProject.dbo.coviddeaths
group by location, population
order by infection_rate desc

-- Highest death count, death rate
select location, max(total_deaths) as highestdeaths, population, max((cast(total_deaths as float)) / cast(population as float))*100 as percentageofdeath 
from PortfolioProject.dbo.coviddeaths
where continent <> '' --This is super important as I just found out the dataset has rows with Continent or even World data.
group by location, population
order by highestdeaths desc

-- Showing continent with the highest death count per population
select continent, max(total_deaths) as totaldeath
from PortfolioProject.dbo.coviddeaths
where continent <> '' 
group by continent
order by totaldeath desc


-- Global numbers
select date, sum(cast(new_cases as float)) as TotalCase, sum(cast(new_deaths as float)) as TotalDeath, sum(cast(new_deaths as float)) / nullif(sum(cast(new_cases as float)),0)*100 as DeathPercentage
from PortfolioProject.dbo.coviddeaths
where continent <> ''
group by date
order by 1,2


-- Total population vs. vaccinations

-- Using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as  
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccine vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''
)
select *, (RollingVaccinationCount/Population)*100
from PopvsVac


-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population float, New_Vaccinations float, RollingVaccinationCount float)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccine vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''


-- Views for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccine vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''

create view DeathByContinent as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent <> ''
Group by continent

