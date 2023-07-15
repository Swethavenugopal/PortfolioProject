select * 
from portfolio_proj..coviddeaths
--where continent is not Null
order by 3,4

--select * 
--from portfolio_proj..[covid-vaccinations]
--order by 3,4

--select data we are going to be using
select location , date,total_cases,new_cases,total_deaths,	population
from portfolio_proj..coviddeaths
order by 1,2

--looking at total cases vs total death
--likelyhood of death that can occur in ur country
select location , date,  total_cases, total_deaths,  (CAST(total_deaths AS  float ) / CAST(total_cases AS float) )*100 as death_percentage
from portfolio_proj..coviddeaths 
where location like '%States%' and  continent is not Null
order by 1,2


--Looking tot case vs Population
select location , date,  total_cases, population,  (CAST(total_cases AS  float ) / population )*100 as cases_percentage
from portfolio_proj..coviddeaths
where location like '%States%' and continent is not Null
order by 1,2

--Looking at cont which has highest infection rate vs Population
select location ,date , max(CAST(total_cases AS  float)) as highestInfectioncount, population, max (CAST(total_cases AS  float ) / population )*100 as percentpopInfected
from portfolio_proj..coviddeaths
--where location like '%States%'
where continent is not Null
group by location,population,date
order by percentpopInfected desc

--showing at cont which has highest death count vs Population
select location ,date , max(CAST(total_deaths AS  float)) as deathcasecount
from portfolio_proj..coviddeaths
where continent is not Null
group by location,population,date
order by deathcasecount desc

-- break by continents
select location  , max(CAST(total_deaths AS  float)) as deathcasecount
from portfolio_proj..coviddeaths
where continent is  Null
group by location
order by deathcasecount desc

--global numbers
select date, SUM(new_cases) as totalCases,sum(cast(new_deaths as int)) as totaldeaths,--(sum(cast(new_deaths as int)) / SUM(new_cases) )*100 as death_percentage
CASE
		When SUM(new_cases) <= 0 THEN NULL
    ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
  END AS deathPercentage
from portfolio_proj..coviddeaths 
--where location like '%States%'
where  continent  is not Null --and new_cases >1 
group by date
order by 1,2

--global numbers
select  SUM(new_cases) as totalCases,sum(cast(new_deaths as int)) as totaldeaths,--(sum(cast(new_deaths as int)) / SUM(new_cases) )*100 as death_percentage
CASE
		When SUM(new_cases) <= 0 THEN NULL
    ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
  END AS deathPercentage
from portfolio_proj..coviddeaths 
--where location like '%States%'
where  continent  is not Null --and new_cases >1 
--group by date
order by 1,2


--joining of death table and vac table
select *
from portfolio_proj..coviddeaths dea
join portfolio_proj..[covid-vaccinations] vac
  on dea.location=vac.location
  and dea.date=vac.date


  --Looking at total pop vs vaci
  select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location 
  order by dea.location ,dea.date ) as rolling_ppl_vac
--  ,(rolling_ppl_vac/ dea.population)*100
from portfolio_proj..coviddeaths dea
join portfolio_proj..[covid-vaccinations] vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 2,3

--use cte 

with popvsvac(continent,location,date,population,new_vaccinations,rolling_ppl_vac)

as (
 select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location 
  order by dea.location ,dea.date ) as rolling_ppl_vac
--  ,(rolling_ppl_vac/ dea.population)*100
from portfolio_proj..coviddeaths dea
join portfolio_proj..[covid-vaccinations] vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3
  )
select *,(rolling_ppl_vac/population)*100
from popvsvac


--temp table

create table #percentpopvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_ppl_vac numeric
)


insert into #percentpopvaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location 
  order by dea.location ,dea.date ) as rolling_ppl_vac
--  ,(rolling_ppl_vac/ dea.population)*100
from portfolio_proj..coviddeaths dea
join portfolio_proj..[covid-vaccinations] vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3
  select *,(rolling_ppl_vac/population)*100
  from #percentpopvaccinated

  
  
  --creating a view to store data for later visualization
  create view percentpopvaccinated as
  select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location 
  order by dea.location ,dea.date ) as rolling_ppl_vac
--  ,(rolling_ppl_vac/ dea.population)*100
from portfolio_proj..coviddeaths dea
join portfolio_proj..[covid-vaccinations] vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3
  

  select *
  from percentpopvaccinated