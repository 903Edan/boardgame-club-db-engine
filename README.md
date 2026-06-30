# Board Game Club ERP: Database Design

A comprehensive database engine lifecycle project modeling a high-traffic Board Game Club domain ("Gotta Love Games"). This project covers the full spectrum of database engineering: informal domain modeling, schema design, validation testing, and advanced relational normalization theory.

## Tech Stack & Key Concepts
* **Database:** PostgreSQL
* **Languages:** SQL
* **Theoretical Frameworks:** Relational Algebra, Functional Dependencies, BCNF Decomposition, 3NF Synthesis, Chase Test Validation.

---

## Schema Design & Constraint Engineering
The database models interactions between club members, executive facilitators, event committees, inventory tracking, and active multi-table game sessions. 

### Advanced Integrity Features Implemented:
* **Custom Domain Constraints:** Created specialized domains (`NonNegInt`) and ENUM types (`StudyLevel`, `GameCategory`, `PhyCondit`) to ensure domain-level type-safety.
* **Complex Multi-Row Business Logic:** Documented and designed around constraints that natively fall outside standard DDL boundaries (e.g., verifying that a game copy isn't flagged as 'Damaged' prior to session allocation).

---
## Analytical Reporting & Business Intelligence

The database features a dedicated analytical reporting layer designed to extract key organizational metrics from the relational schema. These queries combine decoupled views, multi-table aggregations, and edge-case handling to deliver clean data insights:

### 1. Event Engagement & Member Session Density
* **Business Objective:** Calculate the precise percentage of active event attendees who successfully transitioned into concrete game sessions, filtering out events that hosted no active sessions.
* **Engineering Approach:** Utilizes sequential views (`GSEvent`, `MemberInGSE`, `MemPartiGS`) to isolate baseline event attendance from session tracking, applying float multiplication (`100.0`) to avoid integer division truncation in PostgreSQL.

```sql
-- Step 1: Filter events hosting active sessions
CREATE VIEW GSEvent AS (
    SELECT event_id, name
    FROM event e 
    JOIN GameSession gs ON e.event_id = gs.event
);

-- Step 2: Compute baseline event attendee footprint
CREATE VIEW MemberInGSE AS (
    SELECT event_id, count(member) AS total
    FROM Participate p 
    JOIN GSEvent gse ON gse.event_id = p.event
    GROUP BY event_id
);

-- Step 3: Compute actual game session participant footprint
CREATE VIEW MemPartiGS AS (
    SELECT event_id, count(member) AS parti
    FROM Participate p 
    JOIN GSEvent gse ON gse.event_id = p.event
    JOIN GameSession gs ON p.game_session = gs.session_id
    GROUP BY event_id
);

-- Final Execution: Generate metrics
SELECT mgse.event_id, (parti * 100.0 / total) AS percentage
FROM MemberInGSE mgse
JOIN MemPartiGS mpgs ON mgse.event_id = mpgs.event_id;

```

---

### 2. Game Inventory Utilization Tracker

* **Business Objective:** Audit the full board game library by reporting the total number of times each unique title has been deployed across game sessions.
* **Engineering Approach:** Bridges catalog definitions (`BoardGames`) with operational logs (`GameSession`) and transaction matrices (`Participate`), implementing data deduplication via `COUNT(DISTINCT ...)` and ordering output to isolate under-utilized core assets.

```sql
SELECT bg.game_id, bg.title, COUNT(DISTINCT p.game_session) AS total_times_played
FROM BoardGames bg
JOIN GameSession gs ON bg.game_id = gs.boardgames
JOIN Participate p ON gs.session_id = p.game_session
GROUP BY bg.game_id, bg.title
ORDER BY total_times_played;

```

---

### 3. High-Demand Facilitator Mapping

* **Business Objective:** Identify which specific board game has been hosted/facilitated the absolute most by a single executive club member.
* **Engineering Approach:** Constructs a consolidated tracking view (`GameFacilitated`) to aggregate hosting frequencies, then evaluates the global maximum dynamically through a correlated subquery (`WHERE facilitated = (SELECT MAX...)`) to handle ties seamlessly.

```sql
-- Step 1: Map and aggregate executive hosting frequencies per title
CREATE VIEW GameFacilitated AS (
    SELECT boardgames, title, count((boardgames, executive)) AS facilitated
    FROM GameSession gs 
    JOIN Boardgames bg ON gs.boardgames = bg.game_id
    GROUP BY boardgames, bg.title, executive
);

-- Final Execution: Extract absolute peak matching records
SELECT *
FROM GameFacilitated 
WHERE facilitated = (SELECT MAX(facilitated) FROM GameFacilitated);

```

---

### 4. Power-User Core Engagement Tracking

* **Business Objective:** Isolate and award the core club member(s) who have actively participated as a player in the highest number of unique game sessions.
* **Engineering Approach:** Couples member identity records with structural participation records, evaluating cumulative player footprints against the mathematical maximum boundary limit to support robust edge-case ties.

```sql
-- Step 1: Deduplicate and aggregate session activity per profile
CREATE VIEW MSessionCount AS (
    SELECT p.member, m.name, COUNT(DISTINCT p.game_session) AS unique_sessions
    FROM Participate p
    JOIN Member m ON p.member = m.member_id
    GROUP BY p.member, m.name
);

-- Final Execution: Return matching top-tier power users
SELECT * FROM MSessionCount
WHERE unique_sessions = (SELECT MAX(unique_sessions) FROM MSessionCount);

```

---

### 5. Event Cohort Sizing & Capacity Planning

* **Business Objective:** Compute the mathematical average participant ratio per individual game session, grouped natively by the parent event container.
* **Engineering Approach:** Features advanced conditional runtime evaluation logic (`CASE WHEN`) to inspect session footprints, gracefully emitting safe fallback boundaries (`0`) for zero-session gatherings to completely insulate the pipeline against traditional database division-by-zero errors.

```sql
SELECT event, 
       CASE 
           WHEN COUNT(game_session) = 0 THEN 0  
           ELSE COUNT(member) * 1.0 / COUNT(game_session) 
       END AS avg_participants
FROM Participate
GROUP BY event;

```

```

```

