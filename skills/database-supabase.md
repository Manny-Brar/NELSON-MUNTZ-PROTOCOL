---
name: database-supabase
description: "Peak performance Postgres and Supabase database skill with RLS and multi-tenant focus"
---

# Database Supabase - Peak Performance Database Skill

## Purpose
Create secure, performant database architectures using Supabase and PostgreSQL with proper RLS policies, multi-tenant isolation, and optimized query patterns.

---

## THE MULTI-TENANT SACRED RULE

**Every tenant-scoped table MUST have:**
```sql
tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE
```

**Every query MUST filter by tenant_id:**
```typescript
// ALWAYS
const { data } = await supabase
  .from("jobs")
  .select("*")
  .eq("tenant_id", tenantId);  // ← NEVER FORGET

// NEVER
const { data } = await supabase
  .from("jobs")
  .select("*");  // ← SECURITY BREACH
```

---

## PHASE 1: TABLE DESIGN PATTERNS

### Standard Table Template
```sql
CREATE TABLE table_name (
  -- Primary key
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Multi-tenant (if tenant-scoped)
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

  -- Core columns
  name text NOT NULL,
  status text DEFAULT 'pending',
  metadata jsonb DEFAULT '{}',

  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX idx_table_name_tenant_id ON table_name(tenant_id);
CREATE INDEX idx_table_name_status ON table_name(status);

-- Updated_at trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON table_name
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### JSONB Usage Guidelines

**GOOD uses for JSONB:**
```sql
-- Flexible metadata (unknown structure)
metadata jsonb DEFAULT '{}',

-- Settings/config (varies by tenant)
settings jsonb DEFAULT '{}',

-- Equipment details (many optional fields)
equipment_details jsonb,

-- Audit/history (append-only logs)
changes jsonb[]
```

**BAD uses for JSONB:**
```sql
-- Frequently queried fields (use columns)
-- BAD: data->>'customer_name'
-- GOOD: customer_name text

-- Required fields (use NOT NULL columns)
-- BAD: data->>'email'
-- GOOD: email text NOT NULL

-- Foreign keys (can't enforce referential integrity)
-- BAD: data->>'user_id'
-- GOOD: user_id uuid REFERENCES users(id)
```

---

## PHASE 2: RLS POLICY PATTERNS

### Basic Tenant Isolation Policy
```sql
-- CRITICAL: Always enable RLS first
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Tenant isolation policy
CREATE POLICY "tenant_isolation" ON jobs
  FOR ALL
  TO authenticated
  USING (tenant_id = (SELECT auth.uid()));  -- Wrapped for performance
```

### Performance-Optimized RLS

**The (SELECT ...) wrapper is CRITICAL:**
```sql
-- BAD (evaluates per row - SLOW on large tables)
CREATE POLICY "slow_policy" ON big_table
  USING (user_id = auth.uid());

-- GOOD (caches result - 100x+ faster)
CREATE POLICY "fast_policy" ON big_table
  USING (user_id = (SELECT auth.uid()));
```

### Multi-Table RLS with Security Definer

When RLS needs to check another table, use security definer functions:

```sql
-- Create helper function
CREATE OR REPLACE FUNCTION user_tenant_ids()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT tenant_id
  FROM tenant_users
  WHERE user_id = auth.uid()
$$;

-- Use in policy (bypasses RLS on tenant_users)
CREATE POLICY "tenant_member_access" ON jobs
  FOR ALL
  TO authenticated
  USING (tenant_id IN (SELECT user_tenant_ids()));
```

### Separate Policies by Operation

```sql
-- More granular control
CREATE POLICY "select_own" ON jobs
  FOR SELECT
  TO authenticated
  USING (tenant_id = (SELECT get_user_tenant_id()));

CREATE POLICY "insert_own" ON jobs
  FOR INSERT
  TO authenticated
  WITH CHECK (tenant_id = (SELECT get_user_tenant_id()));

CREATE POLICY "update_own" ON jobs
  FOR UPDATE
  TO authenticated
  USING (tenant_id = (SELECT get_user_tenant_id()))
  WITH CHECK (tenant_id = (SELECT get_user_tenant_id()));

CREATE POLICY "delete_own" ON jobs
  FOR DELETE
  TO authenticated
  USING (tenant_id = (SELECT get_user_tenant_id()));
```

---

## PHASE 3: INDEXING STRATEGY

### Index Decision Framework

| Query Pattern | Index Type | Example |
|---------------|------------|---------|
| Equality (`=`) | B-tree | `tenant_id`, `status` |
| Range (`>`, `<`, `BETWEEN`) | B-tree | `created_at`, `amount` |
| Text search (`LIKE 'foo%'`) | B-tree | `name` (prefix only) |
| Full text search | GIN | `to_tsvector(description)` |
| JSONB key lookup | GIN | `metadata` |
| Array contains | GIN | `tags` |

### Required Indexes for RLS

**ALWAYS index columns used in RLS policies:**
```sql
-- If policy uses tenant_id
CREATE INDEX idx_jobs_tenant_id ON jobs(tenant_id);

-- If policy uses user_id
CREATE INDEX idx_jobs_user_id ON jobs(user_id);

-- Compound index for common query patterns
CREATE INDEX idx_jobs_tenant_status ON jobs(tenant_id, status);
```

### Index Performance Impact

```
Without index on 1M rows: 11,000ms
With index on 1M rows:    7ms

Without index on 100K rows: timeout
With index on 100K rows:    2ms
```

---

## PHASE 4: QUERY OPTIMIZATION

### Efficient Pagination
```typescript
// BAD: OFFSET-based (slow on large tables)
const { data } = await supabase
  .from("jobs")
  .select("*")
  .range(1000, 1010);  // Scans 1010 rows

// GOOD: Cursor-based (consistent performance)
const { data } = await supabase
  .from("jobs")
  .select("*")
  .gt("id", lastSeenId)
  .order("id", { ascending: true })
  .limit(10);
```

### Efficient Joins
```typescript
// BAD: Fetching related data separately
const { data: jobs } = await supabase.from("jobs").select("*");
const { data: customers } = await supabase.from("customers").select("*");
// Then join in JS...

// GOOD: Use Supabase relationships
const { data } = await supabase
  .from("jobs")
  .select(`
    *,
    customer:customers(id, name, phone),
    technician:technicians(id, name)
  `)
  .eq("tenant_id", tenantId);
```

### Efficient Aggregations
```typescript
// For counts, use head: true
const { count } = await supabase
  .from("jobs")
  .select("*", { count: "exact", head: true })
  .eq("tenant_id", tenantId)
  .eq("status", "completed");
```

---

## PHASE 5: MIGRATION BEST PRACTICES

### Migration File Structure
```sql
-- supabase/migrations/20260113_create_equipment_table.sql

-- Description: Create equipment tracking table for tenant assets
-- Author: Nelson Muntz
-- Date: 2026-01-13

-- Up migration
CREATE TABLE equipment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id),
  equipment_type text NOT NULL,
  brand text,
  model text,
  serial_number text,
  install_date date,
  warranty_expiry date,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "tenant_isolation" ON equipment
  FOR ALL
  TO authenticated
  USING (tenant_id = (SELECT get_user_tenant_id()));

-- Create indexes
CREATE INDEX idx_equipment_tenant_id ON equipment(tenant_id);
CREATE INDEX idx_equipment_customer_id ON equipment(customer_id);

-- Add trigger
CREATE TRIGGER set_equipment_updated_at
  BEFORE UPDATE ON equipment
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Migration Safety Rules

1. **Never drop columns in production** - Mark deprecated, remove later
2. **Always add columns as nullable or with defaults**
3. **Create indexes CONCURRENTLY** in production
4. **Test migrations on branch database first**
5. **Keep migrations idempotent when possible**

```sql
-- Safe column addition
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS priority int DEFAULT 0;

-- Safe index creation
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_jobs_priority ON jobs(priority);
```

---

## PHASE 6: SUPABASE-SPECIFIC PATTERNS

### Edge Function Database Access
```typescript
// supabase/functions/my-function/index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  // Use service role for admin operations
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!  // Bypasses RLS
  );

  // Or use user's JWT for tenant-scoped operations
  const authHeader = req.headers.get("Authorization");
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader! } } }
  );
});
```

### Realtime Subscriptions
```typescript
// Subscribe to changes for a tenant
const subscription = supabase
  .channel("jobs-changes")
  .on(
    "postgres_changes",
    {
      event: "*",
      schema: "public",
      table: "jobs",
      filter: `tenant_id=eq.${tenantId}`
    },
    (payload) => {
      console.log("Change received:", payload);
    }
  )
  .subscribe();
```

### Database Functions
```sql
-- Create reusable function for common operations
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT tenant_id
  FROM tenant_users
  WHERE user_id = auth.uid()
  LIMIT 1
$$;

-- Use in queries
SELECT * FROM jobs WHERE tenant_id = get_user_tenant_id();
```

---

## PHASE 7: PERFORMANCE MONITORING

### Identify Slow Queries
```sql
-- Enable query logging
ALTER DATABASE postgres SET log_min_duration_statement = 1000;  -- Log queries > 1s

-- Check pg_stat_statements
SELECT
  query,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Analyze Query Plans
```sql
-- See what Postgres is actually doing
EXPLAIN ANALYZE
SELECT * FROM jobs
WHERE tenant_id = 'uuid-here'
AND status = 'pending';

-- Look for:
-- - Seq Scan (bad on large tables - add index)
-- - Nested Loop (may need JOIN optimization)
-- - High actual rows vs estimated (statistics outdated)
```

### PostgREST Metrics
```sql
-- Enable plan analysis for API queries
ALTER ROLE authenticator SET pgrst.db_plan_enabled TO true;
```

---

## DATABASE CHECKLIST

Before deploying any database change:

```
[ ] Multi-Tenant
    [ ] Table has tenant_id column (if tenant-scoped)
    [ ] tenant_id has foreign key to tenants
    [ ] tenant_id is indexed

[ ] RLS
    [ ] RLS is enabled on table
    [ ] Policies use (SELECT ...) wrapper for auth functions
    [ ] Policies specify TO authenticated
    [ ] Tested with multiple test tenants

[ ] Performance
    [ ] Columns in WHERE clauses are indexed
    [ ] Columns in RLS policies are indexed
    [ ] EXPLAIN ANALYZE shows reasonable plan
    [ ] No sequential scans on large tables

[ ] Migration
    [ ] Migration is idempotent (IF NOT EXISTS)
    [ ] New columns have defaults or are nullable
    [ ] Migration tested on branch database

[ ] Security
    [ ] No service_role key in client code
    [ ] RLS policies restrict by tenant
    [ ] Sensitive columns handled appropriately
```

---

## COMMON MISTAKES TO AVOID

### RLS Mistakes
- ❌ Forgetting to enable RLS (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`)
- ❌ Using `auth.uid()` directly (wrap in `SELECT`)
- ❌ Policy with `USING (true)` (everyone can access)
- ❌ Missing index on RLS policy columns

### Query Mistakes
- ❌ OFFSET pagination on large tables
- ❌ Missing tenant_id filter in queries
- ❌ N+1 queries (fetch related data separately)
- ❌ SELECT * when only needing specific columns

### Migration Mistakes
- ❌ Dropping columns without deprecation period
- ❌ Adding NOT NULL column without default
- ❌ Running heavy migrations during peak traffic
- ❌ Not testing on branch database first

---

## RESOURCES

- [Supabase RLS Docs](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [RLS Performance Best Practices](https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv)
- [Multi-Tenant Architecture with RLS](https://www.antstack.com/blog/multi-tenant-applications-with-rls-on-supabase-postgress/)
- [Supabase Best Practices](https://www.leanware.co/insights/supabase-best-practices)

---

*Data integrity is non-negotiable. Security is not optional.*
