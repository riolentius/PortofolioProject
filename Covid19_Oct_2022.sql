--select * from Portofolio.dbo.CovidDeaths
--where continent is not null
--order by 3,4

--select * from Portofolio.dbo.CovidVaccination
--order by 3,4

-- select the data that we want to use
select location,date,total_cases,new_cases,total_deaths,population
from Portofolio.dbo.CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- Show the percentage of likelihood of dying if you get a Covid
select location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Portofolio.dbo.CovidDeaths
where location = 'Indonesia' and continent is not null
order by 1,2

-- looking at the total cases vs the population
-- Show the percentage of population got Covid
select location,date,total_cases,new_cases,population, (total_cases/population) * 100 as TotalCase
from Portofolio.dbo.CovidDeaths
where location = 'Indonesia' and continent is not null
order by 1,2

-- looking the country with the highest infection rate compared to population
select location,population,max(total_cases) as HighestInfection, max((total_cases/population) * 100)
as PercentagePopulationInfection
from Portofolio.dbo.CovidDeaths
where continent is not null
Group By location,population
order by PercentagePopulationInfection desc

-- Showing the country with the highest death count per population
select location,max(cast(total_deaths as int)) as total_death_count
from Portofolio.dbo.CovidDeaths
where continent is not null
Group By location,population
order by total_death_count desc

-- Check the data by look at continent with the highest death count per population
select continent,max(cast(total_deaths as int)) as total_death_count
from Portofolio.dbo.CovidDeaths
where continent is not null
Group By continent
order by total_death_count desc

-- global number
select date, sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as new_deaths,
sum(cast(new_deaths as int))/nullif(sum(new_cases),0) * 100 as percentage_new_death
from Portofolio.dbo.CovidDeaths
group by date
order by 1,2
-- adding nullif for avoid divided by zero error

-- looking for a total population vs vaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio.dbo.CovidDeaths dea
join Portofolio.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
-- adding bigint to avoid arithmatic error, because it exceed the max value

-- using cte to calculate the percentage of the rollingpeoplevaccinated per population
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio.dbo.CovidDeaths dea
join Portofolio.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac

-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio.dbo.CovidDeaths dea
join Portofolio.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated



-- creating view to store data later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio.dbo.CovidDeaths dea
join Portofolio.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * from 
PercentPopulationVaccinated