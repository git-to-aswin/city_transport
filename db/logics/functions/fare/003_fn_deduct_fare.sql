-- Deduct fare from a card if sufficient balance exists.
-- Returns TRUE if deducted, FALSE otherwise.
-- Uses row-level locking to prevent race conditions (two taps at same time).

CREATE OR REPLACE FUNCTION card.fn_deduct_fare(
  p_card_id BIGINT,
  p_deduct_fare INT
) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_balance INT;
BEGIN
  IF p_deduct_fare IS NULL OR p_deduct_fare <= 0 THEN
    RAISE EXCEPTION 'p_deduct_fare must be > 0 (got %)', p_deduct_fare;
  END IF;

  -- Lock the card row so concurrent deductions don't double-spend.
  SELECT balance_cents
  INTO v_balance
  FROM card.rail_cards
  WHERE card_id = p_card_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN FALSE; -- card not found
  END IF;

  IF v_balance < p_deduct_fare THEN
    RETURN FALSE; -- insufficient funds
  END IF;

  UPDATE card.rail_cards
  SET balance_cents = balance_cents - p_deduct_fare,
      updated_at    = NOW(),
      last_used_at  = NOW()
  WHERE card_id = p_card_id;

  RETURN TRUE;
END;
$$;