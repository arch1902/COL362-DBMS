--1--
WITH a AS (
    SELECT circuitId 
    FROM circuits 
    WHERE country = 'Monaco'
),
b AS (
    SELECT raceid
    FROM races,a
    WHERE year=2017 
    AND races.circuitid = a.circuitid
),
c AS (
    SELECT laptimes.raceid,laptimes.driverid,laptimes.milliseconds
    FROM b
    INNER JOIN laptimes ON laptimes.raceid = b.raceid
),
d AS (
    SELECT MAX(milliseconds) as time
    FROM c
),
e AS (
    SELECT c.driverid,d.time
    FROM c
    INNER JOIN d
    ON c.milliseconds = d.time
)
SELECT drivers.driverid,drivers.forename,drivers.surname,drivers.nationality,e.time
FROM drivers,e
WHERE e.driverid = drivers.driverid
ORDER BY drivers.forename, drivers.surname, drivers.nationality;


--2--
WITH a2 AS (
    SELECT raceid
    FROM races
    WHERE year=2012
),
b2 AS (
    SELECT constructors.constructorid,name,nationality,constructorresults.raceid,constructorresults.points
    FROM constructors
    INNER JOIN constructorresults ON constructors.constructorid=constructorresults.constructorid
),
c2 AS (
    SELECT constructorid,name,nationality,points
    FROM b2
    INNER JOIN a2 ON a2.raceid=b2.raceid
),
d2 AS (
    SELECT constructorid,SUM(points) 
    FROM c2
    GROUP BY constructorid
    ORDER BY SUM(points) DESC
),
e2 AS (
    SELECT DISTINCT name as constructor_name, c2.constructorid,c2.nationality,d2.sum AS points
    FROM c2
    INNER JOIN d2 ON c2.constructorid = d2.constructorid
    ORDER BY points DESC,name,nationality,constructorid
)
SELECT * 
FROM e2
LIMIT 5;


--3--
WITH a3 AS (
    SELECT raceid
    FROM races
    WHERE year>2000 AND year<2021
),
b3 AS (
    SELECT driverid,results.points
    FROM results
    INNER JOIN a3 ON a3.raceid = results.raceid
),
c3 AS (
    SELECT driverid,SUM(points)
    FROM b3
    GROUP BY driverid
),
d3 AS (
    SELECT MAX(sum)
    FROM c3
),
e3 AS (
    SELECT driverid,sum
    FROM c3,d3
    WHERE max=sum
)
SELECT DISTINCT drivers.driverid,drivers.forename,drivers.surname,e3.sum AS points
FROM e3
INNER JOIN drivers ON drivers.driverid = e3.driverid
ORDER BY drivers.forename,drivers.surname,drivers.driverid;


--4--
WITH a4 AS (
    SELECT raceid
    FROM races
    WHERE year>2009 AND year<2021
),
b4 AS (
    SELECT constructorid,constructorresults.points
    FROM constructorresults
    INNER JOIN a4 ON a4.raceid = constructorresults.raceid
),
c4 AS (
    SELECT constructorid,SUM(points)
    FROM b4
    GROUP BY constructorid
),
d4 AS (
    SELECT MAX(sum)
    FROM c4
),
e4 AS (
    SELECT constructorid,sum
    FROM c4,d4
    WHERE max = sum
)
SELECT DISTINCT constructors.constructorid,constructors.name,constructors.nationality,e4.sum AS points
FROM e4
INNER JOIN constructors ON constructors.constructorid = e4.constructorid
ORDER BY constructors.name,constructors.nationality,constructors.constructorid;


--5--
WITH a5 AS (
    SELECT driverid, raceid, positionOrder
    FROM results
    WHERE positionOrder=1
),
b5 AS (
    SELECT driverid,SUM(positionOrder)
    FROM a5
    GROUP BY driverid
),
c5 AS (
    SELECT MAX(sum)
    FROM b5
),
d5 AS (
    SELECT driverid,sum
    FROM b5,c5
    WHERE sum = max
)
SELECT drivers.driverid,forename,surname,d5.sum as race_wins
FROM drivers
INNER JOIN d5 ON drivers.driverid=d5.driverid
ORDER BY forename,surname,drivers.driverid;


--6--
WITH a6 AS (
    SELECT DISTINCT constructorid, raceid, SUM(points)
    FROM constructorresults
    GROUP BY constructorid,raceid
),
y6 AS (
    SELECT DISTINCT raceid,MAX(sum)
    FROM a6
    GROUP BY raceid
),
x6 AS (
    SELECT DISTINCT constructorid, a6.raceid, sum
    FROM a6,y6
    WHERE max = sum
    AND a6.raceid = y6.raceid
),
b6 AS (
    SELECT constructorid,COUNT(raceid)
    FROM x6
    GROUP BY constructorid
),
c6 AS (
    SELECT MAX(count)
    FROM b6
),
d6 AS (
    SELECT constructorid, count
    FROM b6,c6
    WHERE count = max
)
SELECT constructors.constructorid,name,d6.count as num_wins
FROM constructors
INNER JOIN d6 ON constructors.constructorid=d6.constructorid
ORDER BY name,constructors.constructorid;


--7--
WITH A7 AS (
    SELECT driverid,year,SUM(points)
    FROM results,races
    WHERE results.raceid=races.raceid
    GROUP BY driverid,year 
),
B7 AS (
    SELECT year,MAX(A7.sum)
    FROM A7
    GROUP BY year
),
C7 AS (
    SELECT driverid,sum
    FROM A7,B7
    WHERE sum=max
    AND A7.year=B7.year

),
D7 AS (
    SELECT DISTINCT driverid
    FROM C7
),
E7 AS (
    SELECT driverid,SUM(points)
    FROM results
    GROUP BY driverid
),
F7 AS (
    SELECT E7.driverid,E7.sum
    FROM E7,D7
    WHERE D7.driverid = E7.driverid
),
G7 AS (
    SELECT driverid,sum
    FROM E7
    EXCEPT
    SELECT driverid,sum
    FROM F7
    ORDER BY sum DESC
    LIMIT 3
)
SELECT G7.driverid,forename,surname,sum AS points
FROM G7,drivers
WHERE G7.driverid = drivers.driverid
ORDER BY points DESC, forename, surname, G7.driverid;


--8--
WITH a8 AS (
    SELECT driverid, raceid, positionOrder
    FROM results
    WHERE positionOrder=1
),
b8 AS (
    SELECT driverid, races.raceid, circuitid
    FROM a8
    INNER JOIN races ON races.raceid = a8.raceid
),
c8 AS (
    SELECT DISTINCT driverid, circuits.country
    FROM b8
    INNER JOIN circuits ON b8.circuitid = circuits.circuitid
),
d8 AS (
    SELECT driverid,COUNT(driverid)
    FROM c8
    GROUP BY driverid
),
e8 AS (
    SELECT MAX(count)
    FROM d8
),
f8 AS (
    SELECT driverid,count
    FROM d8,e8
    WHERE count=max
)
SELECT f8.driverid,forename,surname,f8.count as num_countries 
FROM f8
INNER JOIN drivers ON drivers.driverid=f8.driverid
ORDER BY forename,surname,f8.driverid;


--9--
WITH A9 AS (
    SELECT results.driverid,results.raceid,positionOrder
    FROM results
    WHERE grid=1
    and positionOrder=1
)
SELECT A9.driverid,forename,surname,COUNT(raceid) as num_wins
FROM A9, drivers
WHERE A9.driverid = drivers.driverid
GROUP BY A9.driverid,forename,surname
ORDER BY COUNT(raceid) DESC, forename, surname, A9.driverid
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
),
X10 AS (
    SELECT MAX(num_stops)
    FROM B10
),
C10 AS (
    SELECT raceid,num_stops,driverid ,forename,surname,circuitid,name
    FROM B10,X10 
    WHERE num_stops=max
)
SELECT B10.raceid,B10.num_stops,B10.driverid ,B10.forename,B10.surname,B10.circuitid,B10.name
FROM B10
INNER JOIN C10 ON B10.num_stops = C10.num_stops
ORDER BY B10.forename,B10.surname,B10.name,B10.circuitid,B10.driverid;


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
x11 AS (
    SELECT raceid,COUNT(raceid)
    FROM b11
    GROUP BY raceid
),
y11 AS (
    SELECT MAX(count)
    FROM x11
),
c11 AS (
    SELECT raceid,count
    FROM x11,y11
    WHERE max=count
),
d11 AS (
    SELECT raceid,location,circuits.name
    FROM circuits
    INNER JOIN races ON races.circuitid=circuits.circuitid
)

SELECT d11.raceid, name, location, c11.count AS num_collisions
FROM d11
INNER JOIN c11 ON d11.raceid=c11.raceid
ORDER BY name,location,d11.raceid;


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
),
c12 AS (
    SELECT b12.driverid, forename, surname, count
    FROM b12
    INNER JOIN drivers ON drivers.driverid=b12.driverid
),
d12 AS (
    SELECT max(count)
    FROM c12
)
SELECT driverid, forename, surname, count
FROM c12,d12
WHERE count = max
ORDER BY forename,surname,driverid;


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
),
G13  AS (
    SELECT C13.year,(C13.score-F13.score) as point_diff,C13.constructorid as constructor1_id,constructor1_name,F13.constructorid as constructor2_id,constructor2_name
    FROM C13,F13
    WHERE C13.year = F13.year
    ORDER BY point_diff DESC
),
H13 AS (
    SELECT max(point_diff)
    FROM G13
)
SELECT year,point_diff,constructor1_id,constructor1_name,constructor2_id,constructor2_name
FROM G13,H13
WHERE point_diff=max
ORDER BY constructor1_name,constructor2_name,constructor1_id,constructor2_id;


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
),
e14 AS (
    SELECT d14.driverid, forename, surname,circuitid,country,grid as pos
    FROM d14
    INNER JOIN drivers ON drivers.driverid=d14.driverid
),
f14 AS (
    SELECT MAX(pos) 
    FROM e14
)
SELECT driverid, forename, surname,circuitid,country,pos
FROM e14,f14
WHERE max = pos
ORDER BY forename DESC, surname,country,driverid,circuitid;


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
),
d15 AS (
    SELECT constructorid,name, COUNT(constructorid) as num
    FROM c15
    GROUP BY constructorid,name
    ORDER BY num DESC
),
e15 AS (
    SELECT max(num)
    FROM d15
)
SELECT constructorid,name,num
FROM d15,e15
WHERE num = max
ORDER BY name,constructorid;


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
ORDER BY name,constructorid;


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
AND A18.driverid = drivers.driverid
ORDER BY forename, surname, driverid; 


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
AND A19.driverid = drivers.driverid
ORDER BY forename,surname DESC,driverid;


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
ORDER BY num_champs DESC, forename,surname DESC,driverid
LIMIT 5;

