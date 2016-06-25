-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3
-- https://github.com/doctorluk/ULX-Age-Verificator

local CATEGORY = "Age Verificator"

-- Empties the database with active entries
function ulx.killbirthdaydatabase ( calling_ply )
	ageverify_flushAllEntries()
	ulx.fancyLogAdmin( calling_ply, "#A has EMPTIED the whole Birthday Database" )
end
local killbirthdaydatabase = ulx.command( CATEGORY, "ulx killbirthdaydatabase", ulx.killbirthdaydatabase, "!killbirthdaydatabase" )
killbirthdaydatabase:defaultAccess( ULib.ACCESS_SUPERADMIN )
killbirthdaydatabase:help( "CAUTION! FLUSHES ALL BIRTHDAY ENTRIES" )

-- Empties the whitelist database
function ulx.killbirthdaydonedatabase ( calling_ply )
	ageverify_flushAllDoneEntries()
	ulx.fancyLogAdmin( calling_ply, "#A has EMPTIED the Birthday DONE Database" )
end
local killbirthdaydonedatabase = ulx.command( CATEGORY, "ulx killbirthdaydonedatabase", ulx.killbirthdaydonedatabase, "!killbirthdaydonedatabase" )
killbirthdaydonedatabase:defaultAccess( ULib.ACCESS_SUPERADMIN )
killbirthdaydonedatabase:help( "CAUTION! FLUSHES ALL PLAYERS THAT HAVE SUCCEEDED ALL BIRTHDAY CHECKS" )

-- Removes active entry of given Steam-ID
function ulx.flushbirthdaysteamid ( calling_ply, steamid )
	if ULib.isValidSteamID( steamid ) then
		ageverify_flushEntriesFromSteamid( steamid )
		ulx.fancyLogAdmin( calling_ply, "#A flushed the Birthday Entries of #s", steamid )
	end
end
local flushbirthdayid = ulx.command( CATEGORY, "ulx flushbirthdayid", ulx.flushbirthdaysteamid, "!flushbirthdayid" )
flushbirthdayid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
flushbirthdayid:defaultAccess( ULib.ACCESS_ADMIN )
flushbirthdayid:help( "Flushes all entered Birthday-Checks for the selected SteamID" )

-- Displays the current amount of active entries in chat
function ulx.showactiveagecheckentries ( calling_ply )
	local entries = ageverify_getAgecheckCount()
	
	for _, player in ipairs( player.GetAll() ) do
			ULib.tsayColor( player, true, 
			Color( 255, 255, 255, 255 ), "Agecheck Database Entries [", 
			Color( 255, 255, 0, 255 ), "ACTIVE", 
			Color( 255, 255, 255, 255 ), "]: ", 
			Color( 100, 255, 255, 255	), entries )
	end
end
local showactiveagecheckentries = ulx.command( CATEGORY, "ulx agactive", ulx.showactiveagecheckentries, "!agactive" )
showactiveagecheckentries:defaultAccess( ULib.ACCESS_ADMIN )
showactiveagecheckentries:help( "Shows the amount of currently pending agechecks inside the database in chat." )

-- Displays the current amount of whitelist entries in chat
function ulx.showwhitelistagecheckentries ( calling_ply )
	local entries = ageverify_getAgecheckWhitelistCount()
	
	for _, player in ipairs( player.GetAll() ) do
			ULib.tsayColor( player, true, 
			Color( 255, 255, 255, 255 ), "Agecheck Database Entries [", 
			Color( 255, 255, 0, 255 ), "WHITELISTED", 
			Color( 255, 255, 255, 255 ), "]: ", 
			Color( 100, 255, 255, 255	), entries )
	end
end
local showwhitelistagecheckentries = ulx.command( CATEGORY, "ulx agwhitelist", ulx.showwhitelistagecheckentries, "!agwhitelist" )
showwhitelistagecheckentries:defaultAccess( ULib.ACCESS_ADMIN )
showwhitelistagecheckentries:help( "Shows the amount of whitelisted players inside the database in chat" )

-- Removes active entry of given player
function ulx.flushbirthday ( calling_ply, target_plys )
	for i = 1, #target_plys do
		local target_pl = target_plys[ i ]
		ageverify_flushEntriesFromSteamid( target_pl:SteamID() )
		ulx.fancyLogAdmin( calling_ply, "#A flushed the Birthday Entries of #T", target_pl )
	end
end
local flushbirthday = ulx.command( CATEGORY, "ulx flushbirthday", ulx.flushbirthday, "!flushbirthday" )
flushbirthday:addParam{ type=ULib.cmds.PlayersArg }
flushbirthday:defaultAccess( ULib.ACCESS_ADMIN )
flushbirthday:help( "Flushes all entered Birthday-Checks for the selected Player" )

-- Forces the given player to fill out the form
function ulx.showbirthdaytest ( calling_ply, target_plys )
	for i = 1, #target_plys do
		local target_pl = target_plys[ i ]
		
		ageverify_startCheck( target_pl, 100, "true" )
		
		ulx.fancyLogAdmin( calling_ply, "#A forced #T to fill out the birthday form", target_pl )
	end
end
local showbirthdaytest = ulx.command( CATEGORY, "ulx showbirthdaytest", ulx.showbirthdaytest, "!showbirthdaytest" )
showbirthdaytest:addParam{ type=ULib.cmds.PlayersArg }
showbirthdaytest:defaultAccess( ULib.ACCESS_ADMIN )
showbirthdaytest:help( "Forces the selected Players to fill out the birthday form" )

-- Adds ULib permission to see the entered data live, USE WITH CAUTION
if SERVER then
	ULib.ucl.registerAccess( "ulx seebirthdayentry", ULib.ACCESS_OPERATOR, "Ability to see the result of a player answering the Age Verificator", CATEGORY ) 
end