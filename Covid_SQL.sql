-- select location,date,total_cases,new_cases,total_deaths,population from covid
-- order by 1,2 ; 


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract with covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid 
where location like "%states%" and total_deaths!=0
order by 1,2  ; 

-- Looking at Total Cases vs Populations

select location,date,total_cases,population, (total_cases/population)*100 as PercentagePopulation
from covid 
where location like "%states%" and total_deaths!=0
order by 1,2  ; 

-- Looking at countries with Highest Infection Rate compared with Population

select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from covid 
-- where location like "%states%" and total_deaths!=0 
GROUP BY location,population
order by PercentagePopulationInfected desc ; 

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid
-- where location like "%states%" and total_deaths!=0 
where continent is not null 
GROUP BY location
order by TotalDeathCount desc ; 


-- Let's break things down by continent



SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid
-- where location like "%states%" and total_deaths!=0 
where continent is not null 
GROUP BY continent
order by TotalDeathCount desc ; 

-- Globals numbers

select sum(new_cases) as Total_cases, sum(cast(new_deaths AS UNSIGNED)) as total_deaths, sum(cast(new_deaths AS UNSIGNED))/
sum(new_cases)*100 as DeathPercentage
from covid 
-- where location like "%states%" and total_deaths!=0
where continent is not null and new_cases!=0
-- group by date 
order by 1,2  ; 

-- Looking at Total Population vs Vaccinations
 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as UNSIGNED)) over (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covid dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null and dea.location like "can%"
order by 2,3;


-- Use CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as UNSIGNED)) over (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covid dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null and dea.location like "can%"
-- order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
from PopvsVac;

-- Temp table 

DROP TABLE IF EXISTS
PrecentPopulationVaccinated;

Create TEMPORARY table PrecentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccination DECIMAL (18,2),
RollingPeopleVaccinated numeric );

insert into PrecentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS DECIMAL(18, 2))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
from covid dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null and dea.location like "can%"
-- order by 2,3
;

SELECT *, (RollingPeopleVaccinated/Population)*100
from PrecentPopulationVaccinated;

-- create view to store date for late visualizations 


CREATE VIEW PrecentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as UNSIGNED)) over (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covid dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null 
order by 2,3;

SELECT * FROM PrecentPopulationVaccinated;
DROP VIEW PrecentPopulationVaccinated;
