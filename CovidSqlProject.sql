select *
from sql_project.coviddata_deaths

Select location, date , cast(people_vaccinated as UNSIGNED ), total_vaccinations
from sql_project.coviddata_vaccine
order by 1, month(date)

select location, date, population, total_cases, new_cases, total_deaths
from sql_project.coviddata_deaths
order by 1, month(date)

-- looking at total case vs total death as DeathsPercentage Based on Cases

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from sql_project.coviddata_deaths
order by 1, month(date)

-- looking at total case vs total death as DeathsPercentage in INDIA
select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from sql_project.coviddata_deaths
where location = "India"
order by 1, month(date)

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in INDIA

select location, date, population, total_cases, total_deaths, (total_cases/ population)*100 as PercentageGotCovid
from sql_project.coviddata_deaths
where location = "India"
order by 1, month(date)

-- Countries with Highest Infection Rate compared to Population around the world

select location, population, MAX(total_cases) as HighestInfectionCount , Max((total_cases/ population))*100 as PercentageGotCovid 
from sql_project.coviddata_deaths
Group by Location, Population
order by PercentageGotCovid desc

-- Showing Countries with Highiest Death count per population 

select location, MAX(cast(total_deaths as UNSIGNED)) as Deathcount
from sql_project.coviddata_deaths
Group by location
order by  Deathcount desc

-- Showing Continent with Highiest Death count per population

select continent, MAX(cast(total_deaths as UNSIGNED)) as Deathcount
from sql_project.coviddata_deaths
Group by continent
order by  Deathcount desc

-- Showing Global Death percentage

select SUM(total_cases) as tota_newCases, SUM(cast(total_deaths as UNSIGNED)) as total_newDeaths, (SUM(cast(total_deaths as UNSIGNED))/SUM(total_cases))*100 as DeathsPercentage
from sql_project.coviddata_deaths
order by 1,2

-- Looking at Both Table using JOIN 

Select * 
from sql_project.coviddata_deaths as Dea
JOIN sql_project.coviddata_vaccine as Vac

-- Looking at Population vs vaccine using JOIN
Select Dea.Location, Dea.date as Date, Dea.population, cast(Vac.new_vaccinations as UNSIGNED), cast(Vac.total_vaccinations as UNSIGNED)
from sql_project.coviddata_deaths as Dea
JOIN sql_project.coviddata_vaccine as Vac
on Dea.Location = Vac.Location
and Dea.date = Vac.date
where Dea.continent is not null
order by 1 , year(Dea.date), 3

-- looking at SUM of people vaccinated according to there country using JOIN and Over 

Select cast(Dea.continent as CHAR), Dea.Location, Dea.date , Dea.population, cast(Vac.new_vaccinations as UNSIGNED) as NewVaccination,
SUM(cast(Vac.new_vaccinations as UNSIGNED )) over (partition by Dea.location order by Dea.location, Dea.date) as TotalVaccinated
from sql_project.coviddata_deaths as Dea
JOIN sql_project.coviddata_vaccine as Vac
on Dea.Location = Vac.Location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

-- Adding Vaccination per population using above query

Select cast(Dea.continent as CHAR), Dea.Location, Dea.date, Dea.population, cast(Vac.new_vaccinations as UNSIGNED) as NewVaccination,
SUM(cast(Vac.new_vaccinations as UNSIGNED )) over (partition by Dea.location order by Dea.location, Dea.date) as TotalVaccinated,
(TotalVaccinated/Dea.population)*100 as VaccinatedperPopulation # here we cannot use a temp coloum it give us Error
from sql_project.coviddata_deaths as Dea
JOIN sql_project.coviddata_vaccine as Vac
on Dea.Location = Vac.Location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

-- Adding Vaccination per population using above query using WITH(CTE) clause

With VacvsPop (continent,Location, Date, population, NewVaccination, TotalVaccinated)
as
(
Select cast(Dea.continent as CHAR), Dea.Location, Dea.date, cast(Dea.population as UNSIGNED),
cast(Vac.new_vaccinations as UNSIGNED) as NewVaccination,
SUM(cast(Vac.new_vaccinations as UNSIGNED )) over (partition by Dea.location order by Dea.location, Dea.date) as TotalVaccinated
-- (TotalVaccinated/Dea.population)*100 as VaccinatedperPopulation 
from sql_project.coviddata_deaths as Dea
JOIN sql_project.coviddata_vaccine as Vac
on Dea.Location = Vac.Location
and Dea.date = Vac.date
where Dea.continent is not null
-- order by 2,3
)
Select * , (TotalVaccinated/population)*100 as Vac_perpopulation
from  VacvsPop

-- Creating View to store data for later visualizations / percentage of population infected with Covid in INDIA

Create View IndiaPercentPopulation as 
select location, date, population, total_cases, total_deaths, (total_cases/ population)*100 as PercentageGotCovid
from sql_project.coviddata_deaths
where location = "India"
order by 1, month(date)
