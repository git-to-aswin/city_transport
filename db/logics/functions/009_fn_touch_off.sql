CREATE OR REPLACE FUNCTION fn_touch_off (
    p_card_id BIGINT,
    p_station_row_id SMALLINT,
    p_journey_id BIGINT,
    p_start_zone SMALLINT,
    p_end_zone SMALLINT
)
AS $$
DECLARE
    v_start_time TIMESTAMPTZ;
    v_end_time TIMESTAMPTZ;
BEGIN
    UPDATE journey.rail_journeys
    SET card_id = p_card_id,
        end_station_id = p_station_row_id,
        ended_at = NOW(),
        status = 'closed',
        updated_at = NOW()
    WHERE journey_id = p_journey_id
    RETURNING started_at,ended_at INTO (v_start_time, v_end_time);

    SELECT journey.fn_touch_off_fare(p_journey_id, p_card_id, p_start_zone, v_start_time, v_end_time);
END;
$$;