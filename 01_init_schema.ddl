-- Constraints from domain specification that could not be enforced without
-- assertions or triggers
-- 
-- 1) The num_copy in BoardGames is equal to the count(title) in GameCopy.
-- 
-- 2) Ensuring the organizing team stays the same for the multiple
-- occurrences of any event.
-- 
-- 3) Ensuring the date of enrollment for all executive members are no 
-- later than any event they first held in the club team stays the same 
-- for the multiple occurrences of any event.
-- 
-- 4) boardgames in GameSession cannot be referenced to the copy with 
-- 'Damaged'physical condition.
-- 
-- Constraints from domain specification that could have been enforced 
-- without assertions or triggers but were not enforced:
-- 
-- 1) UNIQUE constraint of email_id could be added but we assume that 
-- email's uniqueness is enforced externally.
-- 
-- 2) CHECK constraint that ensuring acquired_date in BoardGamesis less 
-- than or equal to the current date. Instead, it allows users to input 
-- estimated acquired_date.
-- 
-- 3) The NOT NULL constraint of game_session in Participate as there 
-- exists events that have no game played.
-- 
-- 4) ENUM type for role in Executive to restrict the types of executives'
-- role, instead it allows executive members to enter in their role
-- without further constraint, allowing flexibility.
-- 
-- Extra constraints that are not from domain specification:
-- 
-- 1)  Added NOT NULL constraints to fields whenever it is logically
-- necessary (e.g. acquired_date in BoardGames).
-- 
-- 2)  Defined NonNegInt as a domain to ensure some attributes are 
-- strictly greater or equal to 0 when appropriate (e.g. min_limit,
-- max_limit of BoardGames player limit).
-- 
-- 3) Used ENUM types to enforce StudyLevel, GameCategory and PhyCondit 
-- to be restricted values to a predefined set that are mentioned in 
-- the domain.
-- 
-- Assumptions made for the schema:
-- 
-- 1) Game titles in BoardGames are unique, which allows GameCopy to
-- reference them by name instead of game_id.
-- 
-- 2)  Executive members who played the game in the game session they 
-- held were included in Participate because they should be also counted
-- as players.
-- 
-- 3) Each game session, event and copy of board game are identified by 
-- their ids, instead of their name, date, location or game title
-- respectively.
-- 
-- 4)  All game sessions have the same duration as the event and the 
-- boardgame

-- 1) Game titles in BoardGames are unique, which allows
-- GameCopy to reference them by name instead of game_id.


DROP SCHEMA IF EXISTS A3GLG CASCADE;
CREATE SCHEMA A3GLG;
SET SEARCH_PATH TO A3GLG;


-- Possible values for member's study level, game's category and game's 
-- physical condition.
CREATE TYPE StudyLevel AS ENUM ('Undergraduate', 'Graduate', 'Alumni');

CREATE TYPE GameCategory AS ENUM ('Strategy', 'Party', 'Deck-building', 
'Role-playing', 'Social-deduction');

CREATE TYPE PhyCondit AS ENUM ('New', 'Lightly-used', 'Worn', 'Incomplete',
 'Damaged');

CREATE DOMAIN NonNegInt AS INT CHECK (VALUE >= 0);


-- A member, its name <name>, and the email id of the member <email_id>
-- and its level of study <level>.
CREATE TABLE Member (
	member_id INT PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
	email_id VARCHAR(200) NOT NULL,
	level STUDYLEVEL NOT NULL
);


-- An executive member, which is a member holding a specific role.
CREATE TABLE Executive (
    member INT PRIMARY KEY NOT NULL REFERENCES Member (member_id),
    role VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL
);

-- A board game, identified by <game_id>, with a title <title>,
-- category <category>, player limits <min_limit> and <max_limit>,
-- the publisher <publisher>, release year <released_year>,
-- acquisition date <acquired_date>,and the number of copies <num_copy>
CREATE TABLE BoardGames (
	game_id INT PRIMARY KEY,
	title VARCHAR(200) NOT NULL UNIQUE,
	category GAMECATEGORY NOT NULL,
	min_limit NonNegInt NOT NULL,
	max_limit NonNegInt NOT NULL,
	publisher VARCHAR(200) NOT NULL,
	released_year CHAR(4) NOT NULL, 
	acquired_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	num_copy NonNegInt NOT NULL,
	check(min_limit <= max_limit)
);


-- A copy of a game, identified by its id <copy_id> and its
-- physical condition <physical_condition>.
CREATE TABLE GameCopy(
	copy_id INT PRIMARY KEY,
	game_name VARCHAR(200) NOT NULL REFERENCES BoardGames (title),
	physical_condition PHYCONDIT NOT NULL
);

-- An event, identified by <event_id>, with its name <name>, 
-- location <location>, which date it held <date>, start time <start_time>,
-- and end time <end_time>.
CREATE TABLE  Event(
	event_id INT PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
	location VARCHAR(200) NOT NULL,
	date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	start_time TIMESTAMP WITHOUT TIME ZONE  NOT NULL,
	end_time TIMESTAMP WITHOUT TIME ZONE  NOT NULL,
	check(start_time <= end_time )
);

-- A game session <session_id>, which is hold in an event and specific 
-- board game is played, managed by an executive and linked to an event.
CREATE TABLE GameSession (
	session_id INT PRIMARY KEY,
	boardgames INT NOT NULL REFERENCES BoardGames(game_id),
	executive INT NOT NULL REFERENCES Executive(member),
	event INT NOT NULL REFERENCES Event(event_id),
	UNIQUE (boardgames, executive, event)
);

-- A committee, identified by <committee_id>, responsible for managing 
-- an event <event>, and led by a member <lead>.
CREATE TABLE Committee(
	committee_id INT PRIMARY KEY,
	event INT NOT NULL REFERENCES Event(event_id),
	lead  INT NOT NULL REFERENCES Member (member_id)
);

-- Participation record of a member <member> in an event <event>
-- with the game session it participated <game_session>, only inlcuding
-- the players
CREATE TABLE Participate (
	member INT NOT NULL REFERENCES Member (member_id),
	event INT NOT NULL REFERENCES Event(event_id),
	game_session INT REFERENCES GameSession (session_id),
	UNIQUE (member, event, game_session)
);

-- A committee member, identified by <member>, who belongs to a
-- committee <committee>.
CREATE TABLE CommitteeMember(
	committee INT REFERENCES Committee (committee_id),
	member INT PRIMARY KEY REFERENCES Member (member_id)
);

