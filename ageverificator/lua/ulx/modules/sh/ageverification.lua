-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.0

local CATEGORY = "Age Verificator"

function ulx.killbirthdaydatabase ( calling_ply )
	ageverify_flushAllEntries()
	ulx.fancyLogAdmin( calling_ply, "#A has EMPTIED the whole Birthday Database" )
end
local killbirthdaydatabase = ulx.command( CATEGORY, "ulx killbirthdaydatabase", ulx.killbirthdaydatabase, "!killbirthdaydatabase" )
killbirthdaydatabase:defaultAccess( ULib.ACCESS_SUPERADMIN )
killbirthdaydatabase:help( "CAUTION! FLUSHES ALL BIRTHDAY ENTRIES" )

function ulx.killbirthdaydonedatabase ( calling_ply )
	ageverify_flushAllDoneEntries()
	ulx.fancyLogAdmin( calling_ply, "#A has EMPTIED the Birthday DONE Database" )
end
local killbirthdaydonedatabase = ulx.command( CATEGORY, "ulx killbirthdaydonedatabase", ulx.killbirthdaydonedatabase, "!killbirthdaydonedatabase" )
killbirthdaydonedatabase:defaultAccess( ULib.ACCESS_SUPERADMIN )
killbirthdaydonedatabase:help( "CAUTION! FLUSHES ALL PLAYERS THAT HAVE SUCCEEDED ALL BIRTHDAY CHECKS" )

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

function ulx.showbirthdaytest ( calling_ply, target_plys )
	for i = 1, #target_plys do
		local target_pl = target_plys[ i ]
		
		ageverify_startCheck( target_pl, 1.0, "true" )
		
		ulx.fancyLogAdmin( calling_ply, "#A forced #T to fill out the birthday form", target_pl )
	end
end
local showbirthdaytest = ulx.command( CATEGORY, "ulx showbirthdaytest", ulx.showbirthdaytest, "!showbirthdaytest" )
showbirthdaytest:addParam{ type=ULib.cmds.PlayersArg }
showbirthdaytest:defaultAccess( ULib.ACCESS_ADMIN )
showbirthdaytest:help( "Forces the selected Players to fill out the birthday form" )

if SERVER then
	ULib.ucl.registerAccess( "ulx seebirthdayentry", ULib.ACCESS_OPERATOR, "Ability to see the result of a player answering the Age Verificator", CATEGORY ) 
end