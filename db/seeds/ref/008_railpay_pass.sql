INSERT INTO ref.railpay_passes
  (zone_count, weekly_pass_cents, monthly_yearly_pass_cents, is_zone_1, is_zone_2, status_active)
VALUES
  -- Including Zone 1 (Zone 1 to any other zone)
  -- 7 day pass $57.00, 28–325 day pass per day $6.84
  (2, 5700, 684, TRUE,  FALSE, 'active'),
  -- Excluding Zone 1 (number of zones travelled excluding Zone 1)
  -- 1 zone: $28.00 weekly, $3.90 per day
  (1, 2800, 390, FALSE, FALSE, 'active'),
  -- 2 zones: $40.00 weekly, $5.52 per day
  (2, 4000, 552, FALSE, FALSE, 'active'),
  -- 3 zones: $44.00 weekly, $6.08 per day
  (3, 4400, 608, FALSE, FALSE, 'active'),
  -- 4+ zones: $57.00 weekly, $6.84 per day (store as zone_count=4 and clamp in logic)
  (4, 5700, 684, FALSE, FALSE, 'active'),
  -- ONLY Zone 2
  (1, 3600, 432, FALSE, TRUE,  'active')
ON CONFLICT (zone_count, is_zone_1, is_zone_2)
DO UPDATE
SET weekly_pass_cents         = EXCLUDED.weekly_pass_cents,
    monthly_yearly_pass_cents = EXCLUDED.monthly_yearly_pass_cents,
    status_active             = EXCLUDED.status_active,
    updated_at                = NOW();