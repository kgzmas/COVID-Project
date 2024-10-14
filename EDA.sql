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
