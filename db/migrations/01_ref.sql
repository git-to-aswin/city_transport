-- Make sure schema exists (safe if already created)
CREATE SCHEMA IF NOT EXISTS ref;

-- 1) travel_zone
CREATE TABLE IF NOT EXISTS ref.travel_zones (
  zone_id SMALLINT PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2) station_zones
CREATE TABLE IF NOT EXISTS ref.stations (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

  station_id SMALLINT NOT NULL,
  station_name VARCHAR(25) NOT NULL,
  zone_id    SMALLINT NOT NULL REFERENCES ref.travel_zones(zone_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- prevents duplicate mapping rows for same station-zone
  CONSTRAINT station_zones_station_zone_uk UNIQUE (station_id, zone_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_stations__station_id ON ref.stations(station_id);

-- 3) two_hour_window
CREATE TABLE IF NOT EXISTS ref.two_hour_windows (
    zone_count SMALLINT NOT NULL PRIMARY KEY,
    time_window INTERVAL NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT two_time_window_check CHECK (time_window > INTERVAL '0 minutes')
);

-- 4) fare_amount
CREATE TABLE IF NOT EXISTS ref.railpay_money (
  zone_count SMALLINT PRIMARY KEY,

  base_fare_cents    INT NOT NULL CHECK (base_fare_cents >= 0),
  capping_fare_cents INT NOT NULL CHECK (capping_fare_cents >= 0),

  is_zone_1     BOOLEAN NOT NULL DEFAULT FALSE,
  is_zone_2 BOOLEAN NOT NULL DEFAULT FALSE,

  status_active TEXT NOT NULL DEFAULT 'active'
    CHECK (status_active IN ('active', 'expired', 'paused')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- prevent conflicting flags
  CONSTRAINT railpay_money_zone_flags_chk
    CHECK (NOT (is_zone_1 AND is_zone_2))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_railpay_money__status_active ON ref.railpay_money(zone_count, is_zone_1, is_zone_2, status_active);

-- 5) fare_pass
CREATE TABLE IF NOT EXISTS ref.railpay_passes (
  zone_count SMALLINT PRIMARY KEY,

  weekly_pass_cents  INT NOT NULL CHECK (weekly_pass_cents >= 0),
  monthly_yearly_pass_cents INT NOT NULL CHECK (monthly_yearly_pass_cents >= 0),

  is_zone_1    BOOLEAN NOT NULL DEFAULT FALSE,
  is_zone_2 BOOLEAN NOT NULL DEFAULT FALSE,

  status_active TEXT NOT NULL DEFAULT 'active'
    CHECK (status_active IN ('active', 'expired', 'paused')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- prevent conflicting flags
  CONSTRAINT railpay_pass_zone_flags_chk
    CHECK (NOT (is_zone_1 AND is_zone_2))  
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_railpay_pass__status_active ON ref.railpay_passes(zone_count, is_zone_1, is_zone_2, status_active);

-- 6) railpay_card_types
CREATE TABLE IF NOT EXISTS ref.railpay_card_types (
    card_type_id SMALLINT PRIMARY KEY,
    card_type_name VARCHAR(25) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_railpay_card_types__is_active ON ref.railpay_card_types(card_type_id, is_active);

-- 7) rail_routes
CREATE TABLE IF NOT EXISTS ref.rail_routes (
  route_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  route_name VARCHAR(50) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8) route_stations
CREATE TABLE IF NOT EXISTS ref.rail_route_stations (
  route_id INT NOT NULL REFERENCES ref.rail_routes(route_id) ON DELETE CASCADE,
  station_id SMALLINT NOT NULL REFERENCES ref.stations(station_id),
  stop_sequence SMALLINT NOT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  PRIMARY KEY (route_id, stop_sequence),
  CONSTRAINT rail_route_station_unique UNIQUE (route_id, station_id)
);

-- Fast: “all stations for a route in order”
CREATE INDEX IF NOT EXISTS idx_route_stations__route_seq
ON ref.rail_route_stations(route_id, stop_sequence);

-- Fast: “which routes pass through this station?”
CREATE INDEX IF NOT EXISTS idx_route_stations__station
ON ref.rail_route_stations(station_id, route_id);