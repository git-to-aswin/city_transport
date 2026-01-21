CREATE OR REPLACE FUNCTION card.fn_card_balance(
  p_card_number VARCHAR(16)
) RETURNS INT AS $$
BEGIN
  RETURN (
    SELECT balance_cents
    FROM card.rail_cards
    WHERE card_number = p_card_number
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION card.fn_card_balance(VARCHAR) TO railpay_app;
