BEGIN;
DO $$
DECLARE
  v INT;
BEGIN
  -- Zone 1 included, weekly
  v := ref.fn_pass_fare_calc(7, ARRAY[1,2]::smallint[]);
  IF v <> 5700 THEN
    RAISE EXCEPTION 'fn_pass_fare_calc zone1 weekly: expected 5700 got %', v;
  END IF;

  -- Zone 2 only, weekly (example expected 2800 based on your seed)
  v := ref.fn_pass_fare_calc(7, ARRAY[2]::smallint[]);
  IF v <> 3600 THEN
    RAISE EXCEPTION 'fn_pass_fare_calc zone2-only weekly: expected 2800 got %', v;
  END IF;

  -- Excluding zone1, 3 zones, 30 days (daily_rate * days)
  v := ref.fn_pass_fare_calc(30, ARRAY[2,3,4]::smallint[]);
  IF v <> (608 * 30) THEN
    RAISE EXCEPTION 'fn_pass_fare_calc excl z1 (3 zones) 30d: expected % got %', (608 * 30), v;
  END IF;

  -- Clamp to 4+ zones
  v := ref.fn_pass_fare_calc(28, ARRAY[2,3,4,5,6]::smallint[]);
  IF v <> (684 * 28) THEN
    RAISE EXCEPTION 'fn_pass_fare_calc clamp 4+ 28d: expected % got %', (684 * 28), v;
  END IF;
END $$;

ROLLBACK;
