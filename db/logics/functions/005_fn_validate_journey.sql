CREATE OR REPLACE FUNCTION journey.fn_validate_journey(
  p_card_id     BIGINT,
  p_station_id  SMALLINT,
  p_touched_at  TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (journey_id BIGINT, status TEXT, start_zone SMALLINT, end_zone SMALLINT, station_row_id SMALLINT)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_open_journey_id   BIGINT;
  v_route_id          INT;
  v_start_station_sid SMALLINT;  -- station_id (business key)
  v_started_at        TIMESTAMPTZ;

  v_start_zone  SMALLINT;
  v_curr_zone   SMALLINT;

  v_start_station_row_id SMALLINT; -- ref.stations.id (surrogate)
  v_curr_station_row_id  SMALLINT; -- ref.stations.id (surrogate)

  v_zones_travelled SMALLINT;
  v_time_window     INTERVAL;

  v_on_route BOOLEAN;
  v_elapsed  INTERVAL;
BEGIN
  -- 1) Find latest open journey
  SELECT rj.journey_id, rj.rail_route_id, rj.start_station_id, rj.started_at
  INTO v_open_journey_id, v_route_id, v_start_station_row_id, v_started_at
  FROM journey.rail_journeys rj
  WHERE rj.card_id = p_card_id
    AND rj.status = 'open'
  ORDER BY rj.started_at DESC
  LIMIT 1;

  -- No open journey => caller should create a new journey (touch_on)
  IF v_open_journey_id IS NULL THEN
    journey_id := NULL;
    status := 'touch_on';
    RETURN NEXT;
    RETURN;
  END IF;
  RAISE NOTICE 'NOT A touch_on JOURNEY';
  journey_id := v_open_journey_id;

  -- 2) Same station within 15 minutes => cancel candidate

  IF EXISTS (
      SELECT 1 FROM ref.stations
      WHERE station_id = p_station_id AND id = v_start_station_row_id) 
          AND p_touched_at <= v_started_at + INTERVAL '15 minutes' THEN
    status := 'same_station_cancellation';
    station_row_id := v_start_station_row_id;
    RETURN NEXT;
    RETURN;
  END IF;
  RAISE NOTICE 'NOT A same_station_cancellation JOURNEY';


  -- 3) Map station_id -> stations.id (choose a stable row if overlaps exist)
  SELECT MIN(id) INTO v_curr_station_row_id
  FROM ref.stations
  WHERE station_id = p_station_id;

  IF v_curr_station_row_id IS NULL OR v_start_station_row_id IS NULL THEN
    RAISE EXCEPTION 'Unkown stationID';
  END IF;

  station_row_id := v_curr_station_row_id;

  -- 4) Check if both stations are on same route
  v_on_route := EXISTS (
    SELECT 1
    FROM ref.rail_route_stations r1
    JOIN ref.rail_route_stations r2
      ON r2.route_id = r1.route_id
    WHERE r1.route_id   = v_route_id
      AND r1.station_id = v_start_station_row_id::smallint
      AND r2.station_id = v_curr_station_row_id::smallint
  );

  

  -- 5) Get zones (use MIN(zone_id) to pick one if overlap)
  SELECT zone_id INTO v_start_zone
  FROM ref.stations
  WHERE id = v_start_station_row_id;

  SELECT zone_id INTO v_curr_zone
  FROM ref.stations
  WHERE id = v_curr_station_row_id;

  IF v_start_zone IS NULL OR v_curr_zone IS NULL THEN
    RAISE EXCEPTION 'Unkown ZONE';
  END IF;

  start_zone := v_start_zone;
  end_zone := v_curr_zone;

    IF NOT v_on_route THEN
    RAISE NOTICE 'Irrelavant routes';
    status := 'incomplete_trip';
    RETURN NEXT;
    RETURN;
    END IF;

  v_zones_travelled := (ABS(v_start_zone - v_curr_zone) + 1)::smallint;

  -- two_hour_windows starts at 2 zones
  IF v_zones_travelled < 2 THEN
    v_zones_travelled := 2;
  END IF;

  SELECT time_window INTO v_time_window
  FROM ref.two_hour_windows
  WHERE zone_count = v_zones_travelled;

  IF v_time_window IS NULL THEN
    RAISE NOTICE 'More than two hour window journey';
    status := 'incomplete_trip';
    RETURN NEXT;
    RETURN;
  END IF;

  v_elapsed := p_touched_at - v_started_at;

  IF v_elapsed <= v_time_window THEN
    status := 'touch_off';
  ELSE
    status := 'incomplete_trip';
  END IF;

  RETURN NEXT;
END;
$$;