CREATE OR REPLACE sp_detect_touch (
    IN p_card_number VARCHAR(16),
    IN p_station_id SMALLINT,
    OUT p_balance_cents SMALLINT
    OUT p_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_card_id BIGINT;
    v_open_journey_id BIGINT;
    v_status VARCHAR(10);
    v_start_zone SMALLINT;
    v_end_zone SMALLINT;
    v_station_row_id SMALLINT;
BEGIN
    -- get card_id
    SELECT card_id INTO v_card_id FROM card.rail_cards WHERE card_number = p_card_number;

    -- check if it same journey or new
    SELECT journey_id , status, start_zone, end_zone, station_row_id 
        INTO (v_open_journey_id, v_status, v_start_zone, v_end_zone, v_station_row_id)
    FROM journey.fn_validate_journey(card_id, p_station_id)
    
    -- close the open_journey and detect the fare
    CASE
        WHEN v_status = 'touch_on' THEN
            -- touch ON
            SELECT * FROM ref.fn_touch_on(v_card_id, v_station_row_id);

        WHEN v_status = 'same_station_cancellation' THEN
            -- touch OFF at same station 
            SELECT * FROM ref.fn_cancellation_same_stop(v_open_journey_id, v_station_row_id);

        WHEN v_status = 'incomplete_trip' THEN
            -- no touch OFF for old journey
            SELECT * FROM ref.fn_end_incomplete_trip(v_card_id, v_open_journey_id, v_start_zone);
            
            -- touch ON
            SELECT * FROM ref.fn_touch_on(v_card_id, v_station_row_id);
            
        WHEN v_status = 'touch_off' THEN
            -- touch OFF 
            
            -- Close the old record with this station
END;