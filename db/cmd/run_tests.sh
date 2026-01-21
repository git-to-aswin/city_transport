#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="railpay_postgres"
DB_USER="railpay_app"
DB_NAME="railpay_local"

for f in db/logics/tests/functions/*.sql db/logics/tests/procedures/*.sql; do
  echo "Running $f"
  if ! docker exec -i "$DB_CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" < "$f"; then
    echo "❌ Failed: $f"
  else
    echo "✅ Passed: $f"
  fi
done
