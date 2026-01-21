BEGIN;
DO $$
DECLARE
  v_card_id BIGINT;
  v_message TEXT;
  v_pass_id BIGINT;
  v_fare INT;
BEGIN
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('30001', 100000, 1)
  RETURNING card_id INTO v_card_id;

  v_fare := ref.fn_pass_fare_calc(7, ARRAY[1,2]::smallint[]);
  v_message := card.fn_purchase_pass(
    v_card_id,
    INTERVAL '7 days',
    NOW(),
    v_fare,
    ARRAY[1,2]::smallint[]
  );

  IF v_message NOT LIKE 'SUCCESS pass_id=%' THEN
    RAISE EXCEPTION 'fn_purchase_pass expected SUCCESS message, got %', v_message;
  END IF;

  v_pass_id := NULLIF(regexp_replace(v_message, '.*pass_id=', ''), '')::BIGINT;
  IF v_pass_id IS NULL THEN
    RAISE EXCEPTION 'fn_purchase_pass expected pass_id in message, got %', v_message;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM card.rail_passes
    WHERE pass_id = v_pass_id
      AND card_id = v_card_id
  ) THEN
    RAISE EXCEPTION 'fn_purchase_pass expected rail_passes row for pass_id=%', v_pass_id;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM card.railpass_zones
    WHERE pass_id = v_pass_id
      AND zone_id IN (1,2)
  ) THEN
    RAISE EXCEPTION 'fn_purchase_pass expected railpass_zones for pass_id=%', v_pass_id;
  END IF;
END $$;
ROLLBACK;
