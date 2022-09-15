--checking the data

select *  from project_census.dbo.data1;

select *  from project_census.dbo.data2;

--number of rows

select count(*) from project_census.dbo.data1;
select count(*) from project_census.dbo.data2;

--dataset for Jharkhand and Bihar

select * from project_census.dbo.data1 where state in ('Jharkhand' , 'Bihar') order by state;

select * from project_census.dbo.data2 where state in ('Jharkhand' , 'Bihar') order by state;

--population of india

select sum(population ) as total_population from project_census.dbo.data2;

--average populatin growth

select avg(growth)*100 as avg_population_growth from project_census.dbo.data1;

select state, avg(growth)*100 as avg_population_growth from project_census.dbo.data1 group by state;

--average sex ratio

select round(avg(sex_ratio),0) as avg_sex_ratio from project_census.dbo.data1;

select state, round(avg(sex_ratio),0) as avg_sex_ratio from project_census.dbo.data1 group by state order by avg_sex_ratio desc;

--average literacy rate

select round(avg(literacy),0) as avg_literacy_ratio from project_census.dbo.data1;

select state, round(avg(literacy),0) as avg_literacy_ratio from project_census.dbo.data1 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc;

--top 3 states showing highest growth ratio

select top 3 state, avg(growth)*100 as avg_population_growth from project_census.dbo.data1 group by state order by avg_population_growth desc;

--bottom 3 states showing lowest sex ratio

select top 3 state, round(avg(sex_ratio),0) as avg_sex_ratio from project_census.dbo.data1 group by state order by avg_sex_ratio asc;

--top and bottom 3 states in literacy rates
--top
drop table if exists #topstates
create table #topstates(
state nvarchar(255),
topstate float
)
 insert into #topstates 
 select state, round(avg(literacy),0) as avg_literacy_ratio from project_census.dbo.data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

--bottom

drop table if exists #bottomstates
create table #bottomstates(
state nvarchar(255),
bottomstate float
)
 insert into #bottomstates 
 select state, round(avg(literacy),0) as avg_literacy_ratio from project_census.dbo.data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union operator
select * from (
select top 3 * from #topstates order by #topstates.topstate desc) t
union
select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


---states starting with specific letter

select distinct state from project_census.dbo.data1 where lower(state) like 'a%' or lower(state) like 'b%';

select distinct state from project_census.dbo.data1 where lower(state) like 'a%' or lower(state) like '%d';

select distinct state from project_census.dbo.data1 where lower(state) like 'a%' and lower(state) like '%m';


-- Joining both tables

select a.district, a.state, a.sex_ratio, b.population from project_census.dbo.data1 a inner join project_census.dbo.data2 b on a.District=b.District

--calculating number of males and females

select d.state, sum(d.males) total_males, sum(d.females) total_females from 
(select c.district, c.state, c.population, round((c.population/(c.sex_ratio+1)),0)males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from 
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from project_census.dbo.data1 a inner join project_census.dbo.data2 b on a.District=b.District) c) d
 group by d.state

--total literate people

select c.state, sum(c.literate_people) total_literate_people , sum(c.illiterate_people) total_illiterate_people from
(select d.district, d.state, round((d.literacy_rate*d.population),0) literate_people, round(((1-d.literacy_rate)*d.population),0) illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_rate, b.population from project_census.dbo.data1 a inner join project_census.dbo.data2 b on a.District=b.District) d) c
group by c.state

-- population of previous census

select sum(m.previous_census) previous_population, sum(current_census) current_population from
(select e.state, sum(e.previous_census) previous_census, sum(e.current_census) current_census from
(select d.state, d.district, round(d.population/(1+growth),0) previous_census, d.population current_census from
(select a.district, a.state, a.growth, b.population from project_census.dbo.data1 a inner join project_census.dbo.data2 b on a.District=b.District) d) e
group by e.state) m 

--population vs area
select g.total_area/g.previous_population previous_population_vs_area, g.total_area/g.current_population current_population_vs_area from
(select q.*,r.total_area from
(select '1' as keyy, n. * from
(select sum(m.previous_census) previous_population, sum(current_census) current_population from
(select e.state, sum(e.previous_census) previous_census, sum(e.current_census) current_census from
(select d.state, d.district, round(d.population/(1+growth),0) previous_census, d.population current_census from
(select a.district, a.state, a.growth, b.population from project_census.dbo.data1 a inner join project_census.dbo.data2 b on a.District=b.District) d) e
group by e.state) m) n) q inner join 

(select '1' as keyy, z. * from
(select sum(Area_km2) total_area from project_census.dbo.data2)z) r on q.keyy=r.keyy)g

--window functions
--output top 3 districts from states based on literacy rate

select a.* from
(select state, district, literacy, rank() over (partition by state order by literacy desc) rnk from project_census.dbo.data1)a
where a.rnk in (1,2,3) order by state

--output bottom 3 districts from states based on literacy rate

select a.* from
(select state, district, literacy, rank() over (partition by state order by literacy asc) rnk from project_census.dbo.data1)a
where a.rnk in (1,2,3) order by state