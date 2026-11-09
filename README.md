# IndexPulse
### SQL Server Performance, Integrity & Recovery Engineering

IndexPulse is a practical **T-SQL / SQL Server** engineering repository covering query tuning, indexes, transaction safety, idempotent stock reservations, consistency audits, and backup/restore procedures.

## Scope

- Relational model for customers, products, orders and order lines, with foreign keys and validation constraints.
- Deterministic set-based data generator for **50,000 orders** (when executed).
- Baseline vs. sargable queries with `SET STATISTICS IO, TIME ON` and execution-plan review.
- Composite/covering indexes with explicit justification.
- `dbo.ReserveProduct` stored procedure with `UPDLOCK`, `HOLDLOCK`, transaction rollback, idempotency and movement ledger.
- Two-session locking exercise, integrity audits, Query Store and maintenance queries.
- Full database backup, verification and isolated restore for a locally administered SQL Server instance.

**Benchmarks are not pre-filled:** run the scripts and report the actual logical reads and elapsed time in [BENCHMARK_REPORT.md](docs/BENCHMARK_REPORT.md).

## Setup

Requirements: SQL Server 2022 or newer and a T-SQL client (SSMS or VS Code SQL Server extension). Docker is optional.

```bash
# Export SA_PASSWORD first. Then:
docker compose up -d
```

Connection: `localhost,14334`, SQL login `sa`, password from your environment. The SQL Server container stores files in a persistent volume.

Execute **in order**, as separate SQL query scripts in the same connection:

1. `scripts/00_schema.sql` — database and tables.
2. `scripts/01_seed.sql` — reproducible customers, products and 50,000 orders.
3. `scripts/02_baseline.sql` — original query and IO/time metrics.
4. `scripts/03_indexes.sql` — carefully chosen indexes.
5. `scripts/04_optimized.sql` — rewritten query and query-plan comparison.
6. `scripts/05_reservation_procedure.sql` — concurrency-safe inventory reservation.
7. `scripts/06_reserve_calls.sql` — normal and replay scenarios.
8. `scripts/07_integrity_audit.sql` — asserts consistency; run any time.
9. `scripts/08_monitoring.sql` — index/Query Store observations.
10. `scripts/09_backup_restore.sql` — DBA-only backup/restore exercise.

The files use `GO` batch separators supported by SSMS and `sqlcmd`. For the concurrency exercise, see [CONCURRENCY_RUNBOOK.md](docs/CONCURRENCY_RUNBOOK.md).

### Backup notes

Before running `09_backup_restore.sql` against the Docker instance, create `/var/opt/mssql/backups` inside the container and give the SQL Server service account write access. It creates a second `IndexPulse_Recovery` database, leaving the source intact. For Azure SQL Database, use managed point-in-time recovery instead of native `BACKUP DATABASE`.

## Operational discipline

Run the schema and seed scripts **only** on a disposable local database. Backup/restore and index-analysis operations require adequate privileges and should never be executed blindly on a production server. No performance claims are made without measurements.
