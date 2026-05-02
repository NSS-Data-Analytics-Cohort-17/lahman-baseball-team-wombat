-- What range of years for baseball games played does the provided database cover?

SELECT MIN(year), MAX(year)
FROM homegames;

-- Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT DISTINCT (namefirst || ' ' || namelast) AS NAME, height, g_all AS total_games, teams.name AS team_name 
FROM people LEFT JOIN appearances USING(playerid) LEFT JOIN teams ON appearances.teamid = teams.teamid 
WHERE playerid = (SELECT playerid FROM people WHERE height = (SELECT MIN(height) FROM people));

-- Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT namefirst || ' '|| namelast AS NAME, SUM(salary) FROM schools
INNER JOIN collegeplaying ON schools.schoolid = collegeplaying.schoolid
INNER JOIN people ON collegeplaying.playerid = people.playerid
INNER JOIN salaries ON people.playerid = salaries.playerid
WHERE schoolname = 'Vanderbilt University'
GROUP BY people.playerid, namefirst, namelast
ORDER BY SUM(salary) DESC;

-- Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT CASE 
  WHEN fielding.pos = 'OF' THEN 'Outfield'
  WHEN fielding.pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
  WHEN fielding.pos IN ('P', 'C') THEN 'Battery'
END AS position_group,
SUM(fielding.po)
FROM fielding
WHERE fielding.yearid = 2016
GROUP BY position_group;

-- Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT (teams.yearid / 10) * 10 AS decade,
    ROUND(CAST(SUM(teams.so) AS NUMERIC) / SUM(teams.g), 2) AS avg_so_per_game,
    ROUND(CAST(SUM(teams.hr) AS NUMERIC) / SUM(teams.g), 2) AS avg_hr_per_game
FROM teams
WHERE teams.yearid >= 1920
GROUP BY decade
ORDER BY decade;

-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT 
    p.namefirst, 
    p.namelast, 
    ROUND((CAST(b.sb AS NUMERIC) / (b.sb + b.cs)) * 100, 2) AS success_pct
FROM batting b
INNER JOIN people p ON b.playerid = p.playerid
WHERE b.yearid = 2016 AND (b.sb + b.cs) >= 20
ORDER BY success_pct DESC
LIMIT 1;

-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT name, yearid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND yearid <> 1981
  AND ((wswin = 'N') OR (wswin = 'Y'));

WITH max_wins_per_year AS (SELECT yearid, MAX(w) as max_w
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016 AND yearid <> 1981
    GROUP BY yearid)
SELECT 
    SUM(CASE WHEN t.wswin = 'Y' THEN 1 ELSE 0 END) AS frequent_winners,
    COUNT(*) AS total_years,
    ROUND(SUM(CASE WHEN t.wswin = 'Y' THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS percentage
FROM teams t
JOIN max_wins_per_year mw ON t.yearid = mw.yearid AND t.w = mw.max_w
WHERE t.yearid BETWEEN 1970 AND 2016 AND t.yearid <> 1981;

-- Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT 
    p.park_name, 
    t.name AS team_name, 
    (h.attendance / h.games) AS avg_attendance
FROM homegames h
INNER JOIN parks p ON h.park = p.park
INNER JOIN teams t ON h.team = t.teamid AND h.year = t.yearid
WHERE h.year = 2016 AND h.games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;


-- Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT (p.namefirst || ' ' || p.namelast) AS name, am.yearid, am.lgid, t.name AS team
FROM awardsmanagers am
LEFT JOIN people p ON am.playerid = p.playerid
LEFT JOIN managers m ON am.playerid = m.playerid AND am.yearid = m.yearid
LEFT JOIN teams t ON m.teamid = t.teamid AND m.yearid = t.yearid
WHERE am.awardid = 'TSN Manager of the Year'
  AND am.playerid IN (SELECT playerid 
      FROM awardsmanagers 
      WHERE awardid = 'TSN Manager of the Year' 
        AND lgid IN ('AL', 'NL')
      GROUP BY playerid 
      HAVING COUNT(DISTINCT lgid) = 2)
ORDER BY name, am.yearid;


-- Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
SELECT people.namefirst, people.namelast, batting.hr
FROM batting
JOIN people ON batting.playerid = people.playerid
WHERE batting.yearid = 2016 
  AND batting.hr > 0
  AND batting.hr = (SELECT MAX(inner_batting.hr) 
      FROM batting AS inner_batting 
      WHERE inner_batting.playerid = batting.playerid)
  AND (SELECT COUNT(DISTINCT inner_batting.yearid) 
      FROM batting AS inner_batting 
      WHERE inner_batting.playerid = batting.playerid) >= 10;