select count(*) from project..CovidDeaths$
where continent is not null
group by location

--get data 

SELECT location, date, total_cases, new_cases ,round((new_cases/total_cases),2)*100 as rate_cases
FROM project..CovidDeaths$
where location like '%china%'
order by 1,2

--looking at total cases vs population

SELECT location, date, total_cases, new_cases ,population,(total_cases/population)*100 as rate_cases
FROM project..CovidDeaths$
--where location like '%hin%'
order by 1,2

--looking countries with highest infected rate

SELECT location,  max(total_cases) as rate
FROM project..CovidDeaths$
where continent is not null
group by location
order by rate desc

--looking conntinent with highest infected rate

SELECT continent,  max(total_cases) as rate
FROM project..CovidDeaths$
where continent is not null
group by continent
order by rate desc

--global number

select date,sum(new_cases) as newcases, sum(cast(new_deaths as float)) as deathsrate,sum(new_cases)/sum(cast(new_deaths as int))*100 ascfact
FROM project..CovidDeaths$
where continent is not null
group by date
order by newcases desc


--cte
with popvsvac (continent,location,date,population,new_vaccinations,rolling)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as rolling
FROM project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
)
select *,(rolling/population)*100 as perc from popvsvac


--temp table
--drop table if exists #t
create table #t
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling numeric
)

insert into #t
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as rolling
FROM project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date

select *,(rolling/population)*100 as perc from #t

--create view

create view percenta as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as rolling
FROM project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date