@set card_id = 131

-- Insert a user for testing
insert into card.rail_cards (card_number, balance_cents, card_type_id)
values (98765442712, 9000, 1);

-- Journey result
select rj.journey_id , rj.card_id , rj.status, rjf.start_zone , rjf.end_zone, rjf.fare_cents , rjf.fare_reason, rj.start_station_id   from journey.rail_journeys rj 
left join journey.rail_journey_fares rjf  on rj.journey_id  = rjf.journey_id  
where rj.card_id = :card_id;

-- No journey started yet
SELECT * from journey.fn_validate_journey(:card_id :: integer, 100 :: smallint, NOW() :: timestamp with time zone);

-- Starting a journy at ROUTE 18
select journey.fn_touch_on(:card_id :: BIGINT,  148 :: smallint);

select * from journey.rail_journeys rj 
left join journey.rail_journey_fares rjf  on rj.journey_id  = rjf.journey_id  
where rj.card_id = :card_id;

-- incomplete trip
select journey.fn_end_incomplete_trip(:card_id :: BIGINT, 38::bigint, 8:: smallint);

-- Cancelling with same station within 15min
select journey.fn_cancellation_same_stop(39::bigint, 148::smallint);

-- journey tap off
select journey.fn_touch_off(:card_id ::bigint, 91::smallint, 40::bigint, 8::smallint,1::smallint);

--------------------------------------
---        STORE PROCEDURE         ---
--------------------------------------
-- IN  p_card_number VARCHAR(16)
-- IN  p_station_id  SMALLINT
-- OUT p_balance_cents INT
-- OUT p_message TEXT

@set card_number = 98765442718

-- Insert a user for testing
insert into card.rail_cards (card_number, balance_cents, card_type_id)
values (:card_number, 9000, 1);

-- TOUCH ON
CALL card.sp_detect_touch(:card_number :: VARCHAR(16), 1001:: smallint, null, null);

-- TOUCH OFF AT same station within 15 min
CALL card.sp_detect_touch(:card_number :: VARCHAR(16), 1001:: smallint, null, null);

-- TOUCH ON AT some irrelavent station not connecting to the route
CALL card.sp_detect_touch(:card_number :: VARCHAR(16), 4920:: smallint, null, null);

-- PROPER TOUCH OFF 
CALL card.sp_detect_touch(:card_number :: VARCHAR(16), 1090:: smallint, null, null);

-- TOUCH ON
CALL card.sp_detect_touch(:card_number :: VARCHAR(16), 4920:: smallint, null, null);