BEGIN;
DO $$
DECLARE
  v_pass_id INT;
  v_error_code INT;
  v_message VARCHAR;
  v_card_id BIGINT;
  v_fare INT;
BEGIN
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('TESTPASS0001', 100000, 1)
  RETURNING card_id INTO v_card_id;

  -- Valid 7-day pass, partial payment triggers deduction
  CALL card.sp_purchase_pass(
    'TESTPASS0001',
    NOW()::timestamp,
    7,
    1000,
    ARRAY[1,2]::smallint[],
    v_pass_id,
    v_error_code,
    v_message
  );

  IF v_error_code <> 0 THEN
    RAISE EXCEPTION 'expected success for 7-day pass, got error_code=% message=%', v_error_code, v_message;
  END IF;
  IF v_pass_id IS NULL THEN
    RAISE EXCEPTION 'expected pass_id for 7-day pass, got NULL message=%', v_message;
  END IF;
  IF v_message NOT LIKE 'SUCCESS pass_id=%' THEN
    RAISE EXCEPTION 'expected SUCCESS message, got %', v_message;
  END IF;
  IF NOT EXISTS (
    SELECT 1
    FROM card.rail_passes
    WHERE pass_id = v_pass_id
      AND card_id = v_card_id
  ) THEN
    RAISE EXCEPTION 'expected rail_passes row for pass_id=%', v_pass_id;
  END IF;

  -- Valid 28-day pass (full payment)
  v_fare := ref.fn_pass_fare_calc(28, ARRAY[1,2]::smallint[]);
  CALL card.sp_purchase_pass(
    'TESTPASS0001',
    NOW()::timestamp,
    28,
    v_fare,
    ARRAY[1,2]::smallint[],
    v_pass_id,
    v_error_code,
    v_message
  );

  IF v_error_code <> 0 THEN
    RAISE EXCEPTION 'expected success for 28-day pass, got error_code=% message=%', v_error_code, v_message;
  END IF;

  -- Invalid duration
  CALL card.sp_purchase_pass(
    'TESTPASS0001',
    NOW()::timestamp,
    10,
    1000,
    ARRAY[1]::smallint[],
    v_pass_id,
    v_error_code,
    v_message
  );

  IF v_error_code <> 2 THEN
    RAISE EXCEPTION 'expected invalid duration error_code=2, got % message=%', v_error_code, v_message;
  END IF;

  -- Insufficient balance
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('TESTPASS0002', 0, 1);

  CALL card.sp_purchase_pass(
    'TESTPASS0002',
    NOW()::timestamp,
    7,
    0,
    ARRAY[1,2]::smallint[],
    v_pass_id,
    v_error_code,
    v_message
  );

  IF v_error_code <> 3 THEN
    RAISE EXCEPTION 'expected insufficient balance error_code=3, got % message=%', v_error_code, v_message;
  END IF;

  -- Invalid card number
  CALL card.sp_purchase_pass(
    'NO_SUCH_CARD',
    NOW()::timestamp,
    7,
    1000,
    ARRAY[1]::smallint[],
    v_pass_id,
    v_error_code,
    v_message
  );

  IF v_error_code <> 1 THEN
    RAISE EXCEPTION 'expected invalid card error_code=1, got % message=%', v_error_code, v_message;
  END IF;
END $$;
ROLLBACK;
