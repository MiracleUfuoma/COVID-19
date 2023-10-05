select * from ['covid death ']
where continent is not null
order by 3,4
select * from ['covid vaccine ']
order by 3,4

--shows the total number of covid cases in each country
select location,date,population,new_cases,new_deaths,total_deaths,(new_cases + total_deaths) as total_cases
from ['covid death ']
where continent is not null
order by 1,2

--looking at total deaths vs the population
--shows percentage of people that died from covid
select location , date , population , total_deaths ,(total_deaths/population) * 100 deathrate 
from ['covid death ']
where continent is not null
order by 1,2

--looking at countries with highest deaths compared to population
select location ,  population , max(cast(total_deaths as int)) as totaldeathcount
from ['covid death ']
where continent is not null
group by location,population
order by totaldeathcount  desc

--BREAKING THINGS DOWN BY CONTINENT
--showing continents with highest death count per population
select continent , max(cast(total_deaths as int)) as totaldeathcount
from ['covid death ']
where continent is not null
group by continent 
order by totaldeathcount  desc

--global counts
select date , sum(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths
from ['covid death ']
where continent is not null
group by date 
order by 1,2

select continent,SUM(new_deaths)as totaldeaths,SUM(new_cases) as totalcases,SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage
from ['covid death ']
where continent is not null
group by continent
order by 1,2

--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.people_vaccinated AS bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from ['covid death '] dea
join ['covid vaccine '] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--using CTE
with popvsvac(continent, location, date, population, new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.people_vaccinated AS bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from ['covid death '] dea
join ['covid vaccine '] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from popvsvac


--temp table

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.people_vaccinated AS bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from ['covid death '] dea
join ['covid vaccine '] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population) *100
from #percentagepopulationvaccinated



--creating view for later visualization
create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.people_vaccinated AS bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from ['covid death '] dea
join ['covid vaccine '] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentagepopulationvaccinated
