CREATE OR REPLACE FUNCTION card.fn_purchase_pass (
  p_card_id              BIGINT,
  p_purchasing_interval  INTERVAL,
  p_valid_from           TIMESTAMPTZ,
  p_fare                 INT,
  p_valid_zones          SMALLINT[]
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_pass_id BIGINT;
  v_missing SMALLINT;
BEGIN
    -- Validate zones exist in ref.travel_zones
    SELECT array_agg(z ORDER BY z)
    INTO v_missing
    FROM (
        SELECT DISTINCT unnest(p_valid_zones) AS z
        EXCEPT
        SELECT zone_id FROM ref.travel_zones
    ) m;

    IF v_missing IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid zone_id(s): %', v_missing;
    END IF;
    
    -- Insert pass
    INSERT INTO card.rail_passes (card_id, purchasing_interval, valid_from, price_cents)
    VALUES (p_card_id, p_purchasing_interval, p_valid_from, p_fare)
    RETURNING pass_id INTO v_pass_id;

    -- Insert zones for this pass
    INSERT INTO card.railpass_zones (pass_id, zone_id)
    SELECT v_pass_id, z
    FROM (SELECT DISTINCT unnest(p_valid_zones) AS z) d;

    RETURN 'SUCCESS pass_id=' || v_pass_id;
END;
$$;