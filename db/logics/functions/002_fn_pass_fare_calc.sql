CREATE OR REPLACE FUNCTION ref.fn_pass_fare_calc(
    p_duration_days INT,
    p_valid_zones SMALLINT[]
) RETURNS INT AS $$
DECLARE
    v_fare_cents INT;
    v_is_zone_1 BOOLEAN;
    v_is_zone_2 BOOLEAN;
    num_zones INT;
BEGIN

    -- Validate duration: only 7 OR 28..365
    IF NOT (p_duration_days = 7 OR p_duration_days BETWEEN 28 AND 365) THEN
        RAISE EXCEPTION 'Invalid duration: % days. Only 7 or 28-365 days allowed.', p_duration_days;
    END IF;

    IF p_valid_zones IS NULL OR array_length(p_valid_zones, 1) IS NULL OR array_length(p_valid_zones, 1) = 0 THEN
        RAISE EXCEPTION 'p_valid_zones cannot be NULL/empty';
    END IF;

    -- Contains checks
    v_is_zone_1 := p_valid_zones @> ARRAY[1]::smallint[];
    v_is_zone_2 := p_valid_zones @> ARRAY[2]::smallint[];

    num_zones := array_length(p_valid_zones, 1);

    -- Clamp number of zones to 4 for fare calculation
    IF num_zones > 4 THEN
        num_zones := 4;
    END IF;

    -- Handle special case for Zone 2 only pass
    IF v_is_zone_2 AND NOT v_is_zone_1 AND num_zones = 1 THEN
        SELECT 
            CASE 
                WHEN p_duration_days = 7 THEN weekly_pass_cents
                WHEN p_duration_days BETWEEN 28 AND 365 THEN daily_pass_rate_cents * p_duration_days
            END
            INTO v_fare_cents
        FROM ref.railpay_passes
        WHERE is_zone_2 = TRUE 
            AND is_zone_1 = FALSE 
            AND zone_count = 1 
            AND status_active = 'active' 
        LIMIT 1;

        RETURN v_fare_cents;
    END IF;

    -- Zone 1 specific logic
    IF v_is_zone_1 THEN
        SELECT 
            CASE 
                WHEN p_duration_days = 7 THEN weekly_pass_cents
                WHEN p_duration_days BETWEEN 28 AND 365 THEN daily_pass_rate_cents * p_duration_days
            END
            INTO v_fare_cents
        FROM ref.railpay_passes
        WHERE is_zone_1 = TRUE
        LIMIT 1;

        RETURN v_fare_cents;
    END IF;

    -- General fare calculation based on number of zones
    SELECT
        CASE 
            WHEN p_duration_days = 7 THEN weekly_pass_cents
            WHEN p_duration_days BETWEEN 28 AND 365 THEN daily_pass_rate_cents * p_duration_days
        END
        INTO v_fare_cents
    FROM ref.railpay_passes
    WHERE zone_count = num_zones 
        AND status_active = 'active'
    LIMIT 1;

    RETURN v_fare_cents;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION ref.fn_pass_fare_calc(INT, SMALLINT[]) TO railpay_app, railpay_admin;
