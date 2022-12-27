--select * 
--from PortfolioProject..Covid_deaths
--where continent is not null
--order by 3,4;

--select * 
--from PortfolioProject..Covid_Vaccinations
--where continent is not null
--order by 3,4;


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_deaths
where continent is not null
order by 1,2;
--order by column 1 n 2 ie location n date


--Total Casee vs Total Deaths
--chances of dying from covid in uae
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "Death Percentage"
from PortfolioProject..Covid_deaths
where location like '%emirates%' and continent is not null
order by 1,2;


--Total Cases vs Population
--percentage of population that got covid
select location, date, population, total_cases, (total_cases/population)*100 as "Covid Percentage"
from PortfolioProject..Covid_deaths
where location like '%emirates%' and continent is not null
order by 1,2;


--Highest Infection Rate vs Population countries
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as "PercentPopulationInfected"
from PortfolioProject..Covid_deaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;


--Highest Death Count per Population continents
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;


--INTERNATIONAL COUNT
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as "Death Percentage"
from PortfolioProject..Covid_deaths
where continent is not null
group by date
order by 1,2;


--Total Population vs Total Vaccination
--Rolling count and CTE(common table expression) included
with populationVSvaccination (Continent,Location,Date,Population,New_vaccinationss,RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, population, v.new_vaccinations, 
	sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_deaths d join PortfolioProject..Covid_vaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated from populationVSvaccination;


--TEMPORARY TABLE
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(Continent nvarchar(255),Location nvarchar(255),Date datetime,Population numeric,New_vaccinations numeric,RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_deaths d join PortfolioProject..Covid_vaccinations v
on d.location=v.location and d.date=v.date

select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated from #PercentPopulationVaccinated;



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
drop view if exists PercentPopulationVaccinated;
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_deaths d join PortfolioProject..Covid_vaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null

select * from PercentPopulationVaccinated;