-- Sample data for Projectarium
-- Only insert default projects if the table is empty
INSERT INTO projects (name, description, path, file, priority, status, language)
SELECT * FROM (VALUES
    ('WotR', 'Wizards of the Rift', '/home/sean/code/paused/godot/Wizards-of-the-Rift/', '', 0, 'Abandoned', 'Godot'),
    ('LearnScape', 'General learning visualizer', '/home/sean/code/paused/LearnScape/', 'learnscape.py', 0, 'Abandoned', 'Python'),
    ('ROMs', 'ROM emulation optimization', '/home/sean/code/future/ROMs/', '', 0, 'Backlog', 'C'),
    ('goverse', 'Go VCS application', '/home/sean/code/active/go/goverse/', 'cli/main.go', 0, 'Active', 'Go'),
    ('projectarium', 'Project progress tracker', '/home/sean/code/active/python/projectarium/', 'projectarium.py', 0, 'Active', 'Python'),
    ('snr', 'Search and replace plugin', '/home/sean/.config/nvim/lua/snr/', 'init.lua', 0, 'Active', 'Lua'),
    ('todua', 'Todo list for Neovim', '/home/sean/.config/nvim/lua/todua/', 'init.lua', 0, 'Active', 'Lua'),
    ('macro-blues', 'Custom macropad firmware', '/home/sean/code/active/c/macro-c.BLUEs/', 'macro-c.BLUEs', 0, 'Active', 'C'),
    ('leetcode', 'Coding interview practice', '/home/sean/code/paused/leetcode/', '', 0, 'Active', 'Python'),
    ('TestTaker', 'ChatGPT->Python test maker', '/home/sean/code/paused/TestTaker/', 'testtaker.py', 0, 'Active', 'Python'),
    ('Mission-Uplink', 'TFG Mission Uplink', '/home/sean/code/tfg/Mission-Uplink/', 'README.md', 0, 'Active', 'Go,C'),
    ('Sorter', 'Sorting algoithm visualizer', '/home/sean/code/done/Sorter/', 'sorter.py', 0, 'Done', 'Python'),
    ('landing-page', 'Cute application launcher', '/home/sean/code/done/landing-page/', 'landing-page.py', 0, 'Done', 'Python')
) AS v(name, description, path, file, priority, status, language)
WHERE NOT EXISTS (SELECT 1 FROM projects LIMIT 1);
