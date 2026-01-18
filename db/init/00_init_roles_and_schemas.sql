-- Run inside railpay_local (POSTGRES_DB) on first init

-- 1) Create roles (LOGIN)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'railpay_admin') THEN
    CREATE ROLE railpay_admin LOGIN PASSWORD 'railPay1234!';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'railpay_app') THEN
    CREATE ROLE railpay_app LOGIN PASSWORD 'railPay5678!';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'railpay_ro') THEN
    CREATE ROLE railpay_ro LOGIN PASSWORD 'railPay9012!';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'railpay_dev') THEN
    CREATE ROLE railpay_dev LOGIN PASSWORD 'railPay3456!';
  END IF;
END $$;

-- 2) Lock down database access
REVOKE ALL ON DATABASE railpay_local FROM PUBLIC;
GRANT CONNECT ON DATABASE railpay_local TO railpay_admin, railpay_app, railpay_ro, railpay_dev;

-- 3) Create schemas (owned by admin)
CREATE SCHEMA IF NOT EXISTS core  AUTHORIZATION railpay_admin;
CREATE SCHEMA IF NOT EXISTS ref   AUTHORIZATION railpay_admin;
CREATE SCHEMA IF NOT EXISTS fare  AUTHORIZATION railpay_admin;
CREATE SCHEMA IF NOT EXISTS audit AUTHORIZATION railpay_admin;
ALTER DATABASE railpay_local OWNER TO railpay_admin;

-- 4) Schema usage: allow access but prevent object creation (no DDL)
GRANT USAGE ON SCHEMA core, ref, fare, audit TO railpay_app, railpay_ro, railpay_dev;

REVOKE CREATE ON SCHEMA core, ref, fare, audit FROM railpay_app, railpay_ro, railpay_dev;
-- (Only schema owner railpay_admin can CREATE/DROP/ALTER objects here)

-- 5) Default privileges: when railpay_admin creates tables, give proper perms automatically

-- App + Dev: read/write (no delete by default; you can enable per-table later)
ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA ref, fare, audit
  GRANT SELECT, INSERT, UPDATE ON TABLES TO railpay_app, railpay_dev;

ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA ref, fare, audit
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO railpay_app, railpay_dev;

-- Read-only role
ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA core, ref, fare, audit
  GRANT SELECT ON TABLES TO railpay_ro;

ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA core, ref, fare, audit
  GRANT USAGE, SELECT ON SEQUENCES TO railpay_ro;

-- Ref schema: App + Dev read-only (contains business reference data)
ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA ref
  GRANT SELECT ON TABLES TO railpay_app, railpay_dev;

ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA ref
  GRANT USAGE, SELECT ON SEQUENCES TO railpay_app, railpay_dev;

-- Ensure DELETE/TRUNCATE are not granted by default (explicitly)
ALTER DEFAULT PRIVILEGES FOR ROLE railpay_admin IN SCHEMA core, ref, fare, audit
  REVOKE DELETE, TRUNCATE ON TABLES FROM railpay_app, railpay_dev, railpay_ro;

-- 6) Set search_path
ALTER ROLE railpay_admin SET search_path = core, ref, fare, audit, public;
ALTER ROLE railpay_app   SET search_path = core, ref, fare, audit, public;
ALTER ROLE railpay_dev   SET search_path = core, ref, fare, audit, public;
ALTER ROLE railpay_ro    SET search_path = core, ref, fare, audit, public;