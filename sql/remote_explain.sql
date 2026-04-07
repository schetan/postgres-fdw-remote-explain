-- ===================================================================
-- Test remote EXPLAIN functionality
-- ===================================================================
--
-- Tests the postgres_fdw.show_remote_plans GUC which displays execution
-- plans from foreign servers inline with local EXPLAIN output.
--
-- Test coverage:
-- - Backward compatibility (feature disabled by default)
-- - Remote plan display when enabled
-- - Toggle behavior (on/off)
-- - Multiple foreign scans (UNION ALL)
-- - InitPlans with subqueries
-- - Foreign joins (skipped in Phase 1)
--
-- TODU: Add EXPLAIN ANALYZE tests in Phase 2
--
-- Setup: Relies on objects from postgres_fdw.sql (loopback server, ft1, ft2)
-- Test order: postgres_fdw.sql -> query_cancel.sql -> remote_explain.sql

-- ===================================================================
-- Test 1: Backward compatibility - feature disabled (default)
-- ===================================================================
-- EXPLAIN VERBOSE output should NOT show remote plan
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 WHERE c1 = 1;

-- ===================================================================
-- Test 2: Enable feature and verify remote plan display
-- ===================================================================
SET postgres_fdw.show_remote_plans = on;

-- Verify setting
SHOW postgres_fdw.show_remote_plans;

-- Simple query - should show remote plan
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 WHERE c1 = 1;

-- Query with multiple conditions
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 WHERE c1 > 100 AND c2 < 5;

-- Query with ORDER BY
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 WHERE c1 > 100 ORDER BY c3 LIMIT 10;

-- Join query - pushed down join has scanrelid=0, skipped for now
-- TODU: Phase 2 should support same-server joins by iterating fs_base_relids
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1, ft2 t2 WHERE t1.c1 = t2.c1 AND t1.c1 = 1;

-- ===================================================================
-- Test 3: Disable feature again
-- ===================================================================
SET postgres_fdw.show_remote_plans = off;

-- Verify setting
SHOW postgres_fdw.show_remote_plans;

-- Should NOT show remote plan again
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 WHERE c1 = 1;

-- ===================================================================
-- Test 4: Feature works with other EXPLAIN options
-- ===================================================================
SET postgres_fdw.show_remote_plans = on;

-- With BUFFERS
EXPLAIN (VERBOSE, COSTS OFF, BUFFERS) SELECT * FROM ft1 WHERE c1 = 1;

-- ===================================================================
-- Test 5: Multiple foreign tables
-- ===================================================================
SET postgres_fdw.show_remote_plans = on;

EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1 WHERE c1 = 1
UNION ALL
SELECT * FROM ft1 WHERE c1 = 2;

-- ===================================================================
-- Test 6: InitPlan - Scalar subquery in WHERE clause
-- ===================================================================
SET postgres_fdw.show_remote_plans = on;

-- Scalar subquery - should show InitPlan in remote plan
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1 WHERE c1 = (SELECT MAX(c1) FROM ft1);

-- ===================================================================
-- Test 7: InitPlan - Multiple scalar subqueries
-- ===================================================================
-- Multiple subqueries - should show multiple InitPlans
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1
WHERE c1 > (SELECT MIN(c1) FROM ft1)
  AND c1 < (SELECT MAX(c1) FROM ft1);

-- ===================================================================
-- Test 8: InitPlan - NOT IN subquery
-- ===================================================================
-- NOT IN with subquery - should show InitPlan
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1
WHERE c1 NOT IN (SELECT c1 FROM ft1 WHERE c2 > 500);

-- ===================================================================
-- Cleanup: Reset to default
-- ===================================================================
RESET postgres_fdw.show_remote_plans;

-- Final verification
SHOW postgres_fdw.show_remote_plans;
