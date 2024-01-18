SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.deaths
order by 1,2



--looking at Total cases per total deaths ratio in different dates in the USA
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject.dbo.deaths
where location like '%state%' AND total_cases is not null and total_deaths is not null 
order by 1,2


--looking at maximum of total_cases per population across different locations and dates 
--what percantage of population have got covid and are diagnosed
Select location, population, MAX(total_cases) as Max_total_cases, (cast(MAX(total_cases) as float)/cast(population as float))*100 as InfectionRate
FROM PortfolioProject.dbo.deaths
where total_cases is not null
group by Location, population
order by InfectionRate desc


--showing highest death count 
Select location, MAX(cast(total_deaths as int)) as max_death
FROM PortfolioProject.dbo.deaths
where continent is not null
group by Location
order by max_death desc

--showing highest death count per population
Select location, population, MAX(cast(total_deaths as int)) as max_death, MAX(cast(total_deaths as float))/cast(population as float) as ratio
FROM PortfolioProject.dbo.deaths
where total_cases is not null and total_deaths is not null 
group by Location, population
order by ratio desc


--showing continents with the highest death count 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.deaths
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers 
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths--total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.deaths
where continent is not null


SELECT *
FROM PortfolioProject.dbo.CovidVaccinations

UPDATE PortfolioProject.dbo.CovidVaccinations SET new_vaccinations=0 WHERE new_vaccinations IS NULL



--looking at total population vs vaccination
with popvsvac (continent, Location, Date, population, New_vaccinations, rollingvaccination)as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccination
FROM PortfolioProject.dbo.CovidVaccinations vac
join PortfolioProject.dbo.deaths dea
on vac.date=dea.date
and vac.location=dea.location
where dea.continent is not null
--order by 1,2,3
)
SELECT *, (rollingvaccination/population)*100 as percent_vaccinated
FROM popvsvac


--creating temp table

create table #vac_vs_pop
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
rollingvaccination numeric
)
insert into #vac_vs_pop
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccination
FROM PortfolioProject.dbo.CovidVaccinations vac
join PortfolioProject.dbo.deaths dea
on vac.date=dea.date
and vac.location=dea.location
where dea.continent is not null
--order by 1,2,3

select *, (rollingvaccination/population)*100
from #vac_vs_pop
order by 1,2,3



-- CREATING VIEWS FOR LATER VISUALIZATION
USE PortfolioProject
GO
CREATE view percentage_of_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccination
FROM PortfolioProject.dbo.CovidVaccinations vac
join PortfolioProject.dbo.deaths dea
on vac.date=dea.date
and vac.location=dea.location
where dea.continent is not null


SELECT *
FROM percentage_of_population_vaccinated