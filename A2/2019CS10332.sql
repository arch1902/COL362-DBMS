--1--
WITH RECURSIVE routes(dest,depth) AS (
    SELECT  destination_station_name, 1
    FROM train_info
    WHERE source_station_name = 'KURLA'
    AND train_no = 97131
    UNION ALL
    SELECT train_info.destination_station_name, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND depth < 3
)
SELECT DISTINCT dest as destination_station_name
FROM routes
ORDER BY destination_station_name;


--2--
WITH RECURSIVE routes(dest,day,depth) AS (
    SELECT  destination_station_name,day_of_departure, 1
    FROM train_info
    WHERE source_station_name = 'KURLA'
    AND day_of_arrival = day_of_departure
    AND train_no = 97131
    UNION ALL
    SELECT train_info.destination_station_name,routes.day, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND routes.day = train_info.day_of_arrival
    AND train_info.day_of_arrival = train_info.day_of_departure
    AND depth < 3
)
SELECT DISTINCT dest as destination_station_name
FROM routes
ORDER BY destination_station_name;


--3--
WITH RECURSIVE routes(src,dest,dist,day,depth) AS (
    SELECT source_station_name, destination_station_name, distance, train_info.day_of_departure, 1
    FROM train_info
    WHERE source_station_name = 'DADAR'
    AND train_info.day_of_arrival = train_info.day_of_departure
    UNION ALL
    SELECT  routes.src,train_info.destination_station_name,train_info.distance+routes.dist,routes.day, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND routes.day = train_info.day_of_arrival
    AND train_info.day_of_arrival = train_info.day_of_departure
    AND depth < 3
)
SELECT DISTINCT dest as destination_station_name, dist AS distance, day
FROM routes
WHERE dest != 'DADAR'
ORDER BY destination_station_name,distance,day; 


--4--
WITH RECURSIVE foo AS (
    select day,num from (select day, case when day = 'Wednesday' then 3 when day = 'Monday' then 1 when day = 'Tuesday' then 2 when day = 'Friday' then 5 when day = 'Thursday' then 4 when day = 'Sunday' then 7 when day = 'Saturday' then 6 else 0 end as num from (select day_of_departure as day from train_info union select day_of_arrival as day from train_info) as x) as y where num != 0
),
new_train_info AS (
    SELECT source_station_name,num as day_dep,departure_time,destination_station_name,day_of_arrival,arrival_time
    FROM train_info,foo
    WHERE foo.day = day_of_departure
),
final_train_info AS (
    SELECT source_station_name, day_dep,departure_time,destination_station_name, num as day_arr,arrival_time
    FROM new_train_info , foo
    WHERE foo.day = day_of_arrival
),
routes(src,dest,day,time,depth) AS (
    SELECT source_station_name, destination_station_name, day_arr,train_info.arrival_time, 1
    FROM final_train_info as train_info 
    WHERE source_station_name = 'DADAR'
    AND (day_dep < day_arr or (day_dep=day_arr AND train_info.departure_time <= train_info.arrival_time))

    UNION ALL

    SELECT  routes.src,train_info.destination_station_name,train_info.day_arr,train_info.arrival_time, depth + 1 
    FROM final_train_info as train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND (day < day_dep or (day = day_dep AND time <= train_info.departure_time))
    AND (day_dep < day_arr or (day_dep=day_arr AND train_info.departure_time <= train_info.arrival_time))
    AND depth < 3
)
SELECT DISTINCT dest as destination_station_name
FROM routes
WHERE dest != 'DADAR'
ORDER BY destination_station_name;


--5--
WITH RECURSIVE routes(src,dest,depth) AS (
    SELECT source_station_name, destination_station_name, 1
    FROM train_info
    WHERE source_station_name = 'CST-MUMBAI'
    UNION ALL
    SELECT  routes.src,train_info.destination_station_name, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND train_info.source_station_name != 'VASHI'
    AND train_info.source_station_name != 'CST-MUMBAI'
    AND depth < 3
)
SELECT count(*) as Count
FROM routes
WHERE routes.dest = 'VASHI';


--6--
WITH RECURSIVE routes(src,dest,path,dist,depth) AS (
    SELECT source_station_name, destination_station_name,array[source_station_name,destination_station_name], distance, 1
    FROM train_info
    UNION ALL
    SELECT routes.src,train_info.destination_station_name,path || train_info.destination_station_name,train_info.distance+routes.dist, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND (not (train_info.destination_station_name = ANY(path)) )
    AND depth < 6
)
SELECT  dest as destination_station_name,src as source_station_name, MIN(dist) as distance
FROM routes
WHERE dest!=src
GROUP BY source_station_name, destination_station_name
ORDER BY destination_station_name,source_station_name;


--7--
WITH RECURSIVE routes(src,dest,depth) AS (
    SELECT DISTINCT source_station_name, destination_station_name, 1
    FROM train_info
    UNION ALL
    SELECT DISTINCT routes.src,train_info.destination_station_name,depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    --AND not(train_info.destination_station_name = ANY(path))
    AND depth < 4
)
SELECT DISTINCT src as source_station_name, dest as destination_station_name
FROM routes
WHERE src != dest
ORDER BY source_station_name;


--8--
WITH RECURSIVE routes(dest,day,depth) AS (
    SELECT DISTINCT  destination_station_name,day_of_arrival, 1
    FROM train_info
    WHERE source_station_name='SHIVAJINAGAR'
    AND day_of_arrival = day_of_departure
    UNION ALL
    SELECT DISTINCT train_info.destination_station_name,day, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND routes.day = train_info.day_of_arrival
    AND train_info.day_of_arrival = train_info.day_of_departure
)
SELECT DISTINCT  dest as destination_station_name, day
FROM routes
WHERE dest != 'SHIVAJINAGAR'
ORDER BY destination_station_name;

--9--
WITH RECURSIVE routes(src,dest,day,dist,path,depth) AS (
    SELECT source_station_name, destination_station_name, day_of_arrival , distance, array[source_station_name,destination_station_name], 1
    FROM train_info
    WHERE source_station_name = 'LONAVLA'
    AND day_of_arrival = day_of_departure
    UNION ALL
    SELECT routes.src, train_info.destination_station_name,routes.day,train_info.distance+routes.dist, path || train_info.destination_station_name, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND routes.day = train_info.day_of_arrival
    AND day_of_arrival = day_of_departure
    AND (not (train_info.destination_station_name = ANY(path)) )
    --AND depth < 3
)

SELECT dest as destination_station_name,MIN(dist) as distance,day
FROM routes
WHERE dest != 'LONAVLA'
GROUP BY destination_station_name,day
ORDER BY distance, dest;

--10--
WITH RECURSIVE routes(src,dest,path,dist,depth) AS (
    SELECT source_station_name, destination_station_name,array[source_station_name,destination_station_name], distance, 1
    FROM train_info
    UNION
    SELECT  routes.src,train_info.destination_station_name,path || train_info.destination_station_name,train_info.distance+routes.dist, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND train_info.source_station_name != routes.src
    AND (not(train_info.destination_station_name = ANY(path)) OR train_info.destination_station_name=routes.src)
    AND train_info.source_station_name != train_info.destination_station_name
    --AND depth < 2
    
)
SELECT src as source_station_name,MAX(dist) as distance
FROM routes
WHERE src = dest
GROUP BY source_station_name
ORDER BY source_station_name;


--11--
WITH RECURSIVE routes(src,dest,depth) AS (
    SELECT source_station_name, destination_station_name, 1
    FROM train_info
    UNION ALL
    SELECT  routes.src,train_info.destination_station_name, depth + 1 
    FROM train_info, routes
    WHERE routes.dest = train_info.source_station_name
    AND depth < 2
),
A11 as (
    SELECT src as source_station_name, count(DISTINCT dest)
    FROM routes
    -- OPTION MAXRECURSION 6
    GROUP BY source_station_name
    ORDER BY count DESC,source_station_name
),
B11 AS (
    SELECT DISTINCT destination_station_name as stations
    FROM train_info
    UNION 
    SELECT DISTINCT source_station_name as stations
    FROM train_info
),
C11 AS (
    SELECT count(*)
    FROM B11
)
SELECT source_station_name
FROM A11,C11
WHERE A11.count = C11.count
ORDER BY source_station_name;


--12--
WITH a12 AS (
    SELECT teamid
    FROM teams
    WHERE name = 'Arsenal'
),
b12 AS (
    SELECT awayteamid
    FROM games,a12
    WHERE hometeamid = a12.teamid
),
c12 AS (
    SELECT hometeamid
    FROM games,b12,a12
    WHERE b12.awayteamid = games.awayteamid
    AND hometeamid != a12.teamid
)
SELECT DISTINCT name as teamnames
FROM teams,c12
WHERE hometeamid=teamid
ORDER BY name;


--13--
WITH a13 AS (
    SELECT teamid
    FROM teams
    WHERE name = 'Arsenal'
),
b13 AS (
    SELECT awayteamid
    FROM games,a13
    WHERE hometeamid = a13.teamid
),
c13 AS (
    SELECT games.hometeamid,games.year
    FROM games,b13,a13
    WHERE b13.awayteamid = games.awayteamid
    AND hometeamid != a13.teamid
    ORDER BY year
),
d13 AS (
    SELECT hometeamid,SUM(homegoals) as total_homegoals
    FROM games
    GROUP BY hometeamid
),
e13 AS (
    SELECT awayteamid,SUM(awaygoals) as total_awaygoals
    FROM games
    GROUP BY awayteamid
),
f13 AS (
    SELECT DISTINCT d13.hometeamid, total_awaygoals+total_homegoals as total_goals
    FROM d13,e13
    WHERE hometeamid = awayteamid
),
g13 AS (
    SELECT DISTINCT f13.hometeamid,year,total_goals
    FROM c13,f13
    WHERE C13.hometeamid = f13.hometeamid
    ORDER BY total_goals DESC, year
    LIMIT 1
),
h13 AS (
    SELECT DISTINCT f13.hometeamid,c13.year,f13.total_goals
    FROM c13,f13,g13
    WHERE C13.hometeamid = f13.hometeamid
    AND f13.total_goals = g13.total_goals
    AND c13.year = g13.year
)

SELECT name as teamnames,total_goals as goals,year
FROM teams,h13
WHERE hometeamid=teamid;


--14--
WITH a14 AS (
    SELECT teamid
    FROM teams
    WHERE name = 'Leicester'
),
temp AS (
    SELECT * 
    FROM games
    WHERE year = 2015
),
b14 AS (
    SELECT DISTINCT awayteamid
    FROM games,a14
    WHERE hometeamid = a14.teamid
),
temp2 AS (
    SELECT DISTINCT hometeamid
    FROM b14,games,a14
    WHERE b14.awayteamid = games.awayteamid
    AND hometeamid!=a14.teamid
),
temp3 AS (
    select gameid
    FROM temp,b14,temp2
    WHERE b14.awayteamid = temp.awayteamid
    AND temp2.hometeamid = temp.hometeamid
),
c14 AS (
    SELECT temp.hometeamid, (homegoals-awaygoals) as goals
    FROM temp,temp3
    WHERE temp.gameid = temp3.gameid
)
SELECT name as teamnames,goals as goaldiff
FROM c14,teams
WHERE goals > 3
AND hometeamid = teamid
ORDER BY goals,teamnames;



--15--
WITH a15 AS (
    SELECT teamid
    FROM teams
    WHERE name = 'Valencia'
),
b15 AS (
    SELECT DISTINCT awayteamid
    FROM games,a15
    WHERE games.hometeamid = a15.teamid
),
c15 AS (
    SELECT DISTINCT hometeamid
    FROM games,b15,a15
    WHERE b15.awayteamid = games.awayteamid
    AND hometeamid != a15.teamid
),
temp AS (
    SELECT DISTINCT gameid
    FROM games,c15,b15
    WHERE games.hometeamid = c15.hometeamid
    AND games.awayteamid = b15.awayteamid
),
d15 AS (
    SELECT playerid, SUM(goals)
    FROM appearances,temp
    WHERE appearances.gameid = temp.gameid
    GROUP BY playerid
    ORDER BY sum DESC
),
e15 AS (
    SELECT MAX(sum)
    FROM d15
)
SELECT name as playernames, sum as goals
FROM players,d15,e15
WHERE d15.sum = e15.max
AND players.playerid = d15.playerid
ORDER BY name;


--16--
WITH a15 AS (
    SELECT teamid
    FROM teams
    WHERE name = 'Everton'
),
b15 AS (
    SELECT DISTINCT awayteamid
    FROM games,a15
    WHERE games.hometeamid = a15.teamid
),
c15 AS (
    SELECT DISTINCT hometeamid
    FROM games,b15,a15
    WHERE b15.awayteamid = games.awayteamid
    AND hometeamid != a15.teamid
),
temp AS (
    SELECT DISTINCT gameid
    FROM games,c15,b15
    WHERE games.hometeamid = c15.hometeamid
    AND games.awayteamid = b15.awayteamid
),
d15 AS (
    SELECT playerid, SUM(assists)
    FROM appearances,temp
    WHERE appearances.gameid = temp.gameid
    GROUP BY playerid
    ORDER BY sum DESC
),
e15 AS (
    SELECT MAX(sum)
    FROM d15
)
SELECT name as playernames, sum as assistscount
FROM players,d15,e15
WHERE d15.sum = e15.max
AND players.playerid = d15.playerid
ORDER BY playernames;



--17--
WITH a15 AS (
    SELECT teamid
    FROM teams
    WHERE name = 'AC Milan'
),
b15 AS (
    SELECT DISTINCT hometeamid
    FROM games,a15
    WHERE games.awayteamid = a15.teamid
),
c15 AS (
    SELECT DISTINCT awayteamid
    FROM games,b15,a15
    WHERE b15.hometeamid = games.hometeamid
    AND awayteamid != a15.teamid
),
temp AS (
    SELECT DISTINCT gameid
    FROM games,c15,b15
    WHERE games.awayteamid = c15.awayteamid
    AND games.hometeamid = b15.hometeamid
    AND year = 2016
),

d15 AS (
    SELECT playerid, SUM(shots)
    FROM appearances,temp
    WHERE appearances.gameid = temp.gameid
    GROUP BY playerid
    ORDER BY sum DESC
),
e15 AS (
    SELECT MAX(sum)
    FROM d15
)
SELECT name as playernames, sum as shotscount
FROM players,d15,e15
WHERE d15.sum = e15.max
AND players.playerid = d15.playerid
ORDER BY playernames;


--18--
WITH a15 AS (
SELECT teamid
FROM teams
WHERE name = 'AC Milan'
),
b15 AS (
SELECT DISTINCT awayteamid
FROM games,a15
WHERE games.hometeamid = a15.teamid
),
c15 AS (
SELECT DISTINCT hometeamid
FROM games,b15,a15
WHERE b15.awayteamid = games.awayteamid
AND hometeamid != a15.teamid
),
d15 AS (
SELECT DISTINCT games.awayteamid,year,SUM(awaygoals)
FROM games,c15,b15
WHERE games.hometeamid = c15.hometeamid
AND games.awayteamid = b15.awayteamid
AND year = 2020
GROUP BY games.awayteamid,year
)
SELECT name as teamname,year
FROM teams,d15
WHERE teams.teamid = d15.awayteamid
AND sum = 0
ORDER BY name
LIMIT 5;



--19--
WITH A19 AS (
    SELECT hometeamid, leagueid, SUM(homegoals) as total_hg
    FROM games
    WHERE year = 2019
    GROUP BY hometeamid,leagueid
),
B19 AS (
    SELECT awayteamid, leagueid, SUM(awaygoals) as total_ag
    FROM games
    WHERE year = 2019
    GROUP BY awayteamid,leagueid
),
C19 AS (
    SELECT hometeamid as team, A19.leagueid, total_ag+total_hg as total_g
    FROM A19,B19
    WHERE hometeamid = awayteamid
    AND A19.leagueid = B19.leagueid
    ORDER BY total_g DESC
),
D19 AS (
    SELECT leagueid,MAX(total_g)
    FROM C19
    GROUP BY leagueid
),
E19 AS(
    SELECT D19.leagueid,team,total_g as teamtopscore
    FROM D19,C19
    WHERE total_g = max
    AND D19.leagueid = C19.leagueid
    ORDER BY leagueid
),
b15 AS (
    SELECT DISTINCT awayteamid,team
    FROM games,E19
    WHERE games.hometeamid = E19.team
),
c15 AS (
    SELECT DISTINCT hometeamid,E19.team
    FROM games,b15,E19
    WHERE b15.awayteamid = games.awayteamid
    AND b15.team = E19.team
    AND hometeamid != E19.team
),
temp AS (
    SELECT DISTINCT gameid, leagueid, c15.team
    FROM games,c15,b15
    WHERE games.hometeamid = c15.hometeamid
    AND games.awayteamid = b15.awayteamid
    AND c15.team = b15.team
    AND year = 2019
),
d15 AS (
    SELECT temp.leagueid,playerid,team, SUM(goals)
    FROM appearances,temp
    WHERE appearances.gameid = temp.gameid
    GROUP BY temp.leagueid,playerid,team
),
e15 AS (
    SELECT leagueid,MAX(sum)
    FROM d15
    GROUP BY leagueid
)
SELECT leagues.name as leaguename,players.name as playernames, sum as playertopscore,teams.name as teamname,E19.teamtopscore
FROM players,d15,e15,E19,leagues,teams
WHERE d15.sum = e15.max
AND d15.leagueid = e15.leagueid
AND e15.leagueid = leagues.leagueid
AND players.playerid = d15.playerid
AND d15.team = E19.team
AND E19.team = teams.teamid
ORDER BY playertopscore DESC, teamtopscore DESC, playernames;


--20--
WITH RECURSIVE path(teamA, teamB, game_path, count) as (
    select hometeamid, awayteamid, array[hometeamid, awayteamid], 1
    from games
    where hometeamid = (SELECT teamid 
    FROM teams
    WHERE name = 'Manchester United')

    union

    select path.teamA, games.awayteamid, game_path || games.awayteamid, count + 1
    from games, path
    where path.teamB = games.hometeamid
    and (not (games.awayteamid = ANY(game_path)))
    and games.hometeamid != (SELECT teamid
    FROM teams
    WHERE name = 'Manchester City')
    --and count < 4
)
SELECT MAX(count) as count
FROM path
WHERE path.teamB = (SELECT teamid
    FROM teams
    WHERE name = 'Manchester City');


--21--
WITH RECURSIVE path(teamA, teamB, game_path, count) as (
    select hometeamid, awayteamid, array[hometeamid, awayteamid], 1
    from games
    where hometeamid = (SELECT teamid 
    FROM teams
    WHERE name = 'Manchester United')

    union

    select path.teamA, games.awayteamid, game_path || games.awayteamid, count + 1
    from games, path
    where path.teamB = games.hometeamid
    and (not (games.awayteamid = ANY(game_path)))
    and games.hometeamid != (SELECT teamid
    FROM teams
    WHERE name = 'Manchester City')
    -- AND count < 4
)
SELECT count(*)
FROM path
WHERE path.teamB = (SELECT teamid
    FROM teams
    WHERE name = 'Manchester City');


--22--
WITH RECURSIVE path(teamA, teamB, game_path, leagueid, count) as (
    select hometeamid, awayteamid, array[hometeamid, awayteamid], leagueid, 1
    from games

    union all

    select path.teamA, games.awayteamid, game_path || games.awayteamid, games.leagueid, count + 1
    from games, path
    where path.teamB = games.hometeamid
    and games.leagueid = path.leagueid
    and (not (games.awayteamid = ANY(game_path)))
    --and count < 2
),
A22 as (
    SELECT leagueid,MAX(count)
    FROM path
    GROUP BY leagueid
),
B22 as (
    SELECT DISTINCT teamA,teamB, A22.leagueid, A22.max as count
    FROM path,A22
    WHERE path.count = max
    AND path.leagueid = A22.leagueid
)
SELECT DISTINCT leagues.name as leaguename, t1.name as teamAname, t2.name as teamBname, count
FROM leagues, teams as t1,teams as t2, B22
WHERE B22.teamA = t1.teamid
AND B22.teamB = t2.teamid
AND B22.leagueid = leagues.leagueid
ORDER by count DESC, teamAname, teamBname;


