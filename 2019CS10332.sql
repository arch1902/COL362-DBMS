--1--
WITH a AS (
SELECT circuitId 
FROM circuits 
WHERE country = 'Monaco'),

b AS (
SELECT raceid
FROM races,a
WHERE year=2017 
AND races.circuitid = a.circuitid),

c AS (
SELECT laptimes.raceid,laptimes.driverid,laptimes.milliseconds
FROM b
INNER JOIN laptimes ON laptimes.raceid = b.raceid),

d AS (
SELECT MAX(milliseconds) as time
FROM c),

e AS (
SELECT c.driverid,d.time
FROM c
INNER JOIN d
ON c.milliseconds = d.time)

SELECT drivers.driverid,drivers.forename,drivers.surname,drivers.nationality,e.time
FROM drivers,e
WHERE e.driverid = drivers.driverid
ORDER BY drivers.forename, drivers.surname, drivers.nationality;

--2--
WITH a2 AS (
SELECT raceid
FROM races
WHERE year=2012),

b2 AS (
SELECT constructors.constructorid,name,nationality,constructorresults.raceid,constructorresults.points
FROM constructors
INNER JOIN constructorresults ON constructors.constructorid=constructorresults.constructorid),

c2 AS (
SELECT constructorid,name,nationality,points
FROM b2
INNER JOIN a2 ON a2.raceid=b2.raceid),

d2 AS (
SELECT constructorid,SUM(points) 
FROM c2
GROUP BY constructorid
ORDER BY SUM(points) DESC),

e2 AS (
SELECT DISTINCT name as constructor_name, c2.constructorid,c2.nationality,d2.sum AS points
FROM c2
INNER JOIN d2 ON c2.constructorid = d2.constructorid
ORDER BY points DESC,name,nationality,constructorid)

SELECT * 
FROM e2
LIMIT 5;

--3--
WITH a3 AS (
SELECT raceid
FROM races
WHERE year>2000 AND year<2021),

b3 AS (
SELECT driverid,results.points
FROM results
INNER JOIN a3 ON a3.raceid = results.raceid),

c3 AS (
SELECT driverid,SUM(points)
FROM b3
GROUP BY driverid
ORDER BY SUM(points) DESC
LIMIT 1)

SELECT DISTINCT drivers.driverid,drivers.forename,drivers.surname,c3.sum AS points
FROM c3
INNER JOIN drivers ON drivers.driverid = c3.driverid;

--4--
WITH a4 AS (
SELECT raceid
FROM races
WHERE year>2009 AND year<2021),

b4 AS (
SELECT constructorid,constructorresults.points
FROM constructorresults
INNER JOIN a4 ON a4.raceid = constructorresults.raceid),

c4 AS (
SELECT constructorid,SUM(points)
FROM b4
GROUP BY constructorid
ORDER BY SUM(points) DESC
LIMIT 1)

SELECT DISTINCT constructors.constructorid,constructors.name,constructors.nationality,c4.sum AS points
FROM c4
INNER JOIN constructors ON constructors.constructorid = c4.constructorid;

--5--
WITH a5 AS (
SELECT driverid, raceid, positionOrder
FROM results
WHERE positionOrder=1),

b5 AS (
SELECT driverid,SUM(positionOrder)
FROM a5
GROUP BY driverid
ORDER BY SUM(positionOrder) DESC
LIMIT 1)

SELECT drivers.driverid,forename,surname,b5.sum as race_wins
FROM drivers
INNER JOIN b5 ON drivers.driverid=b5.driverid;

--6--
WITH a6 AS (
SELECT constructorid, raceid, positionOrder
FROM results
WHERE positionOrder=1),

b6 AS (
SELECT constructorid,SUM(positionOrder)
FROM a6
GROUP BY constructorid
ORDER BY SUM(positionOrder) DESC
LIMIT 1)

SELECT constructors.constructorid,name,b6.sum as num_wins
FROM constructors
INNER JOIN b6 ON constructors.constructorid=b6.constructorid;


--7--


--8--
WITH a8 AS (
SELECT driverid, raceid, positionOrder
FROM results
WHERE positionOrder=1),

b8 AS (
SELECT driverid, races.raceid, circuitid
FROM a8
INNER JOIN races ON races.raceid = a8.raceid),

c8 AS (
SELECT DISTINCT driverid, circuits.country
FROM b8
INNER JOIN circuits ON b8.circuitid = circuits.circuitid),

d8 AS (
SELECT driverid,COUNT(driverid)
FROM c8
GROUP BY driverid
ORDER BY COUNT(driverid) DESC
LIMIT 1)

SELECT d8.driverid,forename,surname,d8.count as num_countries 
FROM d8
INNER JOIN drivers ON drivers.driverid=d8.driverid;

--9--
WITH A9 AS (
    SELECT results.driverid,results.raceid,position,positionOrder
    FROM qualifying, results
    WHERE position=1
    and results.driverid=qualifying.driverid
    and positionOrder=1
    and results.raceid = qualifying.raceid
)
SELECT A9.driverid,forename,surname,COUNT(A9.driverid) as num_wins
FROM A9, drivers
WHERE A9.driverid = drivers.driverid
GROUP BY A9.driverid,forename,surname
ORDER BY COUNT(raceid) DESC
LIMIT 3;

--10--
WITH A10 AS (
    SELECT results.driverid,results.raceid
    FROM pitstops,results
    WHERE positionOrder=1
    AND results.driverid=pitstops.driverid
    AND results.raceid=pitstops.raceid
),
B10 AS (
SELECT A10.raceid,COUNT(A10.driverid) AS num_stops,A10.driverid ,forename,surname,races.circuitid,circuits.name
FROM A10, drivers, races, circuits
WHERE A10.driverid=drivers.driverid
AND A10.raceid = races.raceid
AND races.circuitid = circuits.circuitid
GROUP BY A10.raceid,A10.driverid,forename,surname,races.circuitid,circuits.name
ORDER BY num_stops DESC
),
C10 AS (
    SELECT * 
    FROM B10 
    LIMIT 1
)
SELECT B10.raceid,B10.num_stops,B10.driverid ,B10.forename,B10.surname,B10.circuitid,B10.name
FROM B10
INNER JOIN C10 ON B10.num_stops = C10.num_stops;

--11--
WITH a11 AS (
    SELECT *
    FROM status
    WHERE status='Collision'
),
b11 AS (
    SELECT raceid
    FROM results
    INNER JOIN a11 ON results.statusid=a11.statusid
),
c11 AS (
    SELECT raceid,COUNT(raceid)
    FROM b11
    GROUP BY raceid
    ORDER BY COUNT(raceid) DESC
    LIMIT 1
),
d11 AS (
    SELECT raceid,location,circuits.name
    FROM circuits
    INNER JOIN races ON races.circuitid=circuits.circuitid
)

SELECT d11.raceid, name, location, c11.count AS num_collisions
FROM d11
INNER JOIN c11 ON d11.raceid=c11.raceid;

--12--
WITH a12 AS (
    SELECT driverid
    FROM results
    WHERE positionOrder=1 AND rank=1
),
b12 AS (
    SELECT driverid,COUNT(driverid)
    FROM a12
    GROUP BY driverid
    ORDER BY COUNT(driverid) DESC
)

SELECT b12.driverid, forename, surname, count
FROM b12
INNER JOIN drivers ON drivers.driverid=b12.driverid
ORDER BY count DESC
LIMIT 1;

--13--
WITH A13 AS (
    SELECT constructorid,year,SUM(points) as score
    FROM results,races
    WHERE results.raceid=races.raceid
    GROUP BY constructorid,year
    ORDER BY year,score DESC
),
B13 AS (
    SELECT year,MAX(A13.score) as score
    FROM A13
    GROUP BY year
    ORDER BY year 
),
C13 AS (
    SELECT DISTINCT A13.constructorid,name as constructor1_name,B13.year,B13.score
    FROM A13,B13,constructors
    WHERE A13.score=B13.score 
    AND A13.year=B13.year
    AND constructors.constructorid = A13.constructorid
    ORDER BY year
),
D13 AS (
    SELECT constructorid,year,score
    FROM A13
    EXCEPT
    SELECT constructorid,year,score
    FROM C13
    ORDER BY year, score DESC
),
E13 AS (
    SELECT year,MAX(D13.score) as score
    FROM D13
    GROUP BY year
    ORDER BY year     
),
F13 AS (
    SELECT DISTINCT D13.constructorid,name as constructor2_name,D13.year,D13.score
    FROM D13,E13,constructors
    WHERE D13.score=E13.score 
    AND constructors.constructorid = D13.constructorid
    AND D13.year=E13.year
    ORDER BY year
)
SELECT C13.year,(C13.score-F13.score) as points_diff,C13.constructorid as constructor1_id,constructor1_name,F13.constructorid as constructor2_id,constructor2_name
FROM C13,F13
WHERE C13.year = F13.year
ORDER BY points_diff DESC 
LIMIT 1;

--14--
WITH a14 AS (
    SELECT raceid,circuitid
    FROM races
    WHERE year=2018
),
b14 AS (
    SELECT driverid,A14.raceid,grid
    FROM results
    INNER JOIN a14 ON results.raceid = a14.raceid
    WHERE positionOrder=1
),
c14 AS (
    SELECT raceid,a14.circuitid,country
    FROM a14
    INNER JOIN circuits ON a14.circuitid=circuits.circuitid
),
d14 AS (
    SELECT driverid,circuitid,country,grid
    FROM c14
    INNER JOIN b14 ON b14.raceid=c14.raceid
)

SELECT d14.driverid, forename, surname,circuitid,country,grid as pos
FROM d14
INNER JOIN drivers ON drivers.driverid=d14.driverid
ORDER BY grid DESC
LIMIT 1;

--15--
WITH a15 AS (
    SELECT raceid
    FROM races
    WHERE year>=2000
),
b15 AS (
    SELECT constructorid
    FROM results
    INNER JOIN a15 ON results.raceid = a15.raceid
    WHERE statusid=5
),
c15 AS (
    SELECT b15.constructorid,name
    FROM constructors
    INNER JOIN b15 ON b15.constructorid=constructors.constructorid
)

SELECT constructorid,name, COUNT(constructorid) as num
FROM c15
GROUP BY constructorid,name
ORDER BY num DESC
LIMIT 1;

--16--
WITH a16 AS (
    SELECT DISTINCT driverid, raceid
    FROM results
    WHERE positionOrder=1
),
b16 AS (
    SELECT DISTINCT drivers.driverid,forename,surname, raceid
    FROM drivers
    INNER JOIN a16 ON drivers.driverid = a16.driverid
    WHERE nationality='American'
),
c16 AS (
    SELECT DISTINCT driverid,forename,surname,circuitid
    FROM races
    INNER JOIN b16 ON b16.raceid=races.raceid
)

SELECT driverid,forename,surname
FROM circuits
INNER JOIN c16 ON circuits.circuitid=c16.circuitid
WHERE country='USA'
ORDER BY forename,surname,driverid
LIMIT 5;

--17--
WITH A17 AS (
    SELECT constructorid,results.raceid,COUNT(results.raceid) as num
    FROM results,races
    WHERE positionOrder < 3 
    AND year>2013
    AND results.raceid=races.raceid
    GROUP BY constructorid,results.raceid
),
B17 AS (
    SELECT constructorid,COUNT(raceid) as count
    FROM A17
    WHERE num>1
    GROUP BY constructorid
),
C17 AS (
    SELECT MAX(count) AS mx
    FROM B17
)

SELECT constructors.constructorid,name,count
FROM B17,C17,constructors
WHERE C17.mx = B17.count
AND constructors.constructorid = B17.constructorid
ORDER BY name,constructorid

--18--
WITH A18 AS (
    SELECT driverid,COUNT(position)
    FROM laptimes
    WHERE position = 1
    GROUP BY driverid
    ORDER BY count DESC
),
B18 AS (
    SELECT MAX(count)
    FROM A18
)
SELECT drivers.driverid,forename,surname,B18.max AS num_laps
FROM A18,B18,drivers
WHERE A18.count = B18.max
AND A18.driverid = drivers.driverid; 

--19--
WITH A19 as (
    SELECT driverid,COUNT(driverid) as count
    FROM results 
    WHERE positionOrder<4
    GROUP BY driverid
),
B19 AS (
    SELECT MAX(count) as mx
    FROM A19
)
SELECT A19.driverid,forename,surname,mx as count
FROM A19,B19,drivers    
WHERE A19.count = B19.mx
AND A19.driverid = drivers.driverid;

--20--
WITH A20 AS (
    SELECT driverid,year,SUM(points)
    FROM results,races
    WHERE results.raceid=races.raceid
    GROUP BY driverid,year
),
B20 AS (
    SELECT year,MAX(A20.sum)
    FROM A20
    GROUP BY year
),
C20 AS (
    SELECT driverid,COUNT(driverid) AS num_champs
    FROM A20,B20
    WHERE A20.year=B20.year 
    AND A20.sum = B20.max
    GROUP BY driverid
)
SELECT C20.driverid,forename,surname,num_champs
FROM drivers,C20
WHERE C20.driverid = drivers.driverid
ORDER BY num_champs DESC, forename,surname,driverid
LIMIT 5;
