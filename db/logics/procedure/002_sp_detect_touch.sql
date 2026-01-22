CREATE OR REPLACE PROCEDURE card.sp_detect_touch (
  IN  p_card_number   VARCHAR(16),
  IN  p_station_id    SMALLINT,
  OUT p_balance_cents INT,
  OUT p_message       TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_card_id         BIGINT;
  v_open_journey_id BIGINT;
  v_status          TEXT;
  v_start_zone      SMALLINT;
  v_end_zone        SMALLINT;
  v_station_row_id  SMALLINT;
BEGIN
  p_balance_cents := NULL;
  p_message := NULL;

  -- 1) Get and lock card row to avoid concurrent double-taps causing inconsistencies
  SELECT rc.card_id, rc.balance_cents
  INTO v_card_id, p_balance_cents
  FROM card.rail_cards rc
  WHERE rc.card_number = p_card_number
  FOR UPDATE;

  IF v_card_id IS NULL THEN
    p_message := 'card_not_found';
    RETURN;
  END IF;

  IF p_balance_cents IS NULL OR p_balance_cents <= 0 THEN
    p_message := 'insufficient_balance';
    RETURN;
  END IF;

  -- 2) Validate journey / detect touch status
  SELECT journey_id, status, start_zone, end_zone, station_row_id
  INTO v_open_journey_id, v_status, v_start_zone, v_end_zone, v_station_row_id
  FROM journey.fn_validate_journey(v_card_id::bigint, p_station_id::smallint, NOW()::timestamptz);

  IF v_status IS NULL THEN
    p_message := 'validation_failed';
    RETURN;
  END IF;

  -- 3) Execute action based on status (same logic as yours)
  CASE
    WHEN v_status = 'touch_on' THEN
      PERFORM journey.fn_touch_on(v_card_id, p_station_id);
      p_message := 'touch_on';

    WHEN v_status = 'same_station_cancellation' THEN
      PERFORM journey.fn_cancellation_same_stop(v_open_journey_id, v_station_row_id);
      p_message := 'same_station_cancellation';

    WHEN v_status = 'incomplete_trip' THEN
      PERFORM journey.fn_end_incomplete_trip(v_card_id, v_open_journey_id, v_start_zone);
      PERFORM journey.fn_touch_on(v_card_id, p_station_id);
      p_message := 'incomplete_trip';

    WHEN v_status = 'touch_off' THEN
      PERFORM journey.fn_touch_off(v_card_id, v_station_row_id, v_open_journey_id, v_start_zone, v_end_zone);
      p_message := 'touch_off';

    ELSE
      p_message := 'unknown_status:' || v_status;
  END CASE;

  -- 4) Return latest balance
  SELECT balance_cents
  INTO p_balance_cents
  FROM card.rail_cards
  WHERE card_id = v_card_id;

EXCEPTION
  WHEN OTHERS THEN
    -- Production-grade: don’t leak internals; log in server logs, return clean message
    -- p_message := 'error';
    -- If you want more detail during dev:
    p_message := SQLSTATE || ':' || SQLERRM;
END;
$$;