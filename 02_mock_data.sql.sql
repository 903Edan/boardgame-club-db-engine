-- Cleaning existing data points to avoid potential error
TRUNCATE TABLE Participate CASCADE;
TRUNCATE TABLE GameSession CASCADE;
TRUNCATE TABLE Executive CASCADE;
TRUNCATE TABLE CommitteeMember CASCADE;
TRUNCATE TABLE Committee CASCADE;
TRUNCATE TABLE Member CASCADE;
TRUNCATE TABLE Event CASCADE;
TRUNCATE TABLE BoardGames CASCADE;
TRUNCATE TABLE GameCopy CASCADE;

INSERT INTO BoardGames (game_id, title, category, min_limit, max_limit, publisher, released_year, acquired_date, num_copy) VALUES
(1, 'Blood on the Clocktower', 'Social-deduction', 5, 20, 'The Pandemonium Institute', '2019', '2024-01-01', 1),
(2, 'Turing Machine', 'Strategy', 1, 4, 'Scorpion Masqué', '2022', '2024-01-01', 1),
(3, 'Cascadia', 'Strategy', 1, 4, 'Flatout Games', '2021', '2024-01-01', 1),
(4, 'Cryptid', 'Strategy', 3, 5, 'Osprey Games', '2018', '2024-01-01', 1),
(5, 'Avalon', 'Social-deduction', 5, 10, 'Indie Boards & Cards', '2012', '2024-01-01', 2),
(6, '7 Wonders', 'Deck-building', 3, 7, 'Repos Production', '2010', '2024-01-01', 2);

INSERT INTO GameCopy (copy_id, game_name, physical_condition) VALUES
(1, 'Blood on the Clocktower', 'New'),
(2, 'Turing Machine', 'Lightly-used'),
(3, 'Cascadia', 'Worn'),
(4, 'Cryptid', 'New'),
(5, 'Avalon', 'Lightly-used'),
(6, 'Avalon', 'New'),
(7, '7 Wonders', 'Worn'),
(8, '7 Wonders', 'Lightly-used');

INSERT INTO Event (event_id, name, location, date, start_time, end_time) VALUES
(1, 'Weekly Boardgame Event', 'GLG Room', '2024-03-05', '2024-03-05 18:00:00', '2024-03-05 22:00:00'),
(2, 'Basement Clocktower', 'GLG Basement', '2024-03-05', '2024-03-05 22:00:00', '2024-03-05 23:59:00'),
(3, 'Weekly Boardgame Event', 'GLG Room', '2024-03-12', '2024-03-12 18:00:00', '2024-03-12 22:00:00'),
(4, 'Basement Clocktower', 'GLG Basement', '2024-03-12', '2024-03-12 22:00:00', '2024-03-12 23:59:00'),
(5, 'Winter Break Social', 'Outdoor Park', '2024-01-10', '2024-01-10 12:00:00', '2024-01-10 17:00:00');

INSERT INTO Member (member_id, name, email_id, level) VALUES
(1, 'Jason', 'jason@example.com', 'Graduate'),
(2, 'Zach', 'zach@example.com', 'Graduate'),
(3, 'Josh', 'josh@example.com', 'Alumni'),
(4, 'Eryka', 'eryka@example.com', 'Undergraduate'),
(5, 'Tawfiq', 'tawfiq@example.com', 'Undergraduate'),
(6, 'Jimbo', 'jimbo@example.com', 'Undergraduate'),
(7, 'Evelyn', 'evelyn@example.com', 'Undergraduate'),
(8, 'Christian', 'christian@example.com', 'Undergraduate'),
(9, 'Grace', 'grace@example.com', 'Undergraduate'),
(10, 'Ella', 'ella@example.com', 'Undergraduate'),
(11, 'Cameron', 'cameron@example.com', 'Undergraduate'),
(12, 'Honda', 'honda@example.com', 'Undergraduate'),
(13, 'Justin', 'justin@example.com', 'Undergraduate'),
(14, 'Ari', 'ari@example.com', 'Undergraduate'),
(15, 'Max', 'max@example.com', 'Undergraduate'),
(16, 'Akshay', 'akshay@example.com', 'Undergraduate');

INSERT INTO Executive (member, role, start_date) VALUES
(1, 'Organizer of Weekly Boardgame Event', '2024-01-01'),
(2, 'Organizer of Basement Clocktower', '2024-02-01'),
(3, 'Organizer of Winter Break Social', '2023-12-15'),
(4, 'Event Organizer', '2023-11-10');


INSERT INTO GameSession (session_id, boardgames, executive, event) VALUES
(101, 2, 4, 1), -- Eryka facilitated "Turing Machine" on 5th March event
(102, 6, 1, 1), -- Jason facilitated "7 Wonders" on 5th March event
(103, 3, 4, 3), -- Eryka facilitated "Cascadia" on 12th March event
(104, 5, 1, 3), -- Jason facilitated "Avalon" on 12th March event
(105, 6, 3, 3), -- Josh facilitated "7 Wonders" on 12th March event
(106, 1, 2, 2), -- Zach facilitated "Blood on the Clocktower" on 5th March
(107, 1, 2, 4); -- Zach facilitated "Blood on the Clocktower" on 12th March

INSERT INTO Participate (member, event, game_session) VALUES
-- 5th March Weekly Event
(3, 1, 101), (4, 1, 101), (9, 1, 101), -- "Turing Machine" (Eryka, Josh, Grace)
(5, 1, 102), (6, 1, 102), (7, 1, 102), (8, 1, 102), -- "7 Wonders" (Tawfiq, Jimbo, Evelyn, Christian)

-- 12th March Weekly Event
(9, 3, 103), (7, 3, 103), (10, 3, 103), -- "Cascadia" (Grace, Evelyn, Ella)
(1, 3, 104), (6, 3, 104), (5, 3, 104), (11, 3, 104), (2, 3, 104), (12, 3, 104), -- "Avalon" (Jason, Jimbo, Tawfiq, Cameron, Zach, Honda)
(3, 3, 105), (13, 3, 105), (14, 3, 105), (15, 3, 105), -- "7 Wonders" (Josh, Justin, Ari, Max)

-- "Blood on the Clocktower" Sessions
(6, 2, 106), (5, 2, 106), (1, 2, 106), (7, 2, 106), (12, 2, 106), (16, 2, 106), -- 5th March "Blood on the Clocktower" (Zach, Jimbo, Tawfiq, Jason, Evelyn, Honda, Akshay)
(6, 4, 107), (5, 4, 107), (1, 4, 107), (7, 4, 107), (12, 4, 107), (16, 4, 107), -- 12th March "Blood on the Clocktower" (Same members)

-- Winter Break Social event
(4, 5, NULL),  -- Eryka participated
(7, 5, NULL); -- Josh participated as lead)

INSERT INTO Committee (committee_id, event, lead) VALUES
(1, 5, 3); -- Josh led the Winter Break Social event

INSERT INTO CommitteeMember (committee, member) VALUES
(1, 4), -- Eryka assisted in the Winter Break Social
(1, 5); -- Josh as the leader in Winter Break Social





