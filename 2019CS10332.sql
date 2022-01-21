--1--
-- CREATE OR REPLACE VIEW a AS
-- SELECT circuitId 
-- FROM circuits 
-- WHERE country = 'Monaco';

-- CREATE OR REPLACE VIEW b AS
-- SELECT raceid
-- FROM races,a
-- WHERE year=2017 
-- AND races.circuitid = a.circuitid;

-- CREATE OR REPLACE VIEW c AS
-- SELECT laptimes.raceid,laptimes.driverid,laptimes.milliseconds
-- FROM b
-- INNER JOIN laptimes ON laptimes.raceid = b.raceid;

-- CREATE OR REPLACE VIEW d AS
-- SELECT MAX(milliseconds) as time
-- FROM c;

-- CREATE OR REPLACE VIEW e AS
-- SELECT c.driverid,d.time
-- FROM c
-- INNER JOIN d
-- ON c.milliseconds = d.time;

-- -- CREATE OR REPLACE VIEW final_1 AS 
-- SELECT drivers.driverid,drivers.forename,drivers.surname,drivers.nationality,e.time
-- FROM drivers,e
-- WHERE e.driverid = drivers.driverid
-- ORDER BY drivers.forename, drivers.surname, drivers.nationality;

--2--
-- CREATE OR REPLACE VIEW a2 AS
-- SELECT raceid
-- FROM races
-- WHERE year=2012;

-- CREATE OR REPLACE VIEW b2 AS
-- SELECT constructors.constructorid,name,nationality,constructorresults.raceid,constructorresults.points
-- FROM constructors
-- INNER JOIN constructorresults ON constructors.constructorid=constructorresults.constructorid;

-- CREATE OR REPLACE VIEW c2 AS
-- SELECT constructorid,name,nationality,points
-- FROM b2
-- INNER JOIN a2 ON a2.raceid=b2.raceid;

-- CREATE OR REPLACE VIEW d2 AS
-- SELECT constructorid,SUM(points) 
-- FROM c2
-- GROUP BY constructorid
-- ORDER BY SUM(points) DESC;

-- CREATE OR REPLACE VIEW e2 AS
-- SELECT DISTINCT name as constructor_name, c2.constructorid,c2.nationality,d2.sum AS points
-- FROM c2
-- INNER JOIN d2 ON c2.constructorid = d2.constructorid
-- ORDER BY points DESC,name,nationality,constructorid;

-- -- CREATE OR REPLACE VIEW final_2 AS
-- SELECT * 
-- FROM e2
-- LIMIT 5;

--3--
-- CREATE OR REPLACE VIEW a3 AS
-- SELECT raceid
-- FROM races
-- WHERE year>2000 AND year<2021;

-- CREATE OR REPLACE VIEW b3 AS
-- SELECT driverid,results.points
-- FROM results
-- INNER JOIN a3 ON a3.raceid = results.raceid;

-- CREATE OR REPLACE VIEW c3 AS
-- SELECT driverid,SUM(points)
-- FROM b3
-- GROUP BY driverid
-- ORDER BY SUM(points) DESC
-- LIMIT 1;

-- -- CREATE OR REPLACE VIEW final_3 AS
-- SELECT DISTINCT drivers.driverid,drivers.forename,drivers.surname,c3.sum AS points
-- FROM c3
-- INNER JOIN drivers ON drivers.driverid = c3.driverid;

--4--
-- CREATE OR REPLACE VIEW a4 AS
-- SELECT raceid
-- FROM races
-- WHERE year>2009 AND year<2021;

-- CREATE OR REPLACE VIEW b4 AS
-- SELECT constructorid,constructorresults.points
-- FROM constructorresults
-- INNER JOIN a4 ON a4.raceid = constructorresults.raceid;

-- CREATE OR REPLACE VIEW c4 AS
-- SELECT constructorid,SUM(points)
-- FROM b4
-- GROUP BY constructorid
-- ORDER BY SUM(points) DESC
-- LIMIT 1;

-- -- CREATE OR REPLACE VIEW final_3 AS
-- SELECT DISTINCT constructors.constructorid,constructors.name,constructors.nationality,c4.sum AS points
-- FROM c4
-- INNER JOIN constructors ON constructors.constructorid = c4.constructorid;

--5--
-- CREATE OR REPLACE VIEW a5 AS
-- SELECT driverid, raceid, positionOrder
-- FROM results
-- WHERE positionOrder=1;

-- CREATE OR REPLACE VIEW b5 AS
-- SELECT driverid,SUM(positionOrder)
-- FROM a5
-- GROUP BY driverid
-- ORDER BY SUM(positionOrder) DESC
-- LIMIT 1;

-- -- CREATE OR REPLACE VIEW b5 AS
-- SELECT drivers.driverid,forename,surname,b5.sum as race_wins
-- FROM drivers
-- INNER JOIN b5 ON drivers.driverid=b5.driverid;

--6--
-- CREATE OR REPLACE VIEW a6 AS
-- SELECT constructorid, raceid, positionOrder
-- FROM results
-- WHERE positionOrder=1;

-- CREATE OR REPLACE VIEW b6 AS
-- SELECT constructorid,SUM(positionOrder)
-- FROM a6
-- GROUP BY constructorid
-- ORDER BY SUM(positionOrder) DESC
-- LIMIT 1;

-- -- CREATE OR REPLACE VIEW b6 AS
-- SELECT constructors.constructorid,name,b6.sum as num_wins
-- FROM constructors
-- INNER JOIN b6 ON constructors.constructorid=b6.constructorid;


--7--



--8--
-- CREATE OR REPLACE VIEW a8 AS
-- SELECT driverid, raceid, positionOrder
-- FROM results
-- WHERE positionOrder=1;

-- CREATE OR REPLACE VIEW b8 AS
-- SELECT driverid, races.raceid, circuitid
-- FROM a8
-- INNER JOIN races ON races.raceid = a8.raceid;

-- CREATE OR REPLACE VIEW c8 AS
-- SELECT DISTINCT driverid, circuits.country
-- FROM b8
-- INNER JOIN circuits ON b8.circuitid = circuits.circuitid;

-- CREATE OR REPLACE VIEW d8 AS
-- SELECT driverid,COUNT(driverid)
-- FROM c8
-- GROUP BY driverid
-- ORDER BY COUNT(driverid) DESC
-- LIMIT 1;

-- -- CREATE OR REPLACE VIEW e8 AS
-- SELECT d8.driverid,forename,surname,d8.count as num_countries 
-- FROM d8
-- INNER JOIN drivers ON drivers.driverid=d8.driverid;



--9--


--10--


--11--


--12--


--13--


--14--


--15--


--16--


--17--


--18--


--19--


--20--

