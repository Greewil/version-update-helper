TEST_BRANCH='monorepo_equals'
TEST_COMMAND='vuh lv'
TEST_EXPECTED_TEXT=$'MOD_1,MOD_2,MOD_3 modules was selected interactively\n
\n
[38;5;61m(vuh : RECURSION) Handling module: MOD_1[0m\n
\n
getting local version\n
local: 1.2.3\n
\n
[38;5;61m(vuh : RECURSION) Handling module: MOD_2[0m\n
\n
getting local version\n
local: 2.2.2\n
\n
[38;5;61m(vuh : RECURSION) Handling module: MOD_3[0m\n
\n
getting local version\n
local: 3.2.1'
