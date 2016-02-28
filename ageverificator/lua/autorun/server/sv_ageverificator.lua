-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.2

if SERVER then

if not AGECHECK_LANGUAGE then
	include( "ageverificator_config.lua" )
end

-- Make sure we always get valid Zodiacs from the player's net message
VALID_ZODIACS = AGECHECK_ZODIACS

util.AddNetworkString( "agecheck_send" )
util.AddNetworkString( "agecheck_onplayerconnect" )
util.AddNetworkString( "agecheck_checknecessity" )

-- Since we shift from multiple entries per STEAM-ID to single ones with timestamps, it's the easiest way to just create a new table
function ageverify_upgradeAgeTable()

	ServerLog( "[WARNING] Age Verification: FLUSHING agecheck DATABASE TO UPDATE TO THE LATEST DATABASE VERSION!\n" )
	
	local query = "DROP TABLE agecheck; CREATE TABLE agecheck ( id INTEGER PRIMARY KEY AUTOINCREMENT, times INTEGER, steamid TEXT, name TEXT, age INTEGER, day INTEGER, month INTEGER, year INTEGER, zodiac TEXT, date DATETIME DEFAULT CURRENT_TIMESTAMP )"
	local result = sql.Query( query )
	
end

-- This simply deletes entries older than a month
function ageverify_cleanupTable()

	ServerLog( "Age Verification: Performing cleanup of old entries...\n" )
	
	local query = "DELETE FROM agecheck WHERE date <= datetime('now', '-1 month')"
	local result = sql.Query( query )
	
end

-- This function was taken from the AWarn 2 plugin here: http://forums.ulyssesmod.net/index.php/topic,7125.0.html
-- It's nice to alter existing functions for your own purpose. I've got no idea of LUA and doing stuff from scratch is hard sometimes
function ageverify_checkAgeTable()
	-- Check existance and/or create the table that will hold the entered data
	if sql.TableExists( "agecheck" ) then
		ServerLog( "Age Verification: agecheck Table is existing!\n" )
		
		-- Add date column if not exists
		-- Get table info
		local query = "PRAGMA table_info(agecheck)"
		local result = sql.Query( query )
		local addDate = true
		
		-- Check if column 'date' is in there, if not we add it
		for k, v in pairs( result ) do
			if v["name"] == "date" then
				addDate = false
			end
		end
		
		if addDate then
			ageverify_upgradeAgeTable()
		end
		
	else
		local query = "CREATE TABLE agecheck ( id INTEGER PRIMARY KEY AUTOINCREMENT, times INTEGER, steamid TEXT, name TEXT, age INTEGER, day INTEGER, month INTEGER, year INTEGER, zodiac TEXT, date DATETIME DEFAULT CURRENT_TIMESTAMP )"
		result = sql.Query( query )
		ServerLog( "Age Verification: Creating Age Verification Table...\n" )
		if sql.TableExists( "agecheck" ) then
			ServerLog( "Age Verification: Age Verification Table created sucessfully.\n" )
		else
			ServerLog( "[ERROR] Age Verification: Trouble creating the Age Verification Table\n" )
			ServerLog( "[ERROR] Age Verification: " .. sql.LastError( result ).."\n" )
		end
	end
	
	-- Check existance and/or create the table that will hold people who passed enough times
	if sql.TableExists( "agecheck_done" ) then
		ServerLog( "Age Verification: agecheck_done Table is existing!\n" )
	else
		local query = "CREATE TABLE agecheck_done ( id INTEGER PRIMARY KEY AUTOINCREMENT, steamid TEXT, name TEXT )"
		result = sql.Query( query )
		ServerLog( "Age Verification: Creating Age Verification Done Table...\n" )
		if sql.TableExists( "agecheck" ) then
			ServerLog( "Age Verification: Age Verification Done Table created sucessfully.\n" )
		else
			ServerLog( "[ERROR] Age Verification: Trouble creating the Age Verification Done Table\n" )
			ServerLog( "[ERROR] Age Verification: " .. sql.LastError( result ).."\n" )
		end
	end
	
	ageverify_cleanupTable()
end
hook.Add( "Initialize", "age_check_init", ageverify_checkAgeTable )

-- I'm not sure if people could change the net messages, I suspect that is easy, so we make sure
-- the received Zodiac is one that we offered him to choose
function ageverify_isZodiacValid( zodiac )
	return table.HasValue( VALID_ZODIACS, zodiac )
end

-- This is a painful function that checks if the day and month entered matches
-- the zodiac sign, credits to Heady for making it
-- It overlaps sometimes due to the fact that multiple online sources round off the days differently
function ageverify_isValidZodiacDate( day_, month_, zodiac )
	local day = tonumber( day_ )
	local month = tonumber( month_ )
	
	-- "Aries" / "Widder"
	if zodiac == VALID_ZODIACS[1] then
		if ( day >= 21 and month == 3 ) or ( day <= 20 and month == 4 ) then
			return true
		end
	-- "Taurus" / "Stier"
	elseif zodiac == VALID_ZODIACS[2] then
		if ( day >= 21 and month == 4 ) or ( day <= 21 and month == 5 ) then
			return true	
		end
	-- "Gemini" / "Zwillinge"
	elseif zodiac == VALID_ZODIACS[3] then
		if ( day >= 21 and month == 5 ) or ( day <= 21 and month == 6 ) then
			return true
		end
	-- "Cancer" / "Krebs"
	elseif zodiac == VALID_ZODIACS[4] then
		if ( day >= 22 and month == 6 ) or ( day <= 22 and month == 7 ) then
			return true
		end
	-- "Leo" / "Löwe"
	elseif zodiac == VALID_ZODIACS[5] then
		if ( day >= 23 and month == 7 ) or ( day <= 23 and month == 8 ) then
			return true
		end
	-- "Virgo" / "Jungfrau"
	elseif zodiac == VALID_ZODIACS[6] then
		if ( day >= 23 and month == 8 ) or ( day <= 23 and month == 9 ) then
			return true
		end
	-- "Libra" / "Waage"
	elseif zodiac == VALID_ZODIACS[7] then
		if ( day >= 23 and month == 9 ) or ( day <= 23 and month == 10 ) then
			return true
		end
	-- "Scorpio" / "Skorpion"
	elseif zodiac == VALID_ZODIACS[8] then
		if ( day >= 23 and month == 10 ) or ( day <= 22 and month == 11 ) then
			return true
		end
	-- "Saggitarius" / "Schütze"
	elseif zodiac == VALID_ZODIACS[9] then
		if ( day >= 23 and month == 11 ) or ( day <= 21 and month == 12 ) then
			return true
		end
	-- "Capricornus" / "Steinbock"
	elseif zodiac == VALID_ZODIACS[10] then
		if ( day >= 21 and month == 12 ) or ( day <= 20 and month == 1 ) then
			return true
		end
	-- "Aquarius" / "Wassermann"
	elseif zodiac == VALID_ZODIACS[11] then
		if ( day >= 20 and month == 1 ) or ( day <= 19 and month == 2 ) then
			return true
		end
	-- "Pisces" / "Fische"
	elseif zodiac == VALID_ZODIACS[12] then
		if ( day >= 19 and month == 2 ) or ( day <= 20 and month == 3 ) then
			return true
		end
	end
	
	return false
end

-- Taken from stackoverflow and modified
-- Source: https://stackoverflow.com/questions/12542853/how-to-validate-if-a-string-is-a-valid-date-or-not-in-lua
function ageverify_isValidDate( d, m, y )

	if d < 0 or d > 31 or m < 0 or m > 12 or y < 0 then
		-- Cases that don't make sense
		return false
	elseif m == 4 or m == 6 or m == 9 or m == 11 then 
		-- Apr, Jun, Sep, Nov can have at most 30 days
		return d <= 30
	elseif m == 2 then
		-- Feb
		if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
			-- if leap year, days can be at most 29
			return d <= 29
		else
			-- else 28 days is the max
			return d <= 28
		end
	else 
		-- all other months can have at most 31 days
		return d <= 31
	end
	
end

-- Approximately calculating the amount of seconds it will take until this person is finally 
-- in the age to join the server
-- To prevent publishing of people's birthdates on ban websites, we add up to 5 days from the ban length
function ageveryify_getSecondsUntilAge( day_, month_, year_ )
	
	local currentSeconds = tonumber( os.time() )
	local playerSecondsSinceBirth = tonumber( os.time( { year = year_, month = month_, day = day_, hour = 0, min = 0, sec = 0, isdst = false } ) )
	
	local leapdays = math.floor( AGECHECK_MINIMUM_AGE / 4 )
	local leapdayCompensation = leapdays * 86400
	local secondsNeededTillAge = AGECHECK_MINIMUM_AGE * 365 * 24 * 60 * 60 + leapdayCompensation
	local alittlerandomnessalwayshelps = math.random( 432000 )
	
	local secondsLeft = secondsNeededTillAge - ( currentSeconds - playerSecondsSinceBirth ) + alittlerandomnessalwayshelps
	
	-- Ban someone at least for 5 days to prevent silly ban times
	if secondsNeededTillAge < 432000 then
		secondsLeft = 432000
	end
	
	return secondsLeft
	
end

-- That should be easy to understand, shouldn't it?
function ageverify_isOldEnough( day, month, year )
	
	return ageverify_getAge( day, month, year ) >= AGECHECK_MINIMUM_AGE
	
end

-- Check whether his entered age is matching his birthday
function ageverify_isAgeMatching( age, day, month, year )

	return age == math.floor( ageverify_getAge( day, month, year ) )
	
end

-- It seemed easy to use os.time for calculation of years
-- but that wasn't the case. Actually it was quite difficult to calculate
-- In the end we have to add leapday seconds to the equation to get the actual date
-- Otherwise we get false results for players that would turn, let's say 18, in two days and are considered 18 already
-- if we don't remove the leap days that happened. The leapday calculation is lazy, I know
function ageverify_getAge( day_, month_, year_ )

	local currentSeconds = tonumber( os.time() )
	local playerSecondsSinceBirth = tonumber( os.time( { year = year_, month = month_, day = day_, hour = 0, min = 0, sec = 0, isdst = false } ) )
	
	local years = ( currentSeconds - playerSecondsSinceBirth ) / 60 / 60 / 24 / 365
	
	-- Calculate how many leap years have passed since the player's birth
	local approximatedLeapYears = math.floor( years / 4 )
	
	-- Substract those additional days from the final calculation
	years = ( currentSeconds - playerSecondsSinceBirth - ( approximatedLeapYears * 86400 ) ) / 60 / 60 / 24 / 365

	return years
	
end

-- Checks whether a player is required to be tested by checking the whitelist
function ageverify_needsToBeTested( sid )

	local query = "SELECT * FROM agecheck_done WHERE steamid='" .. sid .. "'"
	local result = sql.Query( query )
	
	if result then return AGECHECK_MAXIMUM_TEST end
	
	local wasTested = ageverify_getPreviousEntry( sid )
	
	if wasTested then
		return 1
	else
		return 0
	end
end

-- Gets a player's previous entry data
function ageverify_getPreviousEntry( sid )

	local query = "SELECT * FROM agecheck WHERE steamid='" .. sid .. "'"
	result = sql.Query( query )
	
	return result
	
end

-- Deletes player's entry from the agecheck database
function ageverify_flushEntriesFromSteamid( sid )

	local query = "DELETE FROM agecheck WHERE steamid='" .. sid .. "'"
	result = sql.Query( query )
	
end

-- Empties the agecheck database
function ageverify_flushAllEntries( )

	local query = "DELETE FROM agecheck"
	result = sql.Query( query )
	
end

-- Empties the whitelist
function ageverify_flushAllDoneEntries( )

	local query = "DELETE FROM agecheck_done"
	result = sql.Query( query )
	
end

-- Gets all active entries in the agecheck database
function ageverify_getAgecheckCount( )

	local query = "SELECT COUNT(*) as count FROM agecheck"
	result = sql.Query( query )
	if result then 
		return result[1].count
	else 
		return 0
	end
	
end

-- Gets all whitelist entries in the agecheck_done database
function ageverify_getAgecheckWhitelistCount( )

	local query = "SELECT COUNT(*) as count FROM agecheck_done"
	result = sql.Query( query )
	if result then 
		return result[1].count
	else 
		return 0
	end
	
end

-- Check if all of the newly entered data matches all previously entered data
function ageverify_isMatchingPreviousAnswer( data )

	local sid = data[1]
	local age = data[2]
	local day = data[3]
	local month = data[4]
	local year = data[5]
	local zodiac = data[6]
	
	local previous = ageverify_getPreviousEntry( sid )
	
	if not previous then return true end

	if previous[1].day ~= day or previous[1].month ~= month or previous[1].year ~= year or previous[1].zodiac ~= zodiac then
		return false
	end
	
	return true
	
end

-- Once a player enters his details, print the results to moderators or admins on the server who are allowed access to
-- ulx seebirthdayentry
function ageverify_notifyAdmins( ply, age, day, month, year, zodiac )
	
	local validZodiacColor = Color( 0, 255, 0, 255 )
	local validZodiac = "[GOOD]"
	
	if not ageverify_isValidZodiacDate( day, month, zodiac ) then
		validZodiacColor = Color( 255, 0, 0, 255 )
		validZodiac = "[WRONG]"
	end
	
	local ageColor_1 = Color( 0, 255, 0, 255 )
	local ageGood_1 = age >= AGECHECK_MINIMUM_AGE
	
	if not ageGood_1 then
		ageColor_1 = Color( 255, 0, 0, 255 )
	end
	
	local ageColor_2 = Color( 0, 255, 0, 255 )
	local ageGood_2 = math.floor( ageverify_getAge( day, month, year ) ) == age
	
	if not ageGood_2 then
		ageColor_2 = Color( 255, 0, 0, 255 )
	end

	local players = player.GetAll()
	for _, player in ipairs( players ) do
		if ULib.ucl.query( player, "ulx seebirthdayentry" ) then
			ULib.tsayColor( player, true, 
			Color( 255, 0, 0, 255 	), "[CONFIDENTIAL] ", 
			Color( 255, 255, 0, 255	), "Player '", 
			Color( 0, 255, 255, 255	), ply:Nick(), 
			Color( 255, 255, 0, 255	), "'", 
			Color( 255, 255, 0, 255	), " -> Age: ", 
			ageColor_1, age .. "", 
			Color( 255, 255, 0, 255	), ", Date of Birth: ", 
			Color( 0, 255, 0, 255	), day .. "." .. month .. "." .. year, 
			Color( 255, 255, 0, 255	), " [", 
			ageColor_2, math.floor( ageverify_getAge( day, month, year ) ) .. "", 
			Color( 255, 255, 0, 255	), "] ", 
			Color( 255, 255, 0, 255	), ", ", 
			Color( 0, 255, 0, 255	), zodiac .. " ", 
			validZodiacColor, validZodiac )
		end
	end
	
end

-- Print ban to chat
function ageverify_reportBan( target_ply, banText, duration )

	local time = " (#i minute(s))"
	
	if duration == 0 then 
		time = " (permanent)"
	elseif duration == -1 then 
		time = ""
	end
	
	local str = banText .. time
	ulx.fancyLogAdmin( target_ply, str, duration )
	
end

-- Forward ban to Sourcebans if installed, otherwise ban via ULX
function ageverify_doBan( ply, length, reason, admin_steamid )

	if SBAN.Player_Ban then
		SBAN.Player_Ban( ply, length, reason, admin_steamid )
	else
		RunConsoleCommand( "ulx", "banid", ply:SteamID(), length / 60, reason )
	end
	
end

-- This is the main logic behind all of it
-- Run checks and react to the entered data accordingly
function ageverify_addEntry( data )

	local ply = player.GetBySteamID( data[1] )
	
	local sid = data[1]
	local age = tonumber( data[2] )
	local day = tonumber( data[3] )
	local month = tonumber( data[4] )
	local year = tonumber( data[5] )
	local zodiac = data[6]
	
	ageverify_notifyAdmins( ply, age, day, month, year, zodiac )
	
	if not ageverify_isZodiacValid( zodiac ) then return end
	
	print( "AgeverifyDebug: " .. ply:Nick() .. ", " .. ply:SteamID() .. " -> " .. day .. "." .. month .. "." .. year .. ", " .. zodiac )
	
	local length = 0
	
	-- Check for invalid dates first, this is the most ass-y way of entering birthdays
	if not ageverify_isValidDate( day, month, year ) then
		print( "AgeverifyDebug: INVALID DATE!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_WRONG_DATE, 0 )
		ageverify_doBan( ply, 0, AGECHECK_BAN_REASON_WRONG_DATE, AGECHECK_SBAN_STEAMID )
		return
	end
	
	-- Check whether the age entries of the player (age AND birthday) are okay
	if age < AGECHECK_MINIMUM_AGE or not ageverify_isOldEnough( day, month, year ) then
		print( "AgeverifyDebug: TOO YOUNG!" )
		if age < math.floor( ageverify_getAge( day, month, year ) ) then
			length = ( ( AGECHECK_MINIMUM_AGE - age ) * 365 * 24 * 60 * 60 ) - ( 365 * 24 * 60 * 60 / 2 ) -- Statistically we expect the average time it will take for a player to reach the age to be half a year less than what is left in years, so if he is 1 year too young, we wait half a year. 3 years too young we wait 2.5 years etc.
		else
			length = ageveryify_getSecondsUntilAge( day, month, year ) -- If the birthday results in a lower age, we expect the birthday to be valid and ban him according to the duration of that
		end
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_TOO_YOUNG, -1 )
		ageverify_doBan( ply, length, AGECHECK_BAN_REASON_TOO_YOUNG, AGECHECK_SBAN_STEAMID )
		return
	end
	
	-- Check whether the entered age and the entered birthday both result in the same age
	if not ageverify_isAgeMatching( age, day, month, year ) then
		print( "AgeverifyDebug: AGE MISMATCH!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_AGE_MISMATCH, -1 )
		ageverify_doBan( ply, AGECHECK_DEFAULT_BAN_DURATION, AGECHECK_BAN_REASON_AGE_MISMATCH, AGECHECK_SBAN_STEAMID )
		return
	end
	
	-- Check for valid zodiac
	if not ageverify_isValidZodiacDate( day, month, zodiac ) then
		print( "AgeverifyDebug: INVALID ZODIAC!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_WRONG_ZODIAC, AGECHECK_DEFAULT_BAN_DURATION )
		ageverify_doBan( ply, AGECHECK_DEFAULT_BAN_DURATION, AGECHECK_BAN_REASON_WRONG_ZODIAC, AGECHECK_SBAN_STEAMID )
		return
	end
	
	-- Check for consistent answers
	if not ageverify_isMatchingPreviousAnswer( data ) then
		print( "AgeverifyDebug: DATA NOT PERSISTENT!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_DATA_NOT_PERSISTENT, AGECHECK_DEFAULT_BAN_DURATION )
		ageverify_doBan( ply, AGECHECK_DEFAULT_BAN_DURATION, AGECHECK_BAN_REASON_DATA_NOT_PERSISTENT, AGECHECK_SBAN_STEAMID )
		return
	end
	
	-- Check the amount of checks there have been for this player
	local query = "SELECT times FROM agecheck WHERE steamid='" .. sid .. "'"
	local result = sql.Query( query )
	
	-- If there were not checks before, we add the first
	if not result then
		query = "INSERT INTO agecheck VALUES ( NULL, 1, '" .. sid .. "', '" .. sql.SQLStr( ply:Nick(), true ) .. "', '" .. age .. "', '" .. day .. "', '" .. month .. "', '" .. year .. "', '" .. zodiac .. "', CURRENT_TIMESTAMP )"
		result = sql.Query( query )
	-- If there were at least one entry, we increment the amount of times this person was tested and update the date
	elseif tonumber( result[1].times ) < AGECHECK_MAXIMUM_TEST then
		query = "UPDATE agecheck SET times=times+1, date=CURRENT_TIMESTAMP WHERE steamid='" .. sid .. "'"
		result = sql.Query( query )
	-- If the person has reached the amount of maximum tests, his data is removed and he's added to the whitelist
	else
		ageverify_flushEntriesFromSteamid( sid )
		
		query = "INSERT INTO agecheck_done VALUES ( NULL, '" .. sid .. "', '" .. sql.SQLStr( ply:Nick(), true ) .. "' )"
		result = sql.Query( query )
	end
	
end

-- Net message to open the agecheck on the client's PC
function ageverify_startCheck( ply, probability, shouldShow )

	net.Start( "agecheck_checknecessity" )
	net.WriteString( AGECHECK_LANGUAGE )
	net.WriteString( AGECHECK_TITLE )
	net.WriteString( AGECHECK_TOP_TEXT_ONE )
	net.WriteString( AGECHECK_TOP_TEXT_TWO )
	net.WriteString( AGECHECK_FORM_TITLE )
	net.WriteString( AGECHECK_DISCLAIMER )
	net.WriteTable( AGECHECK_ZODIACS )
	net.WriteString( shouldShow ) -- For some reason WriteBit and ReadBit didn't work
	net.WriteFloat( probability )
	net.Send( ply )
	
end

-- Receival of the entered data by the client
net.Receive( "agecheck_send", function( len, ply )

	local message = ""
	message = net.ReadString()
	message = string.Split( message, " " )
	
	ageverify_addEntry( message )
	
end)

-- Receival of the client's Steam-ID upon connection or map load + logic whether
-- the player should be given the form or not
net.Receive( "agecheck_onplayerconnect", function( len, ply )

	local steamid = net.ReadString()
	local probability = AGECHECK_PROBABILITY
	
	local playerGroup = ply:GetUserGroup()
	
	if AGECHECK_USE_EXCLUDED then
		local shouldContinue = true
		
		for _, group in ipairs( AGECHECK_EXCLUDED_GROUPS ) do
			if playerGroup == group then
				shouldContinue = false
			end
		end
		
		if not shouldContinue then
			ageverify_flushEntriesFromSteamid( steamid ) -- Make sure we remove all entries if the player has reached a group that isnt checked
			return
		end
	else
		local shouldContinue = false
		
		for _, group in ipairs( AGECHECK_INCLUDED_GROUPS ) do
			if playerGroup == group then
				shouldContinue = true
			end
		end
		
		if not shouldContinue then
			ageverify_flushEntriesFromSteamid( steamid ) -- Make sure we remove all entries if the player has reached a group that isnt checked
			return
		end
	end
	
	local shouldShow = ageverify_needsToBeTested( steamid )
	if shouldShow < AGECHECK_MAXIMUM_TEST then
		if AGECHECK_FORCE_FIRST_TIME and shouldShow == 0 then
			probability = 100
		end
		
		shouldShow = "true"
	else
		shouldShow = "false"
	end
	
	ageverify_startCheck( player.GetBySteamID( steamid ), probability, shouldShow )

	end )
	
end