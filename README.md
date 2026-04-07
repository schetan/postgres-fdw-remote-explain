  # postgres_fdw Remote EXPLAIN

  PostgreSQL Foreign Data Wrapper extension with remote EXPLAIN support.

  ## Overview

  This is an enhanced version of PostgreSQL's `postgres_fdw` that adds the ability to display
  execution plans from foreign servers inline with local EXPLAIN output.

  ## Features

  - **GUC Variable**: `postgres_fdw.show_remote_plans` (default: off)
  - **Text-Based Plans**: Fetches plans using `EXPLAIN (VERBOSE, COSTS)`
  - **Complete Plans**: Shows nested plans (Limit→Sort→Scan) naturally
  - **InitPlan Support**: Handles subqueries with multiple foreign scans
  - **Error Handling**: Warnings don't break EXPLAIN
  - **Backward Compatible**: Off by default, zero impact when disabled

  ## Usage

  ```sql
  -- Enable remote plan display
  SET postgres_fdw.show_remote_plans = on;

  -- Now EXPLAIN shows remote execution plans
  EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM foreign_table WHERE id = 1;
  ```

  ## Installation

  Requires PostgreSQL 19devel or later.

  ```sql
  make
  make install
  ```

  Then in PostgreSQL:

  CREATE EXTENSION postgres_fdw;

  ## Current Limitations (Phase 1)

  - Foreign joins (scanrelid == 0) are skipped
  - Cross-server joins work fine (become local joins)
  - No EXPLAIN ANALYZE support yet

  ## TODU

  - Phase 2: Support same-server joins by iterating fs_base_relids
  - Phase 3: Add EXPLAIN ANALYZE support with instrumentation

  ## Based On

  PostgreSQL postgres_fdw (07 April 2026)

  License

  PostgreSQL License - see LICENSE file

  ## Author

  Chetan Suttraway
