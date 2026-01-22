CREATE OR REPLACE FUNCTION journey.fn_cancellation_same_stop(
  p_open_journey_id BIGINT,
  p_station_id SMALLINT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE journey.rail_journey_fares
  SET fare_cents = 0,
      fare_calculated_at = NOW(),
      fare_reason = 'other',
      end_zone = start_zone,
      updated_at = NOW()
  WHERE journey_id = p_open_journey_id;

  UPDATE journey.rail_journeys
  SET status = 'cancelled',
      end_station_id = p_station_id,
      ended_at = NOW(),
      updated_at = NOW()
  WHERE journey_id = p_open_journey_id;
END;
$$;
