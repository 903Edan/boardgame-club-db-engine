-- ============================================================================
-- PROJECT: Board Game Club ERP - Analytical Reporting Engine
-- DESCRIPTION: High-performance SQL queries for organizational metrics, 
--              member engagement tracking, and asset utilization analysis.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Active Member Session Density per Event
-- ----------------------------------------------------------------------------

-- Filter events hosting active sessions
CREATE VIEW GSEvent AS (
    SELECT event_id, name
    FROM Event e 
    JOIN GameSession gs ON e.event_id = gs.event
);

-- Compute baseline event attendee footprint
CREATE VIEW MemberInGSE AS (
    SELECT event_id, count(member) AS total
    FROM Participate p 
    JOIN GSEvent gse ON gse.event_id = p.event
    GROUP BY event_id
);

-- Compute actual game session participant footprint
CREATE VIEW MemPartiGS AS (
    SELECT event_id, count(member) AS parti
    FROM Participate p 
    JOIN GSEvent gse ON gse.event_id = p.event
    JOIN GameSession gs ON p.game_session = gs.session_id
    GROUP BY event_id
);

-- Final Output
SELECT 
    mgse.event_id, 
    (parti * 100.0 / total) AS session_participation_percentage
FROM MemberInGSE mgse
JOIN MemPartiGS mpgs ON mgse.event_id = mpgs.event_id;


-- ----------------------------------------------------------------------------
-- Game Inventory Utilization Tracker
-- ----------------------------------------------------------------------------

SELECT 
    bg.game_id, 
    bg.title, 
    COUNT(DISTINCT p.game_session) AS total_times_played
FROM BoardGames bg
JOIN GameSession gs ON bg.game_id = gs.boardgames
JOIN Participate p ON gs.session_id = p.game_session
GROUP BY bg.game_id, bg.title
ORDER BY total_times_played DESC;


-- ----------------------------------------------------------------------------
-- High-Demand Facilitator & Asset Mapping
-- ----------------------------------------------------------------------------

-- Map and aggregate executive hosting frequencies per title
CREATE VIEW GameFacilitated AS (
    SELECT boardgames, title, COUNT(gs.session_id) AS facilitated
    FROM GameSession gs 
    JOIN BoardGames bg ON gs.boardgames = bg.game_id
    GROUP BY boardgames, bg.title, executive
);

-- Final Output
SELECT 
    boardgames AS game_id, 
    title, 
    facilitated AS max_sessions_by_single_exec
FROM GameFacilitated 
WHERE facilitated = (SELECT MAX(facilitated) FROM GameFacilitated);


-- ----------------------------------------------------------------------------
-- Power-User Core Engagement Tracking
-- ----------------------------------------------------------------------------

-- Deduplicate and aggregate session activity per profile
CREATE VIEW MSessionCount AS (
    SELECT p.member AS member_id, m.name, COUNT(DISTINCT p.game_session) AS unique_sessions
    FROM Participate p
    JOIN Member m ON p.member = m.member_id
    GROUP BY p.member, m.name
);

-- Final Output
SELECT 
    member_id, 
    name, 
    unique_sessions AS total_sessions_played
FROM MSessionCount
WHERE unique_sessions = (SELECT MAX(unique_sessions) FROM MSessionCount);


-- ----------------------------------------------------------------------------
-- Event Cohort Sizing & Capacity Planning
-- ----------------------------------------------------------------------------
RAISE NOTICE 'Executing KPI 5: Event Cohort Sizing...';

SELECT 
    event AS event_id, 
    CASE 
        WHEN COUNT(game_session) = 0 THEN 0.0  
        ELSE COUNT(member) * 1.0 / COUNT(game_session) 
    END AS avg_participants_per_session
FROM Participate
GROUP BY event;


-- ============================================================================
-- ENVIRONMENT CLEANUP
-- Teardown intermediate processing views to maintain schema purity.
-- ============================================================================
DROP VIEW IF EXISTS MSessionCount CASCADE;
DROP VIEW IF EXISTS GameFacilitated CASCADE;
DROP VIEW IF EXISTS MemPartiGS CASCADE;
DROP VIEW IF EXISTS MemberInGSE CASCADE;
DROP VIEW IF EXISTS GSEvent CASCADE;

COMMIT;