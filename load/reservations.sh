#!/usr/bin/env bash
set -euo pipefail
: "${SQL_SERVER:?SQL_SERVER required}" "${SQL_USER:?SQL_USER required}" "${SQL_PASSWORD:?SQL_PASSWORD required}"
WORKERS="${WORKERS:-8}"
if ! [[ "$WORKERS" =~ ^[0-9]+$ ]] || ((WORKERS < 1 || WORKERS > 32)); then
  echo 'WORKERS must be 1..32' >&2; exit 2
fi
PRODUCT_ID="${PRODUCT_ID:-1}"
if ! [[ "$PRODUCT_ID" =~ ^[0-9]+$ ]]; then echo 'Invalid PRODUCT_ID' >&2; exit 2; fi
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
start="$SECONDS"
for ((i=1;i<=WORKERS;i++)); do
  (
    key="bench-$i-$RANDOM-$RANDOM"
    /opt/mssql-tools18/bin/sqlcmd -S "$SQL_SERVER" -U "$SQL_USER" -P "$SQL_PASSWORD" -C -b -d IndexPulse \
      -Q "EXEC dbo.ReserveProduct @RequestKey=N'$key', @ProductId=$PRODUCT_ID, @Quantity=1;" \
      >"$tmp/$i.out" 2>"$tmp/$i.err" || echo 1 >"$tmp/$i.failed"
  ) &
done
wait
failures="$(find "$tmp" -name '*.failed' | wc -l)"
echo "workers=$WORKERS failures=$failures elapsed_seconds=$((SECONDS-start))"
if (( failures > 0 )); then cat "$tmp"/*.err >&2; exit 1; fi
