Select * from CovidDeaths where continent <> '' order by 3,4

Select
	location, date, total_cases, new_cases, total_deaths, population
from 
	CovidDeaths
order by 
	location

	Select
	location, date, total_cases, total_deaths, (Cast(total_deaths as int)/IIF(Cast(total_cases as int) <= 0, 0.1, Cast(total_cases as int))) * 100[Deaths %]
from 
	CovidDeaths
where
	location like '%Malay%'
order by 
	location

--looking for total cases vs population
--show how many % of population infect by covid
Select
	location, date, population, total_cases, 
	(Cast(total_cases as int)/IIF(Cast(population as int) <= 0, 0.1, Cast(population as int))) * 100[% Population Infected]
from 
	CovidDeaths
where
	location like '%Malay%'
order by 
	location

--looking at highest infection rate country
Select
	location, population, 
	MAX(total_cases)[Max cases], Cast(MAX(total_cases) as float)/IIF(Cast(population as float) <= 0, 0.1, Cast(population as float)) * 100 as PopulationInfected
from 
	CovidDeaths
group by 
	location, population
order by 
	PopulationInfected desc

-- Showing country with highest death rate 
Select
	location,  
	Cast(MAX(total_deaths) as float)[highesttotaldeathcount]
	--Cast(MAX(total_cases) as float)/IIF(Cast(population as float) <= 0, 0.1, Cast(population as float)) * 100 as PopulationInfected
from 
	CovidDeaths
where
	continent <> ''
group by 
	location
order by 
	highesttotaldeathcount desc


	Select
	continent,  
	Cast(MAX(total_deaths) as int)[highesttotaldeathcount]
	--Cast(MAX(total_cases) as float)/IIF(Cast(population as float) <= 0, 0.1, Cast(population as float)) * 100 as PopulationInfected
from 
	CovidDeaths
where
	continent <> ''
group by 
	continent
order by 
	highesttotaldeathcount desc

--showing continent with the highest death count per population

	Select
	continent,
	Cast(MAX(total_deaths) as float)[highesttotaldeathcount],
	Cast(MAX(total_deaths) as float)/IIF(Cast(MAX(population) as float) <= 0, 0.1, Cast(MAX(population) as float)) * 100 as PopulationDeath
from 
	CovidDeaths
where
	continent <> ''
group by 
	continent
--	continent, population, location
order by 
	PopulationDeath desc


--Show daily global number
select 
	 SUM(new_cases)[TotalCases], SUM(cast(new_deaths as int))[Total_Death],
	SUM(cast(new_deaths as int))/SUM(NULLIF(new_cases, 0)) * 100
from
	CovidDeaths
where
	continent <> ''
--group by
--	date
order by
	date


	Select 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over 
		(partition by dea.location order by dea.location, dea.date)Roolingpeoplevacination
			from CovidDeaths dea
	join
	CovidVaccinations vac
	on
		vac.location = dea.location
	and
		vac.date = dea.date
	where
		dea.continent <> ''
	order by
		dea.location, dea.date

		--showing population vs vaccination rate
	With CTE_popvsvac(continent, location, date, population, new_vaccinations, Roolingpeoplevacination)
	as
	(
	Select 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over 
		(partition by dea.location order by dea.location, dea.date)Roolingpeoplevacination
			from CovidDeaths dea
	join
	CovidVaccinations vac
	on
		vac.location = dea.location
	and
		vac.date = dea.date
	where
		dea.continent <> ''
	--order by
	--	dea.location, dea.date
	)
	Select *, CTE_popvsvac.Roolingpeoplevacination/population * 100 from CTE_popvsvac

	drop table if exists #temp 
	Select 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over 
		(partition by dea.location order by dea.location, dea.date)Roolingpeoplevacination
		into
		#temp
			from CovidDeaths dea
	join
	CovidVaccinations vac
	on
		vac.location = dea.location
	and
		vac.date = dea.date
	
	where
		dea.continent <> ''
	--order by
	--	dea.location, dea.date

	Select *, Roolingpeoplevacination/population * 100 from #temp order by location, date

	--Creating view to store data for later data visualitazion
	Create View PercentagePopulationVaccinated as
		Select 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over 
		(partition by dea.location order by dea.location, dea.date)Roolingpeoplevacination

			from CovidDeaths dea
	join
	CovidVaccinations vac
	on
		vac.location = dea.location
	and
		vac.date = dea.date
	
	where
		dea.continent <> ''


		Select * from PercentagePopulationVaccinated

