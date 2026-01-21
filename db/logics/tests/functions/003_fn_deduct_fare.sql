BEGIN;
DO $$
DECLARE
  v_ok BOOLEAN;
  v_balance INT;
  v_card_id BIGINT;
BEGIN
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('20001', 5000, 1)
  RETURNING card_id INTO v_card_id;

  v_ok := card.fn_deduct_fare(v_card_id, 1200);
  IF v_ok IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'fn_deduct_fare expected TRUE, got %', v_ok;
  END IF;

  SELECT balance_cents INTO v_balance
  FROM card.rail_cards
  WHERE card_id = v_card_id;
  IF v_balance <> 3800 THEN
    RAISE EXCEPTION 'fn_deduct_fare expected balance 3800, got %', v_balance;
  END IF;

  v_ok := card.fn_deduct_fare(v_card_id, 10000);
  IF v_ok IS DISTINCT FROM FALSE THEN
    RAISE EXCEPTION 'fn_deduct_fare expected FALSE for insufficient funds, got %', v_ok;
  END IF;

  SELECT balance_cents INTO v_balance
  FROM card.rail_cards
  WHERE card_id = v_card_id;
  IF v_balance <> 3800 THEN
    RAISE EXCEPTION 'fn_deduct_fare expected unchanged balance 3800, got %', v_balance;
  END IF;
END $$;
ROLLBACK;
