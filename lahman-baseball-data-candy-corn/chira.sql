--1

--What range of years for baseball games played does the provided database cover?

select max(finalgame), min(debut)
from people


--2
/*
SELECT namelast, namefirst, height, appearances.g_all as games_played, appearances.teamid as team
FROM people
INNER JOIN appearances
ON people.playerid = appearances.playerid
WHERE height IS NOT null
ORDER BY height;
*/

--3

/* 1- Find all players in the database who played at Vanderbilt University
   2- Create a list showing each player’s first and last names
   3- as well as the total salary they earned in the major leagues
   4- Sort this list in descending order by the total salary earned
   5- Which Vanderbilt player earned the most money in the majors? 
*/

--3

/*


WITH vandy AS (SELECT *
				FROM collegeplaying
				WHERE schoolid = 'vandy'),
	vandy_names	AS (SELECT DISTINCT(playerid), namefirst, namelast
			   FROM vandy
			   LEFT JOIN people
			   USING(playerid))
SELECT distinct(playerid), namefirst, namelast,
	sum(salary) over(partition by salaries.playerid) as total_earned
FROM vandy_names
LEFT JOIN salaries
USING(playerid)
where salary is not null
ORDER BY total_earned desc;
*/

--4

/*







*/

/*

  -Using the attendance figures from the homegames table,
  -find the teams and parks which had the top 5 average attendance per game in 2016 
  -(where average attendance is defined as total attendance divided by number of games). 
  -Only consider parks where there were at least 10 games played
  -Report the park name
  -team name
  -and average attendance.
  -Repeat for the lowest 5 average attendance.
*/
/*

with avg_atten as (select team, attendance/games as average
			   from homegames
			   where year = 2016)

select *
from homegames 
left join avg_atten 
using (team)
where year = 2016
and games > 10
order by average --desc
limit 5

*/

/*

  -Analyze all the colleges in the state of Tennessee.
  -Which college has had the most success in the major leagues.
  -Use whatever metric for success you like - 
  -number of players, number of games, salaries, world series wins, etc.


*/
/*
WITH avg_attend as (SELECT team, park, ROUND(attendance::float/games::float) as avg_attendance
				 	 FROM homegames
				  	WHERE year = 2016
				  	AND games >= 10 )
SELECT team, teams.name, park_name, avg_attendance
FROM avg_attend
LEFT JOIN parks
USING(park)
LEFT JOIN teams
ON avg_attend.team = teams.teamid
WHERE teams.yearid = 2016
ORDER BY avg_attendance DESC;

*/

--Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
--Give their full name and the teams that they were managing when they won the award.

/*
with tid as (select teamid, awardsmanagers.playerid
			from awardsmanagers
			left join appearances
			on awardsmanagers.playerid = appearances.playerid
			)

select awardsmanagers.playerid, awardsmanagers.yearid, awardsmanagers.lgid, namefirst, namelast, namegiven, awardsmanagers.awardid
from awardsmanagers
left join people
on awardsmanagers.playerid = people.playerid
left join appearances
on awardsmanagers.playerid = appearances.playerid
*/

/*

  -Analyze all the colleges in the state of Tennessee.
  -Which college has had the most success in the major leagues.
  -Use whatever metric for success you like - number of players, 
  -number of games, salaries, world series wins, etc.
*/ 
--Number of players from TN = 162

with college_stuff as	(select collegeplaying.schoolid, schoolname, schoolstate, playerid, yearid as college_year_id
						from schools
						left join collegeplaying
						on schools.schoolid = collegeplaying.schoolid
						where schoolstate = 'TN'
						order by schoolname)

select * --distinct(people.playerid)
--sum(salary) over(partition by schoolname) as total_earned
from people
left join college_stuff
on people.playerid = college_stuff.playerid 
left join salaries
on people.playerid = salaries.playerid 
where schoolstate = 'TN'
and salary is not null
order by people.playerid

-- first open ended question 
with tn_players as (select schoolid, schoolstate, schoolname
				   from schools
				   where schoolstate= 'TN'),
college_pstate as (select distinct(playerid), schoolstate, schoolid
					   from collegeplaying
					   left join tn_players
					   using(schoolid)
					   where schoolstate = 'TN'
				   		and playerid is not null
				  )
					   
select distinct(schoolid), 
sum(salary) over(partition by schoolid) as total_earned
from salaries
left join College_pstate
using(playerid)
where schoolid is not null
order by total_earned desc 

--Find the name and height of the shortest player in the database.
--How many games did he play in? What is the name of the team for which he played?

with team as(select playerid, teamid
			  from appearances),
	hg as(select teamid, team, teamid
		 from homegames
		 left join team
		 using(teamid))

select height, namefirst, namelast, teamid, team
from people
left join team
using(playerid)
left join hg
using(playerid)
order by height
limit 1

















WITH TN_schools AS (SELECT *
					FROM schools
					WHERE schoolstate = 'TN'),
TN_players AS (SELECT DISTINCT(playerid), schoolname
			  FROM TN_schools
			  LEFT JOIN collegeplaying
			  USING(schoolid)
			  WHERE playerid IS NOT NULL),
TN_salaries AS (SELECT *
				FROM TN_players
				LEFT JOIN
				salaries
				USING(playerid)),
TN_salary_total AS (SELECT DISTINCT(playerid), schoolname, SUM(salary) OVER(PARTITION BY playerid) as total_salary
					FROM TN_salaries
					WHERE salary IS NOT NULL)
SELECT DISTINCT(schoolname), COUNT(playerid) OVER (PARTITION BY schoolname) as total_players, (SUM(total_salary) OVER (PARTITION BY schoolname))::numeric::money as combined_salaries
FROM TN_salary_total
ORDER BY combined_salaries DESC;



