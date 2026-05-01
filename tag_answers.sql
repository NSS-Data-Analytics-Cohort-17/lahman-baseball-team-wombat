--Q1
select min(year), max(year)
from homegames;
--1871 to 2016

--Q2
select distinct(namefirst || ' ' || namelast) as name, height, g_all as total_games, teams.name as team_name
from people left join appearances using(playerid) left join teams on appearances.teamid = teams.teamid
where playerid = (select playerid
				  from people
	  			  where height = (select min(height) from people));
--Eddie Gaedel was the shortest player with a height of 43 in and he played 1 game for the St. Louis Browns.

--Q3
select namefirst || ' ' || namelast as name, sum(salary) as total_salary
from salaries inner join (select distinct(playerid), namefirst, namelast 
						  from collegeplaying left join people using(playerid) 
						  where schoolid = 'vandy') using (playerid)
group by name
order by total_salary desc;
--Of vanderbilt alumni, David Price has the highest total salary with $81,851,296.

--Q4
select case when pos = 'OF' then 'Outfield'
			when pos in('SS','1B','2B','3B') then 'Infield'
			when pos in('P','C') then 'Battery'
		end as position, 
		sum(po)
from fielding
where yearid = 2016
group by position;

--Q5

--Q6

--Q7 **
select name, yearid, teamid, g as games, w as wins, l as losses, wswin as World_Series_winner  
from teams
where yearid <= 2016 and yearid >= 1970 and wswin = 'N' and w = (select max(w) from teams where yearid <= 2016 and yearid >= 1970 and wswin = 'N')
union
select name, yearid, teamid, g as games, w as wins, l as losses, wswin as World_Series_winner  
from teams
where yearid <= 2016 and yearid >= 1970 and wswin = 'Y' and w = (select min(w) from teams where yearid <= 2016 and yearid >= 1970 and wswin = 'Y');

--Highest Wins without winning the world series is from the Seattle Mariners in 2001 with 116 wins out of 162 games.

--The least amount of wins while winning the world series is 63 by the Los Angeles Dodgers in 1981 with only 63 games won.
--The reason they were able to do this is because the players in the MLB went on a 50-day strike half way through the season resulting
--in 2 winners that year. One for the first half of the season and one for the second half of the season. 

select count(World_Series_winner) * 100 / 91 as Percent_of_WSWinners_with_Most_Wins
from(
select yearid, max(wins), World_Series_winner
from (
select yearid, w as wins, wswin as World_Series_Winner
from teams
where yearid <= 2016 and yearid >= 1970 and yearid != 1981)
group by yearid, World_Series_Winner)
where World_Series_winner = 'Y';

--Only 49% of the world series winners have the most wins for the season.

--Q8 **
select distinct park, park_name, name, games, attendance, attendance / games as avg_attendance
from homegames left join parks using(park) left join (select distinct teamid, name from teams where yearid = 2016 order by teamid) as t on homegames.team = t.teamid
where year = 2016 and games >= 10
order by avg_attendance desc
limit 5;

select distinct park, park_name, name, games, attendance, attendance / games as avg_attendance
from homegames left join parks using(park) left join (select distinct teamid, name from teams where yearid = 2016 order by teamid) as t on homegames.team = t.teamid
where year = 2016 and games >= 10
order by avg_attendance asc
limit 5;
--Q9

--Q10