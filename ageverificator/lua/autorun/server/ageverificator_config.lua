-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.2

AGECHECK_LANGUAGE = "english" -- There's also german currently available

AGECHECK_USE_EXCLUDED = true -- If this is set to true, the EXCLUDED groups setting will be used, otherwise only the included groups are checked
AGECHECK_EXCLUDED_GROUPS = { } -- Comma seperated list of groups that should NEVER be checked
AGECHECK_INCLUDED_GROUPS = { "user", "someotheruser" } -- Comma seperated list of groups that SHOULD ONLY be checked
AGECHECK_MINIMUM_AGE = 18 -- The minimum age a player should have
AGECHECK_MAXIMUM_TEST = 4 -- The times a player will be checked until he will never be checked again
AGECHECK_PROBABILITY = 25 -- The probability of a check once the player initializes in percent (in TTT it happens once per map or on connect, this might be true for other gametypes, too)
AGECHECK_DEFAULT_BAN_DURATION = 604800 -- The default ban duration when entering wrong zodiac dates or inconsistent dates in SECONDS
AGECHECK_FORCE_FIRST_TIME = true -- Set to true if you want to send the age check to everyone who connects for the first time/has no record
AGECHECK_SBAN_STEAMID = "STEAM_0:1:000000000" -- The SteamID that should do the bans, ONLY NEEDED IF YOU USE SOURCEBANS

-- Ban reasons displayed to the player who is being banned
AGECHECK_BAN_REASON_WRONG_DATE = "The date you entered doesn't exist. You've been banned for failing the test. agvrfy_1"
AGECHECK_BAN_REASON_TOO_YOUNG = "You are not " .. AGECHECK_MINIMUM_AGE .. ", yet and are not allowed to play here. agvrfy_2"
AGECHECK_BAN_REASON_WRONG_ZODIAC = "Your Zodiac is not at the date you entered, you've been banned for failing the test. agvrfy_3"
AGECHECK_BAN_REASON_DATA_NOT_PERSISTENT = "Your previously entered data differs from the new. You've failed the test. agvrfy_4"
AGECHECK_BAN_REASON_AGE_MISMATCH = "The age you entered does not match with the birthday. agvrfy_5"

-- #A is a replacer for the banned player's name
AGECHECK_BAN_REASON_OTHER_TOO_YOUNG = "#A was banned for not being " .. AGECHECK_MINIMUM_AGE .. " years of age, yet."
AGECHECK_BAN_REASON_OTHER_WRONG_DATE = "#A was banned for entering an invalid date."
AGECHECK_BAN_REASON_OTHER_WRONG_ZODIAC = "#A was banned for entering an invalid Zodiac and Date combination."
AGECHECK_BAN_REASON_OTHER_DATA_NOT_PERSISTENT = "#A was banned due to inconsistent dates entered."
AGECHECK_BAN_REASON_OTHER_AGE_MISMATCH = "#A was banned due to invalid age + birthday relation."

-- The below will be taken if you've chosen 'english' at the top
if AGECHECK_LANGUAGE == "english" then

	AGECHECK_TITLE = [[Form for automatic gathering of birthday data]]
	AGECHECK_TOP_TEXT_ONE = [[Be welcome at SERVERNAME!]] 
	AGECHECK_TOP_TEXT_TWO = [[If you submit lies, you might get banned!]]
	AGECHECK_FORM_TITLE = [[Please enter your Date Of Birth and Zodiac Sign:]]
	AGECHECK_DISCLAIMER = [[PRIVACY:
YOUR DATA IS BEING PROCESSED AUTOMATICALLY AND NOT SHARED WITH THIRD-PARTIES]] -- You can input new lines here, too
	
	-- I DO NOT RECOMMEND CHANGING THEM! THE ORDER IS FIXED TO THE DATE OF EACH ZODIAC SIGN
	AGECHECK_ZODIACS = {"Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Saggitarius", "Capricornus", "Aquarius", "Pisces"}

-- There is also a German translation for all of this. This is being used if you use 'german' at the top
elseif AGECHECK_LANGUAGE == "german" then

	AGECHECK_TITLE = [[Formular zur automatisierten Sammlung von Geburtsdaten]]
	AGECHECK_TOP_TEXT_ONE = [[Herzlich Willkommen auf SERVERNAME!]]
	AGECHECK_TOP_TEXT_TWO = [[Solltest du in diesen Angaben lügen, dann wirst du gebannt.]]
	AGECHECK_FORM_TITLE = [[Bitte gib Dein Geburtsdatum und Dein Sternzeichen ein:]]
	AGECHECK_DISCLAIMER = [[DATENSCHUTZ:
DIESE DATEN WERDEN AUTOMATISCH VERARBEITET UND WERDEN NICHT AN DRITTE WEITERGEGEBEN]]
	
	-- I DO NOT RECOMMEND CHANGING THEM! THE ORDER IS FIXED TO THE DATE OF EACH ZODIAC SIGN
	AGECHECK_ZODIACS = {"Widder", "Stier", "Zwillinge", "Krebs", "Loewe", "Jungfrau", "Waage", "Skorpion", "Schuetze", "Steinbock", "Wassermann", "Fische"}
	
--else
end