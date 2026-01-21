CREATE OR REPLACE PROCEDURE card.sp_purchase_pass(
  IN p_card_number VARCHAR(16),
  IN p_valid_from TIMESTAMP,
  IN p_duration_days INT,
  IN p_amount_cents INT,
  IN p_valid_zones SMALLINT[],
  OUT p_pass_id INT,
  OUT p_error_code INT,
  OUT p_message VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_card_id BIGINT;
  v_pass_fare_cents INT;
  v_purchasing_interval INTERVAL;
  v_purchase_result TEXT;
BEGIN
  -- Initialize output parameters
  p_pass_id := NULL;
  p_error_code := 0;
  p_message := 'Success';

  -- GET card ID from card number
  SELECT c.card_id
  INTO v_card_id
  FROM card.rail_cards c
  WHERE c.card_number = p_card_number;

  IF v_card_id IS NULL THEN
    p_error_code := 1;
    p_message := 'Invalid card number';
    RETURN;
  END IF;

  -- Validate duration
  IF NOT (p_duration_days = 7 OR p_duration_days BETWEEN 28 AND 365) THEN
    p_error_code := 2;
    p_message := 'Invalid duration';
    RETURN;
  END IF;

  -- TODO: Check for overlapping passes

  -- Calculate rail_pass fares
  v_purchasing_interval := make_interval(days => p_duration_days);
  SELECT ref.fn_pass_fare_calc(p_duration_days, p_valid_zones)
  INTO v_pass_fare_cents;

  IF v_pass_fare_cents > p_amount_cents THEN
    IF card.fn_deduct_fare(v_card_id, v_pass_fare_cents - p_amount_cents) THEN
      -- Update the pass details
      SELECT card.fn_purchase_pass(
        v_card_id,
        v_purchasing_interval,
        p_valid_from::timestamptz,
        v_pass_fare_cents,
        p_valid_zones
      )
      INTO v_purchase_result;
    ELSE
      p_error_code := 3;
      p_message := 'Insufficient balance';
      RETURN;
    END IF;
  ELSE
    SELECT card.fn_purchase_pass(
      v_card_id,
      v_purchasing_interval,
      p_valid_from::timestamptz,
      v_pass_fare_cents,
      p_valid_zones
    )
    INTO v_purchase_result;
  END IF;

  p_message := v_purchase_result;
  IF v_purchase_result LIKE 'SUCCESS pass_id=%' THEN
    p_pass_id := NULLIF(regexp_replace(v_purchase_result, '.*pass_id=', ''), '')::INT;
  END IF;
END;
$$;
