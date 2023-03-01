create schema portfolio_projects;
use portfolio_projects;
select * from coviddeaths;
select * from covid_vacc;
UPDATE `coviddeaths` SET `date` = str_to_date( `date`, '%d-%m-%Y' ); #changed the data type to date format of coviddeaths table
Update covid_vacc set date=str_to_date(date,"%d-%m-%Y"); #changed the data type to date format of covid vaccination table
alter table covid_vacc rename column date to date1;


-- Looking at Total cases vs Total deaths
select location, date1, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage from coviddeaths
where location like "%India%"; -- shows the liklihood of dying if you track covid in your country

-- Total cases vs Population
select location, date1, total_cases,population, total_deaths, 
(total_cases/population)*100 AS PositivePercentage from coviddeaths where location like "%states%"; -- What % of people got covid

-- Looking at country with highest infection rate
select location, date1, max(total_cases) as Highest_infection_count,max((total_cases/population))*100 as Highest_Percentage_covid_cases,
(total_cases/population)*100 AS PositivePercentage from coviddeaths
group by population, location
order by PositivePercentage desc ;

-- Showing the countries with the highest death count per population
select location, max(cast(total_deaths as unsigned)) as Total_Death_count from coviddeaths
where continent is not null
group by continent
order by Total_Death_count desc;

-- Lets break things down by continent
-- Showing the continents with highest death count per population
select continent, max(cast(total_deaths as unsigned)) as Total_Death_count from coviddeaths
where continent is not null
group by continent
order by Total_Death_count desc;

-- Global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths )/sum(new_cases)*100 as DeathPercentage from coviddeaths
where continent is not null;
select sum(new_deaths) from coviddeaths;

-- Looking at total population vs vaccination
select cd.continent, cd.location, cd.date1, cd.population, vc.new_vaccinations from coviddeaths cd inner join covid_vacc vc
on cd.date1=vc.date1 and vc.location=cd.location
where cd.continent is not null
order by 2,3;

-- 
select cd.continent, cd.location, cd.date1, cd.population, vc.new_vaccinations, sum(convert(vc.new_vaccinations, unsigned)) 
 OVER (partition by cd.location order by cd.location, cd.date1) as RollingPeopleVaccinated
from coviddeaths cd inner join covid_vacc vc
on cd.date1=vc.date1 and vc.location=cd.location
where cd.continent is not null
order by 2,3;

-- CTE
with PopvsVac (Continent, location ,date1, population, new_vaccinations, RollingPeopleVaccinated) as 
(select cd.continent, cd.location, cd.date1, cd.population, vc.new_vaccinations, sum(convert(vc.new_vaccinations, unsigned)) 
 OVER (partition by cd.location order by cd.location, cd.date1) as RollingPeopleVaccinated
from coviddeaths cd inner join covid_vacc vc
on cd.date1=vc.date1 and vc.location=cd.location
where cd.continent is not null)
-- order by 2,3)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac;

-- Temp Table
Drop table if exists PercentPopulationVaccinated;
Create temporary table PercentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date1 datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
insert into PercentPopulationVaccinated
select cd.continent, cd.location, cd.date1, cd.population, vc.new_vaccinations, sum(convert(vc.new_vaccinations, signed integer)) 
 OVER (partition by cd.location order by cd.location, cd.date1) as RollingPeopleVaccinated
from coviddeaths cd inner join covid_vacc vc
on cd.date1=vc.date1 and vc.location=cd.location;
-- where cd.continent is not null)
-- order by 2,3)

-- Creating viwe to store data for later
create view PercentagePopulationVaccinated as
select cd.continent, cd.location, cd.date1, cd.population, vc.new_vaccinations, sum(convert(vc.new_vaccinations, signed integer)) 
 OVER (partition by cd.location order by cd.location, cd.date1) as RollingPeopleVaccinated
from coviddeaths cd inner join covid_vacc vc
on cd.date1=vc.date1 and vc.location=cd.location
where cd.continent is not null;
select * from PercentagePopulationVaccinated;







