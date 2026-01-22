CREATE OR REPLACE FUNCTION journey.fn_touch_off_fare(
  p_journey_id   BIGINT,
  p_card_id      BIGINT,
  p_start_zone   SMALLINT,
  p_end_zone     SMALLINT,
  p_started_at   TIMESTAMPTZ,
  p_ended_at     TIMESTAMPTZ
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
  v_zone_count SMALLINT;
  v_is_zone_1 BOOLEAN := FALSE;
  v_is_zone_2 BOOLEAN := FALSE;

  v_base_fare_cents INT;
  v_cap_fare_cents  INT;

  v_total_today_cents INT := 0;
  v_charge_cents INT := 0;
  v_ok BOOLEAN;
BEGIN
  IF p_end_zone IS NULL THEN
    RAISE EXCEPTION 'end_zone cannot be NULL for tap-off fare';
  END IF;

  -- Zones travelled (inclusive). Clamp to at least 2 because your tables start from 2 zones.
  v_zone_count := (ABS(p_end_zone - p_start_zone) + 1)::smallint;
  IF v_zone_count < 2 THEN
    v_zone_count := 2;
  END IF;

  v_is_zone_1 := (p_start_zone = 1 OR p_end_zone = 1);
  IF NOT v_is_zone_1 AND v_zone_count = 1 THEN
    v_is_zone_2 := (p_start_zone = 2 OR p_end_zone = 2);
  END IF;

  -- Lookup base + cap fares
  SELECT m.base_fare_cents, m.capping_fare_cents
  INTO v_base_fare_cents, v_cap_fare_cents
  FROM ref.railpay_money m
  WHERE m.zone_count = v_zone_count
    AND m.is_zone_1  = v_is_zone_1
    AND m.is_zone_2  = v_is_zone_2
    AND m.status_active = 'active'
  LIMIT 1;

  IF v_base_fare_cents IS NULL OR v_cap_fare_cents IS NULL THEN
    RAISE EXCEPTION 'No fare rule found for zone_count=%, is_zone_1=%, is_zone_2=%',
      v_zone_count, v_is_zone_1, v_is_zone_2;
  END IF;

  -- Total charged today for this card (use journey started_at day as "service day")
  SELECT COALESCE(SUM(rjf.fare_cents), 0)
  INTO v_total_today_cents
  FROM journey.rail_journeys rj
  JOIN journey.rail_journey_fares rjf
    ON rjf.journey_id = rj.journey_id
  WHERE rj.card_id = p_card_id
    AND rj.started_at >= date_trunc('day', p_ended_at)
    AND rj.started_at <  date_trunc('day', p_ended_at) + INTERVAL '1 day';

  -- Apply daily cap
  IF v_total_today_cents >= v_cap_fare_cents THEN
    v_charge_cents := 0;
  ELSIF v_total_today_cents + v_base_fare_cents > v_cap_fare_cents THEN
    v_charge_cents := v_cap_fare_cents - v_total_today_cents;
  ELSE
    v_charge_cents := v_base_fare_cents;
  END IF;

  -- Deduct (if charge > 0)
  IF v_charge_cents > 0 THEN
    v_ok := card.fn_deduct_fare(p_card_id, v_charge_cents);
    IF NOT v_ok THEN
      RAISE EXCEPTION 'Insufficient balance to deduct % cents', v_charge_cents;
    END IF;
  END IF;

  -- Persist fare result
  UPDATE journey.rail_journey_fares
  SET fare_cents = v_charge_cents,
      fare_calculated_at = NOW(),
      fare_reason = CASE
        WHEN v_charge_cents = 0 THEN 'capped_fare'
        WHEN v_charge_cents < v_base_fare_cents THEN 'capped_fare'
        ELSE 'full_fare'
      END,
      updated_at = NOW()
  WHERE journey_id = p_journey_id;

  RETURN v_charge_cents;
END;
$$;