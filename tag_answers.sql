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
select (teams.yearid / 10) * 10 as decade, round(sum(so :: numeric) / sum(g :: numeric)) as avg_so_per_game, round(sum(hr :: numeric) / sum(g :: numeric)) as avg_hr_per_game
from teams
where teams.yearid >= 1920
group by decade
order by decade;
--Query from Cameron

--Q6
select playerid, namegiven, sb, cs, (sb *100 / (sb + cs)) as p
from batting left join people using (playerid)
where yearid = 2016 and (cs + sb) >= 20
order by p desc
limit 1;

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
select playerid, people.namegiven, yearid, teamid, teams.name, awardid
from awardsmanagers left join managers using(playerid, yearid) left join teams using(teamid, yearid) left join people using(playerid)
where playerid in(select a.playerid
			      from awardsmanagers a cross join awardsmanagers b 
				  where a.awardid = 'TSN Manager of the Year' and a.lgid = 'NL' and b.awardid = 'TSN Manager of the Year' and b.lgid = 'AL' and a.playerid = b.playerid)
and awardid = 'TSN Manager of the Year'
order by playerid;

--Q10
select * 
from(select playerid, namegiven, yearid, hr
	 from batting b1 left join people using(playerid)
	 where playerid in(select playerid
				 	   from batting left join people using(playerid)
				 	   where left(finalgame, 4) :: integer - left(debut, 4) :: integer >= 10 and (case when yearid = 2016 and hr > 0 then 'Y' else 'N' end) = 'Y')
and b1.hr = (select max(hr)
			 from batting b2
			 where b2.playerid = b1.playerid))
where yearid = 2016;