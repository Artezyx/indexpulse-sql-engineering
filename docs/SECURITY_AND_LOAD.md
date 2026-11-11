# SQL Server bounded concurrency profile

Install sqlcmd and GNU parallel or use the shell script below. Use only a
disposable seeded IndexPulse database; never point the script at production.

The benchmark exercises the same stored procedure with a **unique** request
key per worker, and records error count and wall-clock duration. It does not
assert an invented transaction-per-second result.

```bash
export SQL_SERVER=localhost,14334 SQL_USER=sa SQL_PASSWORD='<local-admin-password>'
bash load/reservations.sh
```

For realistic application measurements, replace SA with an account assigned
the `indexpulse_app` database role, and benchmark at least 10, 25 and 50
parallel requests. Verify ledger conservation, deadlocks, lock waits, p95
latency, throughput, SQL CPU and logical reads.

The baseline and optimized plans in scripts/02 and scripts/04 are useful
for evidence but are not performance guarantees.
