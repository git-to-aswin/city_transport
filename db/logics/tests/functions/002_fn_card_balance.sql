BEGIN;
DO $$
DECLARE
  v_balance INT;
  v_missing INT;
  v_card_id BIGINT;
BEGIN
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('12345', 4200, 1)
  RETURNING card_id INTO v_card_id;

  v_balance := card.fn_card_balance('12345');
  IF v_balance <> 4200 THEN
    RAISE EXCEPTION 'fn_card_balance expected 4200 got %', v_balance;
  END IF;

  v_missing := card.fn_card_balance('99999');
  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'fn_card_balance expected NULL for missing card, got %', v_missing;
  END IF;
END $$;
ROLLBACK;
