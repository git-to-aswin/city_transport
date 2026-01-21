-- Seed ref.rail_route_stations for a subset of routes using existing ref.stations rows
-- Uses MIN(id) per station_name to avoid duplicates from overlap stations (e.g., Sunshine).
-- Source station ids/names are from your exported ref.stations query output.  [oai_citation:1‡stations_202601201351.json](sediment://file_00000000d55c7206942bc26c51895f3b)

WITH
r AS (
  SELECT route_id::int AS route_id, route_name
  FROM ref.rail_routes
),
s AS (
  SELECT station_name, MIN(id)::smallint AS station_id
  FROM ref.stations
  GROUP BY station_name
),
seed(route_name, station_name, stop_sequence) AS (
  VALUES
    -------------------------------------------------------------------------
    -- Ballarat Line (subset)
    -------------------------------------------------------------------------
    ('Ballarat Line', 'Southern Cross',     1),
    ('Ballarat Line', 'Footscray',          2),
    ('Ballarat Line', 'Sunshine',           3),
    ('Ballarat Line', 'Deer Park',          4),
    ('Ballarat Line', 'Ardeer',             5),
    ('Ballarat Line', 'Caroline Springs',   6),
    ('Ballarat Line', 'Rockbank',           7),
    ('Ballarat Line', 'Melton',             8),
    ('Ballarat Line', 'Cobblebank',         9),
    ('Ballarat Line', 'Bacchus Marsh',     10),
    ('Ballarat Line', 'Ballan',            11),
    ('Ballarat Line', 'Ballarat',          12),
    ('Ballarat Line', 'Wendouree',         13),
    -------------------------------------------------------------------------
    -- Bendigo Line (subset)
    -------------------------------------------------------------------------
    ('Bendigo Line', 'Southern Cross',      1),
    ('Bendigo Line', 'Footscray',           2),
    ('Bendigo Line', 'Sunshine',            3),
    ('Bendigo Line', 'Sunbury',             4),
    ('Bendigo Line', 'Clarkefield',         5),
    ('Bendigo Line', 'Riddells Creek',      6),
    ('Bendigo Line', 'Gisborne',            7),
    ('Bendigo Line', 'Macedon',             8),
    ('Bendigo Line', 'Woodend',             9),
    ('Bendigo Line', 'Kyneton',            10),
    ('Bendigo Line', 'Malmsbury',          11),
    ('Bendigo Line', 'Castlemaine',        12),
    ('Bendigo Line', 'Kangaroo Flat',      13),
    ('Bendigo Line', 'Bendigo',            14),
    ('Bendigo Line', 'Epsom',              15),
    ('Bendigo Line', 'Eaglehawk',          16),
    ('Bendigo Line', 'Huntly',             17),
    ('Bendigo Line', 'Goornong',           18),
    ('Bendigo Line', 'Raywood',            19),
    -------------------------------------------------------------------------
    -- Geelong Line (subset via RRL corridor)
    -------------------------------------------------------------------------
    ('Geelong Line', 'Southern Cross',      1),
    ('Geelong Line', 'Footscray',           2),
    ('Geelong Line', 'Sunshine',            3),
    ('Geelong Line', 'Deer Park',           4),
    ('Geelong Line', 'Tarneit',             5),
    ('Geelong Line', 'Wyndham Vale',        6),
    ('Geelong Line', 'Little River',        7),
    ('Geelong Line', 'Lara',                8),
    ('Geelong Line', 'Corio',               9),
    ('Geelong Line', 'North Shore',        10),
    ('Geelong Line', 'North Geelong',      11),
    ('Geelong Line', 'Geelong',            12),
    ('Geelong Line', 'South Geelong',      13),
    ('Geelong Line', 'Marshall',           14),
    ('Geelong Line', 'Waurn Ponds',        15),
    -------------------------------------------------------------------------
    -- Gippsland Line (subset)
    -------------------------------------------------------------------------
    ('Gippsland Line', 'Southern Cross',     1),
    ('Gippsland Line', 'Richmond',           2),
    ('Gippsland Line', 'Caulfield',          3),
    ('Gippsland Line', 'Clayton',            4),
    ('Gippsland Line', 'Dandenong',          5),
    ('Gippsland Line', 'Berwick',            6),
    ('Gippsland Line', 'Pakenham',           7),
    ('Gippsland Line', 'Tynong',             8),
    ('Gippsland Line', 'Bunyip',             9),
    ('Gippsland Line', 'Longwarry',         10),
    ('Gippsland Line', 'Drouin',            11),
    ('Gippsland Line', 'Warragul',          12),
    ('Gippsland Line', 'Yarragon',          13),
    ('Gippsland Line', 'Trafalgar',         14),
    ('Gippsland Line', 'Moe',               15),
    ('Gippsland Line', 'Morwell',           16),
    ('Gippsland Line', 'Traralgon',         17),
    ('Gippsland Line', 'Sale',              18),
    ('Gippsland Line', 'Bairnsdale',        19),
    -------------------------------------------------------------------------
    -- Seymour Line (subset)
    -------------------------------------------------------------------------
    ('Seymour Line', 'Southern Cross',       1),
    ('Seymour Line', 'North Melbourne',      2),
    ('Seymour Line', 'Broadmeadows',         3),
    ('Seymour Line', 'Craigieburn',          4),
    ('Seymour Line', 'Donnybrook',           5),
    ('Seymour Line', 'Wallan',               6),
    ('Seymour Line', 'Wandong',              7),
    ('Seymour Line', 'Heathcote Junction',   8),
    ('Seymour Line', 'Kilmore East',         9),
    ('Seymour Line', 'Seymour',             10)
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT
  r.route_id,
  s.station_id,
  seed.stop_sequence
FROM seed
JOIN r ON r.route_name = seed.route_name
JOIN s ON s.station_name = seed.station_name
ON CONFLICT DO NOTHING;


INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at)
VALUES
  -- Zone 2
  (3001, 'Laburnum', 2, NOW(), NOW()),
  (3002, 'Blackburn', 2, NOW(), NOW()),
  (3003, 'Nunawading', 2, NOW(), NOW()),
  (3004, 'Mitcham', 2, NOW(), NOW()),
  (3005, 'Heatherdale', 2, NOW(), NOW()),
  (3006, 'Ringwood', 2, NOW(), NOW()),
  (3007, 'Heathmont', 2, NOW(), NOW()),
  (3008, 'Bayswater', 2, NOW(), NOW()),
  (3009, 'Boronia', 2, NOW(), NOW()),
  (3010, 'Ferntree Gully', 2, NOW(), NOW()),
  (3011, 'Upper Ferntree Gully', 2, NOW(), NOW()),
  (3012, 'Upwey', 2, NOW(), NOW()),
  (3013, 'Tecoma', 2, NOW(), NOW()),
  (3014, 'Belgrave', 2, NOW(), NOW()),
  (3015, 'Box Hill', 2, NOW(), NOW()),
  -- Zone 1 only
  (3016, 'East Camberwell', 1, NOW(), NOW()),
  -- Overlap Zone 1 + 2 (same station_id, two zone rows)
  (3017, 'Union', 1, NOW(), NOW()),
  (3017, 'Union', 2, NOW(), NOW()),
  (3018, 'Chatham', 1, NOW(), NOW()),
  (3018, 'Chatham', 2, NOW(), NOW()),
  (3019, 'Canterbury', 1, NOW(), NOW()),
  (3019, 'Canterbury', 2, NOW(), NOW())
ON CONFLICT (station_id, zone_id) DO UPDATE
SET station_name = EXCLUDED.station_name,
    updated_at   = NOW();

WITH seed(stop_sequence, station_name, route_id) AS (
  VALUES
    ( 1, 'Southern Cross',     2),
    ( 2, 'Flinders Street',    2),
    ( 3, 'Richmond',           2),
    ( 4, 'East Richmond',      2),
    ( 5, 'Burnley',            2),
    ( 6, 'Hawthorn',           2),
    ( 7, 'Glenferrie',         2),
    ( 8, 'Auburn',             2),
    ( 9, 'Camberwell',         2),
    (10, 'East Camberwell',    2),
    (11, 'Canterbury',         2),
    (12, 'Chatham',            2),
    (13, 'Union',              2),
    (14, 'Box Hill',           2),
    (15, 'Laburnum',           2),
    (16, 'Blackburn',          2),
    (17, 'Nunawading',         2),
    (18, 'Mitcham',            2),
    (19, 'Heatherdale',        2),
    (20, 'Ringwood',           2),
    (21, 'Heathmont',          2),
    (22, 'Bayswater',          2),
    (23, 'Boronia',            2),
    (24, 'Ferntree Gully',     2),
    (25, 'Upper Ferntree Gully',2),
    (26, 'Upwey',              2),
    (27, 'Tecoma',             2),
    (28, 'Belgrave',           2)
),
stcode AS (
  SELECT
    ss.route_id,
    MIN(s.id)::smallint AS station_id,  -- FK expects SMALLINT in your table
    ss.stop_sequence
  FROM seed ss
  JOIN ref.stations s
    ON s.station_name = ss.station_name
  GROUP BY ss.route_id, ss.stop_sequence
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id, station_id, stop_sequence
FROM stcode
ON CONFLICT DO NOTHING;

-- Craigieburn line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(4101,'Craigieburn',2,NOW(),NOW()),
(4102,'Roxburgh Park',2,NOW(),NOW()),
(4103,'Coolaroo',2,NOW(),NOW()),
(4104,'Broadmeadows',2,NOW(),NOW()),
(4105,'Jacana',2,NOW(),NOW()),
(4106,'Glenroy',1,NOW(),NOW()),
(4106,'Glenroy',2,NOW(),NOW()),
(4107,'Oak Park',1,NOW(),NOW()),
(4107,'Oak Park',2,NOW(),NOW()),
(4108,'Pascoe Vale',1,NOW(),NOW()),
(4108,'Pascoe Vale',2,NOW(),NOW()),
(4109,'Strathmore',1,NOW(),NOW()),
(4110,'Glenbervie',1,NOW(),NOW()),
(4111,'Essendon',1,NOW(),NOW()),
(4112,'Moonee Ponds',1,NOW(),NOW()),
(4113,'Ascot Vale',1,NOW(),NOW()),
(4114,'Newmarket',1,NOW(),NOW()),
(4115,'Kensington',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name, route_id) AS (
VALUES
( 1,'Southern Cross',3),
( 2,'Flinders Street',3),
( 3,'Parliament',3),
( 4,'Melbourne Central',3),
( 5,'Flagstaff',3),
( 6,'North Melbourne',3),
( 7,'Kensington',3),
( 8,'Newmarket',3),
( 9,'Ascot Vale',3),
(10,'Moonee Ponds',3),
(11,'Essendon',3),
(12,'Glenbervie',3),
(13,'Strathmore',3),
(14,'Pascoe Vale',3),
(15,'Oak Park',3),
(16,'Glenroy',3),
(17,'Jacana',3),
(18,'Broadmeadows',3),
(19,'Coolaroo',3),
(20,'Roxburgh Park',3),
(21,'Craigieburn',3)
),stcode AS (
SELECT ss.route_id,st.id::smallint AS station_id,ss.stop_sequence
FROM seed ss
JOIN LATERAL (
SELECT id FROM ref.stations
WHERE station_name = ss.station_name
ORDER BY zone_id ASC,id ASC
LIMIT 1
) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- Cranbourne Line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) SELECT v.station_id,v.station_name,v.zone_id,NOW(),NOW() FROM (VALUES
(4201,'Flagstaff',1),
(4202,'Melbourne Central',1),
(4203,'Parliament',1),
(4204,'South Yarra',1),
(4205,'Malvern',1),
(4206,'Glen Iris',1),
(4207,'Darling',1),
(4208,'East Malvern',1),
(4209,'Holmesglen',2),
(4210,'Jordanville',2),
(4211,'Mount Waverley',2),
(4212,'Glen Waverley',2),
(4213,'Hughesdale',1),
(4214,'Murrumbeena',1),
(4215,'Carnegie',1),
(4216,'North Road',1),
(4217,'Ormond',1),
(4218,'McKinnon',1),
(4219,'Bentleigh',1),
(4220,'Patterson',1),
(4221,'Moorabbin',1),
(4222,'Highett',1),
(4223,'Southland',1),
(4224,'Cheltenham',1),
(4225,'Mentone',1),
(4226,'Parkdale',1),
(4227,'Mordialloc',1),
(4228,'Aspendale',2),
(4229,'Edithvale',2),
(4230,'Chelsea',2),
(4231,'Bonbeach',2),
(4232,'Carrum',2),
(4233,'Seaford',2),
(4234,'Kananook',2),
(4235,'Frankston',2),
(4236,'Clayton',2),
(4237,'Westall',2),
(4238,'Springvale',2),
(4239,'Sandown Park',2),
(4240,'Noble Park',2),
(4241,'Yarraman',2),
(4242,'Dandenong',2),
(4243,'Lynbrook',2),
(4244,'Merinda Park',2),
(4245,'Cranbourne',2)
) AS v(station_id,station_name,zone_id) LEFT JOIN ref.stations s ON lower(s.station_name)=lower(v.station_name) WHERE s.id IS NULL;
WITH seed(stop_sequence,station_name,route_id) AS (VALUES
( 1,'Southern Cross',4),
( 2,'Flinders Street',4),
( 3,'Parliament',4),
( 4,'Melbourne Central',4),
( 5,'Flagstaff',4),
( 6,'Richmond',4),
( 7,'South Yarra',4),
( 8,'Caulfield',4),
( 9,'Clayton',4),
(10,'Springvale',4),
(11,'Sandown Park',4),
(12,'Noble Park',4),
(13,'Yarraman',4),
(14,'Dandenong',4),
(15,'Lynbrook',4),
(16,'Merinda Park',4),
(17,'Cranbourne',4)
),stcode AS (
SELECT ss.route_id,st.id::smallint AS station_id,ss.stop_sequence
FROM seed ss
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(ss.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id,station_id,stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- Flemington Line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(4401,'Flinders Street',1,NOW(),NOW()),
(4402,'Southern Cross',1,NOW(),NOW()),
(4403,'North Melbourne',1,NOW(),NOW()),
(4404,'Showgrounds',1,NOW(),NOW()),
(4405,'Flemington Racecourse',1,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name, route_id) AS (
VALUES
(1,'Flinders Street',5),
(2,'Southern Cross',5),
(3,'North Melbourne',5),
(4,'Showgrounds',5),
(5,'Flemington Racecourse',5)
),stcode AS (
SELECT ss.route_id,st.id::smallint AS station_id,ss.stop_sequence
FROM seed ss
JOIN LATERAL (
SELECT id
FROM ref.stations
WHERE lower(station_name)=lower(ss.station_name)
ORDER BY zone_id ASC,id ASC
LIMIT 1
) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- Frankston
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(1003,'Richmond',1,NOW(),NOW()),
(4601,'South Yarra',1,NOW(),NOW()),
(4602,'Hawksburn',1,NOW(),NOW()),
(4603,'Toorak',1,NOW(),NOW()),
(4604,'Armadale',1,NOW(),NOW()),
(4605,'Malvern',1,NOW(),NOW()),
(1007,'Caulfield',1,NOW(),NOW()),
(4606,'Glen Huntly',1,NOW(),NOW()),
(4607,'Ormond',1,NOW(),NOW()),
(4607,'Ormond',2,NOW(),NOW()),
(4608,'McKinnon',1,NOW(),NOW()),
(4608,'McKinnon',2,NOW(),NOW()),
(4609,'Bentleigh',1,NOW(),NOW()),
(4609,'Bentleigh',2,NOW(),NOW()),
(4610,'Patterson',2,NOW(),NOW()),
(4611,'Moorabbin',2,NOW(),NOW()),
(4612,'Highett',2,NOW(),NOW()),
(4613,'Southland',2,NOW(),NOW()),
(4614,'Cheltenham',2,NOW(),NOW()),
(4615,'Mentone',2,NOW(),NOW()),
(4616,'Parkdale',2,NOW(),NOW()),
(4617,'Mordialloc',2,NOW(),NOW()),
(4618,'Aspendale',2,NOW(),NOW()),
(4619,'Edithvale',2,NOW(),NOW()),
(4620,'Chelsea',2,NOW(),NOW()),
(4621,'Bonbeach',2,NOW(),NOW()),
(4622,'Carrum',2,NOW(),NOW()),
(4623,'Seaford',2,NOW(),NOW()),
(4624,'Kananook',2,NOW(),NOW()),
(4625,'Frankston',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name, route_id) AS (
VALUES
( 1,'Southern Cross',6),
( 2,'Flinders Street',6),
( 3,'Richmond',6),
( 4,'South Yarra',6),
( 5,'Hawksburn',6),
( 6,'Toorak',6),
( 7,'Armadale',6),
( 8,'Malvern',6),
( 9,'Caulfield',6),
(10,'Glen Huntly',6),
(11,'Ormond',6),
(12,'McKinnon',6),
(13,'Bentleigh',6),
(14,'Patterson',6),
(15,'Moorabbin',6),
(16,'Highett',6),
(17,'Southland',6),
(18,'Cheltenham',6),
(19,'Mentone',6),
(20,'Parkdale',6),
(21,'Mordialloc',6),
(22,'Aspendale',6),
(23,'Edithvale',6),
(24,'Chelsea',6),
(25,'Bonbeach',6),
(26,'Carrum',6),
(27,'Seaford',6),
(28,'Kananook',6),
(29,'Frankston',6)
),stcode AS (
SELECT ss.route_id,st.id::smallint AS station_id,ss.stop_sequence
FROM seed ss
JOIN LATERAL (
SELECT id
FROM ref.stations
WHERE lower(station_name)=lower(ss.station_name)
ORDER BY zone_id ASC,id ASC
LIMIT 1
) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- GLEN
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(1003,'Richmond',1,NOW(),NOW()),
(4700,'East Richmond',1,NOW(),NOW()),
(4701,'Burnley',1,NOW(),NOW()),
(4702,'Heyington',1,NOW(),NOW()),
(4703,'Kooyong',1,NOW(),NOW()),
(4704,'Tooronga',1,NOW(),NOW()),
(4705,'Gardiner',1,NOW(),NOW()),
(4706,'Glen Iris',1,NOW(),NOW()),
(4707,'Darling',1,NOW(),NOW()),
(4707,'Darling',2,NOW(),NOW()),
(4708,'East Malvern',1,NOW(),NOW()),
(4708,'East Malvern',2,NOW(),NOW()),
(4709,'Holmesglen',1,NOW(),NOW()),
(4709,'Holmesglen',2,NOW(),NOW()),
(4710,'Jordanville',2,NOW(),NOW()),
(4711,'Mount Waverley',2,NOW(),NOW()),
(4712,'Syndal',2,NOW(),NOW()),
(4713,'Glen Waverley',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name, route_id) AS (
VALUES
( 1,'Southern Cross',7),
( 2,'Flagstaff',7),
( 3,'Melbourne Central',7),
( 4,'Parliament',7),
( 5,'Flinders Street',7),
( 6,'Richmond',7),
( 7,'East Richmond',7),
( 8,'Burnley',7),
( 9,'Heyington',7),
(10,'Kooyong',7),
(11,'Tooronga',7),
(12,'Gardiner',7),
(13,'Glen Iris',7),
(14,'Darling',7),
(15,'East Malvern',7),
(16,'Holmesglen',7),
(17,'Jordanville',7),
(18,'Mount Waverley',7),
(19,'Syndal',7),
(20,'Glen Waverley',7)
),stcode AS (
SELECT ss.route_id,st.id::smallint AS station_id,ss.stop_sequence
FROM seed ss
JOIN LATERAL (
SELECT id
FROM ref.stations
WHERE lower(station_name)=lower(ss.station_name)
ORDER BY zone_id ASC,id ASC
LIMIT 1
) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

--Hurstbridge Line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1002,'Flinders Street',1,NOW(),NOW()),
(1001,'Southern Cross',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(4801,'Jolimont',1,NOW(),NOW()),
(4802,'West Richmond',1,NOW(),NOW()),
(4803,'North Richmond',1,NOW(),NOW()),
(4804,'Collingwood',1,NOW(),NOW()),
(4805,'Victoria Park',1,NOW(),NOW()),
(4806,'Clifton Hill',1,NOW(),NOW()),
(4807,'Westgarth',1,NOW(),NOW()),
(4808,'Dennis',1,NOW(),NOW()),
(4809,'Fairfield',1,NOW(),NOW()),
(4810,'Alphington',1,NOW(),NOW()),
(4811,'Darebin',1,NOW(),NOW()),
(4812,'Ivanhoe',1,NOW(),NOW()),
(4812,'Ivanhoe',2,NOW(),NOW()),
(4813,'Eaglemont',1,NOW(),NOW()),
(4813,'Eaglemont',2,NOW(),NOW()),
(4814,'Heidelberg',1,NOW(),NOW()),
(4814,'Heidelberg',2,NOW(),NOW()),
(4815,'Rosanna',2,NOW(),NOW()),
(4816,'Macleod',2,NOW(),NOW()),
(4817,'Watsonia',2,NOW(),NOW()),
(4818,'Greensborough',2,NOW(),NOW()),
(4819,'Montmorency',2,NOW(),NOW()),
(4820,'Eltham',2,NOW(),NOW()),
(4821,'Diamond Creek',2,NOW(),NOW()),
(4822,'Wattle Glen',2,NOW(),NOW()),
(4823,'Hurstbridge',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Flinders Street'),
( 2,'Southern Cross'),
( 3,'Flagstaff'),
( 4,'Melbourne Central'),
( 5,'Parliament'),
( 6,'Jolimont'),
( 7,'West Richmond'),
( 8,'North Richmond'),
( 9,'Collingwood'),
(10,'Victoria Park'),
(11,'Clifton Hill'),
(12,'Westgarth'),
(13,'Dennis'),
(14,'Fairfield'),
(15,'Alphington'),
(16,'Darebin'),
(17,'Ivanhoe'),
(18,'Eaglemont'),
(19,'Heidelberg'),
(20,'Rosanna'),
(21,'Macleod'),
(22,'Watsonia'),
(23,'Greensborough'),
(24,'Montmorency'),
(25,'Eltham'),
(26,'Diamond Creek'),
(27,'Wattle Glen'),
(28,'Hurstbridge')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Hurstbridge Line'
),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- Lilydale Line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1002,'Flinders Street',1,NOW(),NOW()),
(1001,'Southern Cross',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1003,'Richmond',1,NOW(),NOW()),
(4901,'East Richmond',1,NOW(),NOW()),
(4902,'Burnley',1,NOW(),NOW()),
(4903,'Hawthorn',1,NOW(),NOW()),
(4904,'Glenferrie',1,NOW(),NOW()),
(4905,'Auburn',1,NOW(),NOW()),
(4906,'Camberwell',1,NOW(),NOW()),
(4907,'East Camberwell',1,NOW(),NOW()),
(4908,'Canterbury',1,NOW(),NOW()),
(4908,'Canterbury',2,NOW(),NOW()),
(4909,'Chatham',1,NOW(),NOW()),
(4909,'Chatham',2,NOW(),NOW()),
(4910,'Union',1,NOW(),NOW()),
(4910,'Union',2,NOW(),NOW()),
(4911,'Box Hill',2,NOW(),NOW()),
(4912,'Laburnum',2,NOW(),NOW()),
(4913,'Blackburn',2,NOW(),NOW()),
(4914,'Nunawading',2,NOW(),NOW()),
(4915,'Mitcham',2,NOW(),NOW()),
(4916,'Heatherdale',2,NOW(),NOW()),
(4917,'Ringwood',2,NOW(),NOW()),
(4918,'Ringwood East',2,NOW(),NOW()),
(4919,'Croydon',2,NOW(),NOW()),
(4920,'Mooroolbark',2,NOW(),NOW()),
(4921,'Lilydale',2,NOW(),NOW()),
(4922,'Mont Albert',1,NOW(),NOW()),
(4923,'Surrey Hills',1,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Flinders Street'),
( 2,'Southern Cross'),
( 3,'Flagstaff'),
( 4,'Melbourne Central'),
( 5,'Parliament'),
( 6,'Richmond'),
( 7,'East Richmond'),
( 8,'Burnley'),
( 9,'Hawthorn'),
(10,'Glenferrie'),
(11,'Auburn'),
(12,'Camberwell'),
(13,'East Camberwell'),
(14,'Canterbury'),
(15,'Chatham'),
(16,'Surrey Hills'),
(17,'Mont Albert'),
(18,'Box Hill'),
(19,'Laburnum'),
(20,'Blackburn'),
(21,'Nunawading'),
(22,'Mitcham'),
(23,'Heatherdale'),
(24,'Ringwood'),
(25,'Ringwood East'),
(26,'Croydon'),
(27,'Mooroolbark'),
(28,'Lilydale')
),route AS (SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Lilydale Line'),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- Mernda Line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(5201,'Jolimont',1,NOW(),NOW()),
(5202,'West Richmond',1,NOW(),NOW()),
(5203,'North Richmond',1,NOW(),NOW()),
(5204,'Collingwood',1,NOW(),NOW()),
(5205,'Victoria Park',1,NOW(),NOW()),
(5206,'Clifton Hill',1,NOW(),NOW()),
(5207,'Rushall',1,NOW(),NOW()),
(5208,'Merri',1,NOW(),NOW()),
(5209,'Northcote',1,NOW(),NOW()),
(5210,'Croxton',1,NOW(),NOW()),
(5211,'Thornbury',1,NOW(),NOW()),
(5212,'Bell',1,NOW(),NOW()),
(5213,'Preston',1,NOW(),NOW()),
(5213,'Preston',2,NOW(),NOW()),
(5214,'Regent',1,NOW(),NOW()),
(5214,'Regent',2,NOW(),NOW()),
(5215,'Reservoir',1,NOW(),NOW()),
(5215,'Reservoir',2,NOW(),NOW()),
(5216,'Ruthven',2,NOW(),NOW()),
(5217,'Keon Park',2,NOW(),NOW()),
(5218,'Thomastown',2,NOW(),NOW()),
(5219,'Lalor',2,NOW(),NOW()),
(5220,'Epping',2,NOW(),NOW()),
(5221,'South Morang',2,NOW(),NOW()),
(5222,'Middle Gorge',2,NOW(),NOW()),
(5223,'Hawkstowe',2,NOW(),NOW()),
(5224,'Mernda',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Flinders Street'),
( 2,'Southern Cross'),
( 3,'Flagstaff'),
( 4,'Melbourne Central'),
( 5,'Parliament'),
( 6,'Jolimont'),
( 7,'West Richmond'),
( 8,'North Richmond'),
( 9,'Collingwood'),
(10,'Victoria Park'),
(11,'Clifton Hill'),
(12,'Rushall'),
(13,'Merri'),
(14,'Northcote'),
(15,'Croxton'),
(16,'Thornbury'),
(17,'Bell'),
(18,'Preston'),
(19,'Regent'),
(20,'Reservoir'),
(21,'Ruthven'),
(22,'Keon Park'),
(23,'Thomastown'),
(24,'Lalor'),
(25,'Epping'),
(26,'South Morang'),
(27,'Middle Gorge'),
(28,'Hawkstowe'),
(29,'Mernda')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Mernda Line'
),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

-- Pakenham Line
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1003,'Richmond',1,NOW(),NOW()),
(5401,'South Yarra',1,NOW(),NOW()),
(5402,'Malvern',1,NOW(),NOW()),
(1007,'Caulfield',1,NOW(),NOW()),
(5403,'Carnegie',1,NOW(),NOW()),
(5404,'Murrumbeena',1,NOW(),NOW()),
(5405,'Hughesdale',1,NOW(),NOW()),
(5405,'Hughesdale',2,NOW(),NOW()),
(5406,'Oakleigh',1,NOW(),NOW()),
(5406,'Oakleigh',2,NOW(),NOW()),
(5407,'Huntingdale',1,NOW(),NOW()),
(5407,'Huntingdale',2,NOW(),NOW()),
(5408,'Clayton',2,NOW(),NOW()),
(5409,'Westall',2,NOW(),NOW()),
(5410,'Springvale',2,NOW(),NOW()),
(5411,'Sandown Park',2,NOW(),NOW()),
(5412,'Noble Park',2,NOW(),NOW()),
(5413,'Yarraman',2,NOW(),NOW()),
(5414,'Dandenong',2,NOW(),NOW()),
(5415,'Hallam',2,NOW(),NOW()),
(5416,'Narre Warren',2,NOW(),NOW()),
(5417,'Berwick',2,NOW(),NOW()),
(5418,'Beaconsfield',2,NOW(),NOW()),
(5419,'Officer',2,NOW(),NOW()),
(5420,'Cardinia Road',2,NOW(),NOW()),
(5421,'Pakenham',2,NOW(),NOW()),
(5422,'East Pakenham',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name, route_id) AS (
VALUES
( 1,'Southern Cross',11),
( 2,'Flinders Street',11),
( 3,'Parliament',11),
( 4,'Melbourne Central',11),
( 5,'Flagstaff',11),
( 6,'Richmond',11),
( 7,'South Yarra',11),
( 8,'Malvern',11),
( 9,'Caulfield',11),
(10,'Carnegie',11),
(11,'Murrumbeena',11),
(12,'Hughesdale',11),
(13,'Oakleigh',11),
(14,'Huntingdale',11),
(15,'Clayton',11),
(16,'Westall',11),
(17,'Springvale',11),
(18,'Sandown Park',11),
(19,'Noble Park',11),
(20,'Yarraman',11),
(21,'Dandenong',11),
(22,'Hallam',11),
(23,'Narre Warren',11),
(24,'Berwick',11),
(25,'Beaconsfield',11),
(26,'Officer',11),
(27,'Cardinia Road',11),
(28,'Pakenham',11),
(29,'East Pakenham',11)
),stcode AS (
SELECT ss.route_id,st.id::smallint AS station_id,ss.stop_sequence
FROM seed ss
JOIN LATERAL (
SELECT id
FROM ref.stations
WHERE lower(station_name)=lower(ss.station_name)
ORDER BY zone_id ASC,id ASC
LIMIT 1
) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at)
SELECT v.station_id, v.station_name, v.zone_id, NOW(), NOW()
FROM (VALUES
(5601,'Flinders Street',1),
(5602,'Richmond',1),
(5603,'South Yarra',1),
(5604,'Prahran',1),
(5605,'Windsor',1),
(5606,'Balaclava',1),
(5607,'Ripponlea',1),
(5608,'Elsternwick',1),
(5609,'Gardenvale',1),
(5610,'North Brighton',1),
(5610,'North Brighton',2),
(5611,'Middle Brighton',1),
(5611,'Middle Brighton',2),
(5612,'Brighton Beach',1),
(5612,'Brighton Beach',2),
(5613,'Hampton',2),
(5614,'Sandringham',2)
) AS v(station_id, station_name, zone_id)
LEFT JOIN ref.stations s
  ON lower(s.station_name)=lower(v.station_name) AND s.zone_id=v.zone_id
WHERE s.id IS NULL
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Flinders Street'),
( 2,'Richmond'),
( 3,'South Yarra'),
( 4,'Prahran'),
( 5,'Windsor'),
( 6,'Balaclava'),
( 7,'Ripponlea'),
( 8,'Elsternwick'),
( 9,'Gardenvale'),
(10,'North Brighton'),
(11,'Middle Brighton'),
(12,'Brighton Beach'),
(13,'Hampton'),
(14,'Sandringham')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Sandringham Line'
),stcode AS (
SELECT r.route_id, st.id::smallint AS station_id, s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (
SELECT id
FROM ref.stations
WHERE lower(station_name)=lower(s.station_name)
ORDER BY zone_id ASC, id ASC
LIMIT 1
) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id, station_id, stop_sequence FROM stcode
ON CONFLICT DO NOTHING;


INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(4625,'Frankston',2,NOW(),NOW()),
(5701,'Leawarra',2,NOW(),NOW()),
(5702,'Baxter',2,NOW(),NOW()),
(5703,'Somerville',2,NOW(),NOW()),
(5704,'Tyabb',2,NOW(),NOW()),
(5705,'Hastings',2,NOW(),NOW()),
(5706,'Bittern',2,NOW(),NOW()),
(5707,'Morradoo',2,NOW(),NOW()),
(5708,'Crib Point',2,NOW(),NOW()),
(5709,'Stony Point',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Frankston'),
( 2,'Leawarra'),
( 3,'Baxter'),
( 4,'Somerville'),
( 5,'Tyabb'),
( 6,'Hastings'),
( 7,'Bittern'),
( 8,'Morradoo'),
( 9,'Crib Point'),
(10,'Stony Point')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Stony Point Line'
),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;


INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(1005,'Footscray',1,NOW(),NOW()),
(6001,'Middle Footscray',1,NOW(),NOW()),
(6002,'West Footscray',1,NOW(),NOW()),
(6003,'Tottenham',1,NOW(),NOW()),
(1008,'Sunshine',1,NOW(),NOW()),
(1008,'Sunshine',2,NOW(),NOW()),
(6004,'Albion',1,NOW(),NOW()),
(6004,'Albion',2,NOW(),NOW()),
(6005,'Ginifer',2,NOW(),NOW()),
(6006,'St Albans',2,NOW(),NOW()),
(6007,'Keilor Plains',2,NOW(),NOW()),
(1019,'Watergardens',2,NOW(),NOW()),
(6008,'Diggers Rest',2,NOW(),NOW()),
(1018,'Sunbury',2,NOW(),NOW()),
(6009,'Arden',1,NOW(),NOW()),
(6010,'Parkville',1,NOW(),NOW()),
(6011,'State Library',1,NOW(),NOW()),
(6012,'Town Hall',1,NOW(),NOW()),
(6013,'Anzac',1,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Southern Cross'),
( 2,'Flinders Street'),
( 3,'Parliament'),
( 4,'Melbourne Central'),
( 5,'Flagstaff'),
( 6,'North Melbourne'),
( 7,'Anzac'),
( 8,'Town Hall'),
( 9,'State Library'),
(10,'Parkville'),
(11,'Arden'),
(12,'Footscray'),
(13,'Middle Footscray'),
(14,'West Footscray'),
(15,'Tottenham'),
(16,'Sunshine'),
(17,'Albion'),
(18,'Ginifer'),
(19,'St Albans'),
(20,'Keilor Plains'),
(21,'Watergardens'),
(22,'Diggers Rest'),
(23,'Sunbury')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Sunbury Line'
),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(1005,'Footscray',1,NOW(),NOW()),
(6001,'Middle Footscray',1,NOW(),NOW()),
(6002,'West Footscray',1,NOW(),NOW()),
(6003,'Tottenham',1,NOW(),NOW()),
(1008,'Sunshine',1,NOW(),NOW()),
(1008,'Sunshine',2,NOW(),NOW()),
(6004,'Albion',1,NOW(),NOW()),
(6004,'Albion',2,NOW(),NOW()),
(6005,'Ginifer',2,NOW(),NOW()),
(6006,'St Albans',2,NOW(),NOW()),
(6007,'Keilor Plains',2,NOW(),NOW()),
(1019,'Watergardens',2,NOW(),NOW()),
(6008,'Diggers Rest',2,NOW(),NOW()),
(1018,'Sunbury',2,NOW(),NOW()),
(6009,'Arden',1,NOW(),NOW()),
(6010,'Parkville',1,NOW(),NOW()),
(6011,'State Library',1,NOW(),NOW()),
(6012,'Town Hall',1,NOW(),NOW()),
(6013,'Anzac',1,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Southern Cross'),
( 2,'Flinders Street'),
( 3,'Parliament'),
( 4,'Melbourne Central'),
( 5,'Flagstaff'),
( 6,'North Melbourne'),
( 7,'Anzac'),
( 8,'Town Hall'),
( 9,'State Library'),
(10,'Parkville'),
(11,'Arden'),
(12,'Footscray'),
(13,'Middle Footscray'),
(14,'West Footscray'),
(15,'Tottenham'),
(16,'Sunshine'),
(17,'Albion'),
(18,'Ginifer'),
(19,'St Albans'),
(20,'Keilor Plains'),
(21,'Watergardens'),
(22,'Diggers Rest'),
(23,'Sunbury')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Sunbury Line'
),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(5901,'Macaulay',1,NOW(),NOW()),
(5902,'Flemington Bridge',1,NOW(),NOW()),
(5903,'Royal Park',1,NOW(),NOW()),
(5904,'Jewell',1,NOW(),NOW()),
(5905,'Brunswick',1,NOW(),NOW()),
(5906,'Anstey',1,NOW(),NOW()),
(5907,'Moreland',1,NOW(),NOW()),
(5908,'Coburg',1,NOW(),NOW()),
(5909,'Batman',1,NOW(),NOW()),
(5909,'Batman',2,NOW(),NOW()),
(5910,'Merlynston',1,NOW(),NOW()),
(5910,'Merlynston',2,NOW(),NOW()),
(5911,'Fawkner',1,NOW(),NOW()),
(5911,'Fawkner',2,NOW(),NOW()),
(5912,'Gowrie',2,NOW(),NOW()),
(5913,'Upfield',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Southern Cross'),
( 2,'Flinders Street'),
( 3,'Parliament'),
( 4,'Melbourne Central'),
( 5,'Flagstaff'),
( 6,'North Melbourne'),
( 7,'Macaulay'),
( 8,'Flemington Bridge'),
( 9,'Royal Park'),
(10,'Jewell'),
(11,'Brunswick'),
(12,'Anstey'),
(13,'Moreland'),
(14,'Coburg'),
(15,'Batman'),
(16,'Merlynston'),
(17,'Fawkner'),
(18,'Gowrie'),
(19,'Upfield')
),route AS (
SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Upfield Line'
),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(4116,'Flagstaff',1,NOW(),NOW()),
(4117,'Melbourne Central',1,NOW(),NOW()),
(4118,'Parliament',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(5901,'Macaulay',1,NOW(),NOW()),
(5902,'Flemington Bridge',1,NOW(),NOW()),
(5903,'Royal Park',1,NOW(),NOW()),
(5904,'Jewell',1,NOW(),NOW()),
(5905,'Brunswick',1,NOW(),NOW()),
(5906,'Anstey',1,NOW(),NOW()),
(5907,'Moreland',1,NOW(),NOW()),
(5908,'Coburg',1,NOW(),NOW()),
(5909,'Batman',1,NOW(),NOW()),
(5909,'Batman',2,NOW(),NOW()),
(5910,'Merlynston',1,NOW(),NOW()),
(5910,'Merlynston',2,NOW(),NOW()),
(5911,'Fawkner',1,NOW(),NOW()),
(5911,'Fawkner',2,NOW(),NOW()),
(5912,'Gowrie',2,NOW(),NOW()),
(5913,'Upfield',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Upfield'),
( 2,'Gowrie'),
( 3,'Fawkner'),
( 4,'Merlynston'),
( 5,'Batman'),
( 6,'Coburg'),
( 7,'Moreland'),
( 8,'Anstey'),
( 9,'Brunswick'),
(10,'Jewell'),
(11,'Royal Park'),
(12,'Flemington Bridge'),
(13,'Macaulay'),
(14,'North Melbourne'),
(15,'Flagstaff'),
(16,'Melbourne Central'),
(17,'Parliament'),
(18,'Flinders Street'),
(19,'Southern Cross')
),route AS (SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Upfield Line'),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(6101,'South Kensington',1,NOW(),NOW()),
(1005,'Footscray',1,NOW(),NOW()),
(6102,'Seddon',1,NOW(),NOW()),
(6103,'Yarraville',1,NOW(),NOW()),
(6104,'Spotswood',1,NOW(),NOW()),
(6105,'Newport',1,NOW(),NOW()),
(6106,'Seaholme',1,NOW(),NOW()),
(6107,'Altona',1,NOW(),NOW()),
(6107,'Altona',2,NOW(),NOW()),
(6108,'Westona',1,NOW(),NOW()),
(6108,'Westona',2,NOW(),NOW()),
(6109,'Laverton',1,NOW(),NOW()),
(6109,'Laverton',2,NOW(),NOW()),
(6110,'Aircraft',2,NOW(),NOW()),
(6111,'Williams Landing',2,NOW(),NOW()),
(6112,'Hoppers Crossing',2,NOW(),NOW()),
(6113,'Werribee',2,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Werribee'),
( 2,'Hoppers Crossing'),
( 3,'Williams Landing'),
( 4,'Aircraft'),
( 5,'Laverton'),
( 6,'Westona'),
( 7,'Altona'),
( 8,'Seaholme'),
( 9,'Newport'),
(10,'Spotswood'),
(11,'Yarraville'),
(12,'Seddon'),
(13,'Footscray'),
(14,'South Kensington'),
(15,'North Melbourne'),
(16,'Southern Cross'),
(17,'Flinders Street')
),route AS (SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Werribee Line'),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1002,'Flinders Street',1,NOW(),NOW()),
(1004,'North Melbourne',1,NOW(),NOW()),
(6201,'South Kensington',1,NOW(),NOW()),
(1005,'Footscray',1,NOW(),NOW()),
(6202,'Seddon',1,NOW(),NOW()),
(6203,'Yarraville',1,NOW(),NOW()),
(6204,'Spotswood',1,NOW(),NOW()),
(6205,'Newport',1,NOW(),NOW()),
(6206,'North Williamstown',1,NOW(),NOW()),
(6207,'Williamstown Beach',1,NOW(),NOW()),
(6208,'Williamstown',1,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Williamstown'),
( 2,'Williamstown Beach'),
( 3,'North Williamstown'),
( 4,'Newport'),
( 5,'Spotswood'),
( 6,'Yarraville'),
( 7,'Seddon'),
( 8,'Footscray'),
( 9,'South Kensington'),
(10,'North Melbourne'),
(11,'Southern Cross'),
(12,'Flinders Street')
),route AS (SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Williamstown Line'),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;

INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at) VALUES
(1001,'Southern Cross',1,NOW(),NOW()),
(1008,'Sunshine',1,NOW(),NOW()),
(1008,'Sunshine',2,NOW(),NOW()),
(1010,'Ardeer',2,NOW(),NOW()),
(1009,'Deer Park',2,NOW(),NOW()),
(1011,'Caroline Springs',2,NOW(),NOW()),
(1012,'Rockbank',2,NOW(),NOW()),
(1014,'Cobblebank',2,NOW(),NOW()),
(1013,'Melton',2,NOW(),NOW()),
(1031,'Bacchus Marsh',2,NOW(),NOW()),
(1045,'Ballan',4,NOW(),NOW()),
(1057,'Ballarat',8,NOW(),NOW()),
(1058,'Wendouree',8,NOW(),NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;
WITH seed(stop_sequence, station_name) AS (VALUES
( 1,'Southern Cross'),
( 2,'Sunshine'),
( 3,'Ardeer'),
( 4,'Deer Park'),
( 5,'Caroline Springs'),
( 6,'Rockbank'),
( 7,'Cobblebank'),
( 8,'Melton'),
( 9,'Bacchus Marsh'),
(10,'Ballan'),
(11,'Ballarat'),
(12,'Wendouree')
),route AS (SELECT route_id::int AS route_id FROM ref.rail_routes WHERE route_name='Ballarat Line'),stcode AS (
SELECT r.route_id,st.id::smallint AS station_id,s.stop_sequence
FROM route r
JOIN seed s ON TRUE
JOIN LATERAL (SELECT id FROM ref.stations WHERE lower(station_name)=lower(s.station_name) ORDER BY zone_id ASC,id ASC LIMIT 1) st ON TRUE
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT route_id,station_id,stop_sequence FROM stcode
ON CONFLICT DO NOTHING;