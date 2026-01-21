ALTER TABLE ref.railpay_passes
DROP CONSTRAINT railpay_passes_pkey;

ALTER TABLE ref.railpay_passes
ADD CONSTRAINT railpay_passes_pkey
PRIMARY KEY (zone_count, is_zone_1, is_zone_2);

ALTER TABLE ref.railpay_passes
RENAME COLUMN monthly_yearly_pass_cents TO daily_pass_rate_cents;