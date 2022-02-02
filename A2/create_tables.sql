CREATE TABLE  IF NOT EXISTS teams (
    teamid bigint NOT NULL,
    name text,
    CONSTRAINT team_key PRIMARY KEY (teamid)
);

CREATE table IF NOT EXISTS games(
    gameid bigint NOT NULL,
    leagueid bigint,
    hometeamid bigint,
    awayteamid  bigint,
    year bigint,
    homegoals bigint,
    awaygoals bigint,
    CONSTRAINT game_key PRIMARY KEY (gameid)
);

CREATE TABLE  IF NOT EXISTS appearances (
    gameid bigint NOT NULL,
    playerid bigint,
    leagueid bigint,
    goals  bigint,
    owngoals bigint,
    assists bigint,
    keypasses bigint,
    shots bigint
);

CREATE TABLE  IF NOT EXISTS leagues (
    leagueid bigint NOT NULL,
    name text,
    CONSTRAINT league_key PRIMARY KEY (leagueid)
);

CREATE TABLE  IF NOT EXISTS players (
    playerid bigint NOT NULL,
    name text,
    CONSTRAINT player_key PRIMARY KEY (playerid)
);

-- CREATE TABLE  IF NOT EXISTS train_info (
--     train_no bigint NOT NULL,
--     train_name text,
--     distance bigint,
--     source_station_name text,
--     departure_time time(7),
--     day_of_departure text,
--     destination_station_name text,
--     arrival_time time(7),
--     day_of_arrival text,
--     CONSTRAINT train_key PRIMARY KEY (train_no)
-- );



