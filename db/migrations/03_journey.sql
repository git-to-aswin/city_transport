-- Make sure schema exists (safe if already created)
CREATE SCHEMA IF NOT EXISTS journey;

-- 1) journeys
CREATE TABLE IF NOT EXISTS journey.rail_journeys (
    journey_id BIGINT GENERATED ALWAYS AS IDENTITY UNIQUE,
    
    card_id BIGINT NOT NULL REFERENCES card.rail_cards(card_id),

    status TEXT NOT NULL DEFAULT 'open'
      CHECK (status IN ('open', 'closed', 'cancelled','incomplete')),
    
    rail_route_id INT REFERENCES ref.rail_routes(route_id),

    start_station_id SMALLINT NOT NULL REFERENCES ref.stations(id),
    end_station_id SMALLINT REFERENCES ref.stations(id),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (journey_id, started_at)
) PARTITION BY RANGE (started_at);

-- Create monthly partitions for journeys
CREATE TABLE IF NOT EXISTS journey.rail_journeys_2026_01
PARTITION OF journey.rail_journeys
FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE IF NOT EXISTS journey.rail_journeys_2026_02
PARTITION OF journey.rail_journeys
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

-- Default partition for future dates
CREATE TABLE IF NOT EXISTS journey.rail_journeys_default
PARTITION OF journey.rail_journeys DEFAULT;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_rail_journeys__open_latest
ON journey.rail_journeys (card_id, started_at DESC)
WHERE end_station_id IS NULL;

CREATE UNIQUE INDEX uidx_one_open_journey_per_card
ON journey.rail_journeys (card_id, journey_id, started_at)
WHERE status = 'open';

-- 2) journey_fares
CREATE TABLE IF NOT EXISTS journey.rail_journey_fares (
  fare_id BIGINT GENERATED ALWAYS AS IDENTITY,

  journey_id BIGINT NOT NULL,
  journey_started_at TIMESTAMPTZ NOT NULL,

  start_zone SMALLINT NOT NULL REFERENCES ref.travel_zones(zone_id),
  end_zone   SMALLINT REFERENCES ref.travel_zones(zone_id),

  zones_travelled SMALLINT GENERATED ALWAYS AS (
    CASE
      WHEN end_zone IS NOT NULL THEN ABS(end_zone - start_zone) + 1
      ELSE NULL
    END
  ) STORED,

  fare_reason TEXT NOT NULL DEFAULT 'full_fare'
    CHECK (fare_reason IN (
      'full_fare', 'incomplete_journey', 'capped_fare', 'penalty_fare',
      'concession_fare', 'public_holiday_fare', 'special_event_fare',
      'other', 'railpass_fare'
    )),

  fare_cents INT CHECK (fare_cents >= 0),
  fare_calculated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Partitioned table: PK must include partition key
  PRIMARY KEY (fare_id, created_at),

  CONSTRAINT rail_journey_fares_journey_fk
    FOREIGN KEY (journey_id, journey_started_at)
    REFERENCES journey.rail_journeys (journey_id, started_at)
    ON DELETE CASCADE
) PARTITION BY RANGE (created_at);

-- Create monthly partitions for journey_fares
CREATE TABLE IF NOT EXISTS journey.rail_journey_fares_2026_01
PARTITION OF journey.rail_journey_fares
FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE IF NOT EXISTS journey.rail_journey_fares_2026_02
PARTITION OF journey.rail_journey_fares
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

-- Default partition for future dates
CREATE TABLE IF NOT EXISTS journey.rail_journey_fares_default
PARTITION OF journey.rail_journey_fares DEFAULT;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_rail_journey_fares__journey_id ON journey.rail_journey_fares(journey_id);