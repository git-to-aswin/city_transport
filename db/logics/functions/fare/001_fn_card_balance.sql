CREATE OR REPLACE FUNCTION card.fn_card_balance(
    p_card_number INT
) RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT balance_cents
        FROM card.rail_cards
        WHERE card_number = p_card_number
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION card.fn_card_balance(INT) TO railpay_app;
