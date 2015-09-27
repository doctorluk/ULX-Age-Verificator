-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.0

if SERVER then

if not AGECHECK_LANGUAGE then
	include( "ageverificator_config.lua" )
end

-- Make sure we always get valid Zodiacs from the player's net message
VALID_ZODIACS = AGECHECK_ZODIACS

util.AddNetworkString( "agecheck_send" )
util.AddNetworkString( "agecheck_onplayerconnect" )
util.AddNetworkString( "agecheck_checknecessity" )

-- This function was taken from the AWarn 2 plugin here: http://forums.ulyssesmod.net/index.php/topic,7125.0.html
-- It's nice to alter existing functions for your own purpose. I've got no idea of LUA and doing stuff from scratch is hard sometimes
function ageverify_checkAgeTable()
	-- Check existance and/or create the table that will hold the entered data
	if sql.TableExists( "agecheck" ) then
		ServerLog( "Age Verification: agecheck Table is existing!\n" )
	else
		local query = "CREATE TABLE agecheck ( id INTEGER PRIMARY KEY AUTOINCREMENT, steamid TEXT, name TEXT, day INTEGER, month INTEGER, year INTEGER, zodiac TEXT )"
		result = sql.Query( query )
		ServerLog( "Age Verification: Creating Age Verification Table...\n" )
		if sql.TableExists( "agecheck" ) then
			ServerLog( "Age Verification: Age Verification Table created sucessfully.\n" )
		else
			ServerLog( "Age Verification: Trouble creating the Age Verification Table\n" )
			ServerLog( "Age Verification: " .. sql.LastError( result ).."\n" )
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
			ServerLog( "Age Verification: Trouble creating the Age Verification Done Table\n" )
			ServerLog( "Age Verification: " .. sql.LastError( result ).."\n" )
		end
	end
end
hook.Add( "Initialize", "age_check_init", ageverify_checkAgeTable )

-- I'm not sure if people could change the net messages, I suspect that is easy, so we make sure
-- the received Zodiac is one that we offered him to choose
function ageverify_isZodiacValid( zodiac )
	return table.HasValue( VALID_ZODIACS, zodiac )
end

-- This is a painful function that checks if the day and month entered matches
-- the zodiac sign, credits to Heady for making it
function ageverify_isValidZodiacDate( day_, month_, zodiac )
	local day = tonumber( day_ )
	local month = tonumber( month_ )
	
	if zodiac == VALID_ZODIACS[1] then
		if ( day >= 21 and month == 3 ) or ( day <= 20 and month == 4 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[2] then
		if ( day >= 21 and month == 4 ) or ( day <= 21 and month == 5 ) then
			return true	
		end

	elseif zodiac == VALID_ZODIACS[3] then
		if ( day >= 22 and month == 5 ) or ( day <= 21 and month == 6 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[4] then
		if ( day >= 22 and month == 6 ) or ( day <= 22 and month == 7 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[5] then
		if ( day >= 23 and month == 7 ) or ( day <= 22 and month == 8 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[6] then
		if ( day >= 23 and month == 8 ) or ( day <= 22 and month == 9 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[7] then
		if ( day >= 23 and month == 9 ) or ( day <= 22 and month == 10 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[8] then
		if ( day >= 23 and month == 10 ) or ( day <= 22 and month == 11 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[9] then
		if ( day >= 23 and month == 11 ) or ( day <= 20 and month == 12 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[10] then
		if ( day >= 21 and month == 12 ) or ( day <= 19 and month == 1 ) then
			return true
		end

	elseif zodiac == VALID_ZODIACS[11] then
		if ( day >= 20 and month == 1 ) or ( day <= 18 and month == 2 ) then
			return true
		end

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
-- To prevent publishing of people's birthdates on ban websites, we add or remove up to 4 days from the ban length
function ageveryify_getSecondsUntilAge( day_, month_, year_ )
	
	local currentSeconds = tonumber( os.time() )
	local playerSecondsSinceBirth = tonumber( os.time( { year = year_, month = month_, day = day_, hour = 0, min = 0, sec = 0, isdst = false } ) )
	
	local leapdays = math.floor( AGECHECK_MINIMUM_AGE / 4 )
	local leapdayCompensation = leapdays * 86400
	local secondsNeededTillAge = AGECHECK_MINIMUM_AGE * 365 * 24 * 60 * 60 + leapdayCompensation
	local alittlerandomnessalwayshelps = math.random( -345600, 345600 )
	
	local secondsLeft = secondsNeededTillAge - ( currentSeconds - playerSecondsSinceBirth ) + alittlerandomnessalwayshelps
	
	return secondsLeft
	
end

-- That should be easy to understand, isn't it?
function ageverify_isOldEnough( day, month, year )
	
	return ageverify_getAge( day, month, year ) >= AGECHECK_MINIMUM_AGE
	
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

-- Checks whether a player is required to be tested by the amount of tests he has done
function ageverify_needsToBeTested( sid )

	local query = "SELECT * FROM agecheck_done WHERE steamid='" .. sid .. "'"
	local result = sql.Query( query )
	
	if result then return AGECHECK_MAXIMUM_TEST end
	
	local count = ageverify_getPreviousEntries( sid )
	if not count then
		return 0
	end

	return #count
end

-- These functions below should be easy to understand
function ageverify_getPreviousEntries( sid )

	local query = "SELECT * FROM agecheck WHERE steamid='" .. sid .. "'"
	result = sql.Query( query )
	
	return result
	
end

function ageverify_flushEntriesFromSteamid( sid )

	local query = "DELETE FROM agecheck WHERE steamid='" .. sid .. "'"
	result = sql.Query( query )
	
end

function ageverify_flushAllEntries( )

	local query = "DELETE FROM agecheck"
	result = sql.Query( query )
	
end

function ageverify_flushAllDoneEntries( )

	local query = "DELETE FROM agecheck_done"
	result = sql.Query( query )
	
end

-- Check if any of the newly entered data matches all previously entered data
function ageverify_isMatchingPreviousAnswers( data )

	local sid = data[1]
	local day = data[2]
	local month = data[3]
	local year = data[4]
	local zodiac = data[5]
	
	local previous = ageverify_getPreviousEntries( sid )
	
	if not previous then return true end
	
	for k,v in pairs( previous ) do
		if previous[k].day ~= day or previous[k].month ~= month or previous[k].year ~= year or previous[k].zodiac ~= zodiac then
			return false
		end
	end
	
	return true
	
end

-- Once a player enters his details, print the results to moderators or admins on the server who are allowed access to
-- ulx seebirthdayentry
function ageverify_notifyAdmins( ply, day, month, year, zodiac )
	
	local validZodiacColor = Color( 0, 255, 0, 255 )
	local validZodiac = "[GOOD]"
	
	if not ageverify_isValidZodiacDate( day, month, zodiac ) then
		validZodiacColor = Color( 255, 0, 0, 255 )
		validZodiac = "[WRONG]"
	end
	
	local ageColor = Color( 0, 255, 0, 255 )
	local ageGood = ageverify_isOldEnough( day, month, year )
	
	if not ageGood then
		ageColor = Color( 255, 0, 0, 255 )
	end

	local players = player.GetAll()
	for _, player in ipairs( players ) do
		if ULib.ucl.query( player, "ulx seebirthdayentry" ) then
			ULib.tsayColor( player, true, Color( 255, 0, 0, 255 ), "[VERTRAULICH] ", Color( 255, 255, 0, 255 ), "Spieler '", Color( 0, 255, 255, 255 ), ply:Nick(), Color( 255, 255, 0, 255 ), "'", Color( 255, 255, 0, 255 ), " -> Alter: ",  ageColor, math.floor(ageverify_getAge( day, month, year )) .. "", Color( 255, 255, 0, 255 ), ", Geburtsdatum: ", Color( 0, 255, 0, 255 ), day .. "." .. month .. "." .. year, Color( 255, 255, 0, 255 ), ", ", Color( 0, 255, 0, 255 ), zodiac .. " ", validZodiacColor, validZodiac )
		end
	end
	
end

-- Print ban to chat
function ageverify_reportBan( target_ply, banText, duration )
	local time = " (#i Minute(n))"
	
	if duration == 0 then 
		time = " (Permanent)"
	elseif duration == -1 then 
		time = ""
	end
	
	local str =  banText .. time
	ulx.fancyLogAdmin( target_ply, str, duration )
end

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
	local day = tonumber( data[2] )
	local month = tonumber( data[3] )
	local year = tonumber( data[4] )
	local zodiac = data[5]
	
	ageverify_notifyAdmins( ply, day, month, year, zodiac )
	
	if not ageverify_isZodiacValid( zodiac ) then return end
	
	print( "AgeverifyDebug: " .. ply:Nick() .. ", " .. ply:SteamID() .. " -> " .. day .. "." .. month .. "." .. year .. ", " .. zodiac )
	
	if not ageverify_isValidDate( day, month, year ) then
		print( "AgeverifyDebug: INVALID DATE!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_WRONG_DATE, 0 )
		ageverify_doBan( ply, 0, AGECHECK_BAN_REASON_WRONG_DATE, AGECHECK_SBAN_STEAMID )
		return
	end
	
	if not ageverify_isOldEnough( day, month, year ) then
		print( "AgeverifyDebug: TOO YOUNG!" )
		local length = ageveryify_getSecondsUntilAge( day, month, year )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_TOO_YOUNG, -1 )
		ageverify_doBan( ply, length, AGECHECK_BAN_REASON_TOO_YOUNG, AGECHECK_SBAN_STEAMID )
		return
	end
	
	if not ageverify_isValidZodiacDate( day, month, zodiac ) then
		print( "AgeverifyDebug: INVALID ZODIAC!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_WRONG_ZODIAC, AGECHECK_DEFAULT_BAN_DURATION )
		ageverify_doBan( ply, AGECHECK_DEFAULT_BAN_DURATION, AGECHECK_BAN_REASON_WRONG_ZODIAC, AGECHECK_SBAN_STEAMID )
		return
	end
	
	if not ageverify_isMatchingPreviousAnswers( data ) then
		print( "AgeverifyDebug: DATA NOT PERSISTENT!" )
		ageverify_reportBan( ply, AGECHECK_BAN_REASON_OTHER_DATA_NOT_PERSISTENT, AGECHECK_DEFAULT_BAN_DURATION )
		ageverify_doBan( ply, AGECHECK_DEFAULT_BAN_DURATION, AGECHECK_BAN_REASON_DATA_NOT_PERSISTENT, AGECHECK_SBAN_STEAMID )
		return
	end
	
	local query = "SELECT COUNT(*) as checks FROM agecheck WHERE steamid='" .. sid .. "'"
	local result = sql.Query( query )
	
	if not result or tonumber( result[1].checks ) < AGECHECK_MAXIMUM_TEST - 1 then
		query = "INSERT INTO agecheck VALUES ( NULL, '" .. sid .. "', '" .. sql.SQLStr( ply:Nick(), true ) .. "', '" .. day .. "', '" .. month .. "', '" .. year .. "', '" .. zodiac .. "' )"
		result = sql.Query( query )
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