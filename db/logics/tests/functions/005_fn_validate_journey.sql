BEGIN;
DO $$
DECLARE
  v_now TIMESTAMPTZ := NOW();
  v_card_id BIGINT;
  v_card_number VARCHAR(16);
  v_route_id INT;
  v_start_station_sid SMALLINT;
  v_other_station_sid SMALLINT;
  v_journey_id BIGINT;
  v_status TEXT;
BEGIN
  -- Preconditions: required reference data
  IF NOT EXISTS (SELECT 1 FROM ref.two_hour_windows WHERE zone_count = 2) THEN
    RAISE EXCEPTION 'Precondition failed: ref.two_hour_windows missing zone_count=2';
  END IF;

  -- Pick a route with at least two stations
  SELECT rrs.route_id
  INTO v_route_id
  FROM ref.rail_route_stations rrs
  GROUP BY rrs.route_id
  HAVING COUNT(*) >= 2
  ORDER BY rrs.route_id
  LIMIT 1;

  IF v_route_id IS NULL THEN
    RAISE EXCEPTION 'Precondition failed: no route in ref.rail_route_stations has >= 2 stations';
  END IF;

  -- Resolve two stations on the chosen route
  SELECT s.id
  INTO v_start_station_sid
  FROM ref.rail_route_stations rrs
  JOIN ref.stations s ON s.id = rrs.station_id
  WHERE rrs.route_id = v_route_id
  ORDER BY rrs.stop_sequence ASC
  LIMIT 1;

  SELECT s.id
  INTO v_other_station_sid
  FROM ref.rail_route_stations rrs
  JOIN ref.stations s ON s.id = rrs.station_id
  WHERE rrs.route_id = v_route_id
  ORDER BY rrs.stop_sequence ASC
  OFFSET 1
  LIMIT 1;

  IF v_start_station_sid IS NULL OR v_other_station_sid IS NULL THEN
    RAISE EXCEPTION 'Precondition failed: could not resolve two stations for route_id=%', v_route_id;
  END IF;

  -- Create a test card
  v_card_number := lpad(((extract(epoch from clock_timestamp()) * 1000000)::bigint % 10000000000000000)::text, 16, '0');
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id, created_at, updated_at)
  VALUES (v_card_number, 10000, 1, NOW(), NOW())
  RETURNING card_id INTO v_card_id;

  -- TC1: No open journey should return (NULL, closed)
  SELECT journey_id, status
  INTO v_journey_id, v_status
  FROM journey.fn_validate_journey(v_card_id::bigint, v_other_station_sid::smallint, v_now);

  IF v_journey_id IS NOT NULL OR v_status <> 'closed' THEN
    RAISE EXCEPTION 'TC1 failed: expected (NULL, closed) got (%, %)', v_journey_id, v_status;
  END IF;

  -- Seed an open journey
  INSERT INTO journey.rail_journeys (card_id, rail_route_id, start_station_id, started_at, status)
  VALUES (v_card_id, v_route_id, v_start_station_sid, v_now - INTERVAL '10 minutes', 'open')
  RETURNING journey_id INTO v_journey_id;

  -- TC2: Start station tap should cancel
  SELECT journey_id, status
  INTO v_journey_id, v_status
  FROM journey.fn_validate_journey(v_card_id::bigint, v_start_station_sid::smallint, v_now);

  IF v_status <> 'cancelled' THEN
    RAISE EXCEPTION 'TC2 failed: expected cancelled got %', v_status;
  END IF;

  -- Reset to open for further tests
  UPDATE journey.rail_journeys
  SET started_at = v_now - INTERVAL '30 minutes',
      rail_route_id = v_route_id,
      start_station_id = v_start_station_sid,
      status = 'open',
      end_station_id = NULL,
      ended_at = NULL
  WHERE journey_id = v_journey_id;

  -- TC3: Different station within window should allow tap_off (or incomplete if window missing)
  SELECT journey_id, status
  INTO v_journey_id, v_status
  FROM journey.fn_validate_journey(v_card_id::bigint, v_other_station_sid::smallint, v_now);

  IF v_status <> 'tap_off' AND v_status <> 'incomplete' THEN
    RAISE EXCEPTION 'TC3 failed: expected tap_off (or incomplete if derived window not present) got %', v_status;
  END IF;

  -- TC4: Long-open journey should be incomplete
  UPDATE journey.rail_journeys
  SET started_at = v_now - INTERVAL '10 hours',
      status = 'open',
      end_station_id = NULL,
      ended_at = NULL
  WHERE journey_id = v_journey_id;

  SELECT journey_id, status
  INTO v_journey_id, v_status
  FROM journey.fn_validate_journey(v_card_id::bigint, v_other_station_sid::smallint, v_now);

  IF v_status <> 'incomplete' THEN
    RAISE EXCEPTION 'TC4 failed: expected incomplete got %', v_status;
  END IF;

  RAISE NOTICE '✅ fn_validate_journey passed. route_id=%, card_id=%, start_station_id=%, other_station_id=%',
    v_route_id, v_card_id, v_start_station_sid, v_other_station_sid;
END $$;
ROLLBACK;
