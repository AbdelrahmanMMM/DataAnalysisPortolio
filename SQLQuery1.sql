--selecting all  the data in the CovidDeaths
select * 
from PortfolioProject..CovidDeaths
order by Location, date

--selecting the data that we will be going to start with
select continent, location,  population, date, new_cases,total_cases ,total_deaths 
from PortfolioProject..CovidDeaths

--Showing the likelihood of dying of you contract Covid in you country in each day
select location, date, total_deaths, Total_cases, (total_deaths/total_cases)*100 as DeathPercentageOfPatients from PortfolioProject..CovidDeaths
where location like 'Egypt'
order by date

--Showing what Percentage of population infected with covid
select location, date, total_cases, Population, (total_cases/population)*100 as infectionPercentageOfPopulation
from PortfolioProject..CovidDeaths
order by 1,2

--Showing countries with the hightest infection number compared to Population
select location, sum(new_cases) as total_cases
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_cases desc

--Countries with highest death number
select location, sum(convert(int,total_deaths)) as total_deaths_in_the_country
from PortfolioProject..CovidDeaths 
where continent is not null
group by location 
order  by total_deaths_in_the_country desc

--Showing Continents with highest death count 
select location, sum(convert(int,total_deaths)) as total_deaths_in_the_country
from PortfolioProject..CovidDeaths 
where continent is null
group by location 
order  by total_deaths_in_the_country desc

--OR

select continent, sum(convert(int, total_deaths)) as total_deaths_in_the_continent
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_deaths_in_the_continent desc

--Showing the death count in the world
select 'World' as continent, sum(convert(int, total_deaths)) as total_deaths_in_the_continent
from PortfolioProject..CovidDeaths

--Global numbers( Worldwide)
select 'WorldWide' as location, sum(new_cases) as total_cases, sum(convert(int,new_deaths)) as total_deaths, sum(convert(int, new_deaths))/sum(new_cases)*100 as DeathPercentageOfPatients 
from PortfolioProject..CovidDeaths
where continent is not null

--Shows Percentage of Population that at least recieved one Vaccine
select location, population, total_vaccinations, (total_vaccinations/population)*100 as VaccinedPeoplePercentage
from PortfolioProject..CovidVaccinations

--Calculating cumulative column of the people vaccined in each country with showing total_deaths
select dea.continent, dea.location, dea.population, dea.total_deaths, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as cumulativePeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.location=dea.location and vac.date=dea.date
where dea.continent is not null
order by dea.location, dea.date

--Calculating cumulative column of the percentage of people vaccined in each country relative to population of the country with showing total_deaths
--Using CTE
with tempTable(continent, location, population, new_vaccinations, total_deaths, cumulativePeopleVaccinated) as(
select dea.continent, dea.location, dea.population, vac.new_vaccinations, dea.total_deaths,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as cumulativePeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.location=dea.location and vac.date=dea.date
where dea.continent is not null

)
select continent, location, population, total_deaths, new_vaccinations, cumulativePeopleVaccinated, (cumulativePeopleVaccinated/population)*100 as cumulativePercentageOfPeopleVaccinated
from tempTable

--Calculating cumulative column of the percentage of people vaccined in each country relative to population of the country with showing total_deaths
--Using temp Table

Drop table if exists #cumulativePercentageOfPeopleVaccinated
create table #cumulativePercentageOfPeopleVaccinated(
continent nvarchar(255),
location nvarchar(255),
population numeric,
total_deaths numeric,
new_vaccincations numeric,
cumulativePeopleVaccinated numeric
)

insert into #cumulativePercentageOfPeopleVaccinated
select dea.continent, dea.location, dea.population, dea.total_deaths, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as cumulativePeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.location=dea.location and vac.date=dea.date
where dea.continent is not null
order by dea.location, dea.date

select (cumulativePeopleVaccinated/population)*100 as cumulativePercentageOfPeopleVaccinated
from #cumulativePercentageOfPeopleVaccinated

--Creating view to store data for later visualization
create view cumulativePercentageOfPeopleVaccinated as 
select dea.continent, dea.location, dea.population, dea.total_deaths, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as cumulativePeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.location=dea.location and vac.date=dea.date
where dea.continent is not null
--order by dea.location, dea.date

select (cumulativePeopleVaccinated/population)*100 as cumulativePercentageOfPeopleVaccinatedValue
from cumulativePercentageOfPeopleVaccinated