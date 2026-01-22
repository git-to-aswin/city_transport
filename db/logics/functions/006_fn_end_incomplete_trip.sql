CREATE OR REPLACE FUNCTION journey.fn_end_incomplete_trip(
  p_card_id BIGINT,
  p_journey_id BIGINT,
  p_start_zone SMALLINT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_total_fare_today INT;
  v_base_fare_cents INT;
  v_capping_fare_cents INT;
  v_is_zone_1 BOOLEAN;
  v_is_zone_2 BOOLEAN;
BEGIN
  -- Total amount spent on this card today
  SELECT COALESCE(SUM(rjf.fare_cents), 0)
  INTO v_total_fare_today
  FROM journey.rail_journeys rj
  JOIN journey.rail_journey_fares rjf
    ON rjf.journey_id = rj.journey_id
  WHERE rj.card_id = p_card_id
    AND rj.started_at >= date_trunc('day', NOW())
    AND rj.started_at < date_trunc('day', NOW()) + INTERVAL '1 day';

  -- Infer zone flags for fare lookup
  v_is_zone_1 := (p_start_zone = 1);
  v_is_zone_2 := (p_start_zone = 2);

  -- Fare for missing tapping (zone count = 1, zone flags from start zone)
  SELECT base_fare_cents, capping_fare_cents
  INTO v_base_fare_cents, v_capping_fare_cents
  FROM ref.railpay_money
  WHERE zone_count = 1
    AND is_zone_1 = TRUE -- for incompelete journey we consider whole route
    AND is_zone_2 = v_is_zone_2
    AND status_active = 'active'
  LIMIT 1;

  IF v_base_fare_cents IS NULL OR v_capping_fare_cents IS NULL THEN
    RAISE EXCEPTION 'No fare config for start_zone=%', p_start_zone;
  END IF;

  IF v_total_fare_today >= v_capping_fare_cents THEN
    -- Already reached the capping price
    UPDATE journey.rail_journey_fares
    SET fare_cents = 0,
        fare_calculated_at = NOW(),
        fare_reason = 'capped_fare',
        updated_at = NOW()
    WHERE journey_id = p_journey_id;
  ELSIF v_total_fare_today + v_base_fare_cents > v_capping_fare_cents THEN
    -- Going beyond capping price
    PERFORM card.fn_deduct_fare(p_card_id, v_capping_fare_cents - v_total_fare_today);

    UPDATE journey.rail_journey_fares
    SET fare_cents = v_capping_fare_cents - v_total_fare_today,
        fare_calculated_at = NOW(),
        fare_reason = 'incomplete_journey',
        updated_at = NOW()
    WHERE journey_id = p_journey_id;
  ELSE
    -- Two-hour fare
    PERFORM card.fn_deduct_fare(p_card_id, v_base_fare_cents);

    UPDATE journey.rail_journey_fares
    SET fare_cents = v_base_fare_cents,
        fare_calculated_at = NOW(),
        fare_reason = 'incomplete_journey',
        updated_at = NOW()
    WHERE journey_id = p_journey_id;
  END IF;

  UPDATE journey.rail_journeys
  SET status = 'closed',
      updated_at = NOW()
  WHERE journey_id = p_journey_id;
END;
$$;
