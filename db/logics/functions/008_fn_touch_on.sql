CREATE OR REPLACE FUNCTION ref.fn_touch_on(
  p_card_id BIGINT,
  p_station_row_id SMALLINT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_route_id INT;
  v_open_journey_id BIGINT;
  v_started_at TIMESTAMPTZ;
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM card.rail_cards
    WHERE card_id = p_card_id
      AND balance_cents > 0
  ) THEN
    RAISE EXCEPTION 'Insufficient balance';
  END IF;

  SELECT rrs.route_id
  INTO v_route_id
  FROM ref.rail_route_stations rrs
  WHERE rrs.station_id = p_station_row_id
  ORDER BY rrs.route_id
  LIMIT 1;

  IF v_route_id IS NULL THEN
    RAISE EXCEPTION 'No route for station_id %', p_station_row_id;
  END IF;

  INSERT INTO journey.rail_journeys (card_id, rail_route_id, start_station_id, started_at, status)
  VALUES (p_card_id, v_route_id, p_station_row_id, NOW(), 'open') RETURNING journey_id, started_at INTO (v_open_journey_id, v_started_at);

  INSERT INTO journey.rail_journey_fares (journey_id, journey_started_at, start_zone)
  SELECT
    v_open_journey_id,
    v_started_at,
    (SELECT MIN(zone_id) FROM ref.stations WHERE station_id = v_start_station_id);

END;
$$;
