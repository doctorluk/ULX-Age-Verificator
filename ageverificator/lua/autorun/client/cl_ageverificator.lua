-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.2

if CLIENT then

-- DEFAULT SETTINGS, just in case something goes horribly wrong
AGECHECK_LANGUAGE = "english"
AGECHECK_TITLE = [[Form for automatic gathering of birthday data]]
AGECHECK_TOP_TEXT_ONE = [[Be welcome at SERVERNAME!]] 
AGECHECK_TOP_TEXT_TWO = [[If you submit lies, you might get banned!]]
AGECHECK_FORM_TITLE = [[Please enter your Date Of Birth and Zodiac Sign:]]
AGECHECK_DISCLAIMER = [[PRIVACY:
YOUR DATA IS BEING PROCESSED AUTOMATICALLY AND NOT SHARED WITH THIRD-PARTIES]]
AGECHECK_ZODIACS = {"Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Saggitarius", "Capricornus", "Aquarius", "Pisces"}
AGECHECK_AGE = "Age"
AGECHECK_DAY = "Day"
AGECHECK_MONTH = "Month"
AGECHECK_YEAR = "Year"
AGECHECK_ZODIAC = "Zodiac Sign"
AGECHECK_SUBMIT = "Submit"

-- The main window
local function ageverify_runAgeCheck()

	-- prevents the window from being opened multiple times
	if ageCheckWindow then 
		local temp = ageCheckWindow
		ageCheckWindow = nil
		temp:Remove() 
	end
	
	-- Top title
	ageCheckWindow = vgui.Create( "DFrame" )
	ageCheckWindow:SetSize( 600, 350 )
	ageCheckWindow:Center()
	ageCheckWindow:SetTitle( AGECHECK_TITLE )
	ageCheckWindow:SetVisible( true )
	ageCheckWindow:SetDraggable( false )
	ageCheckWindow:ShowCloseButton( false )
	ageCheckWindow:SetDeleteOnClose( true )
	-- ageCheckWindow:SetBackgroundBlur( true )
	ageCheckWindow:MakePopup()
	
	-- Top Text
	top_greeting = vgui.Create( "DTextEntry", ageCheckWindow )
	top_greeting:SetPos( 150, 35 )
	top_greeting:SetSize( 500, 100 )
	top_greeting:SetText( AGECHECK_TOP_TEXT_ONE )
	top_greeting:SetTextColor(Color(255, 255, 255, 255));		
	top_greeting:SetDrawBackground( false )
	top_greeting:SetDrawBorder( false )
	top_greeting:SetEditable( false )
	top_greeting:SetMultiline( true )
	
	-- Text below Top Text
	top_description = vgui.Create( "DTextEntry", ageCheckWindow )
	top_description:SetPos( 150, 55 )
	top_description:SetSize( 500, 100 )
	top_description:SetText( AGECHECK_TOP_TEXT_TWO )
	top_description:SetTextColor( Color( 255, 255, 255, 255 ) );		
	top_description:SetDrawBackground( false )
	top_description:SetDrawBorder( false )
	top_description:SetEditable( false )
	top_description:SetMultiline( true )
	
	-- Text right above the available choices
	label_choices = vgui.Create( "DTextEntry", ageCheckWindow )
	label_choices:SetPos( 50, 105 )
	label_choices:SetSize( 500, 35 )
	label_choices:SetText( AGECHECK_FORM_TITLE )
	label_choices:SetTextColor( Color( 255, 255, 255, 255 ) );		
	label_choices:SetDrawBackground( false )
	label_choices:SetDrawBorder( false )
	label_choices:SetEditable( false )
	label_choices:SetMultiline( true )
	
	-- Disclaimer at the bottom
	bottom_disclaimer = vgui.Create( "DTextEntry", ageCheckWindow )
	bottom_disclaimer:SetPos( 40, 300 )
	bottom_disclaimer:SetSize( 520, 50 )
	bottom_disclaimer:SetText( AGECHECK_DISCLAIMER )
	bottom_disclaimer:SetTextColor( Color( 255, 255, 0, 255 ) );		
	bottom_disclaimer:SetDrawBackground( false )
	bottom_disclaimer:SetDrawBorder( false )
	bottom_disclaimer:SetEditable( false )
	bottom_disclaimer:SetMultiline( true )

	
	-- CHOICES (DAY, MONTH, YEAR)
	
	-- AGE
	local age = vgui.Create( "DComboBox" )
	age:SetParent( ageCheckWindow )
	age:SetPos( 250, 130 )
	age:SetSize( 100, 20 )
	age:SetValue( AGECHECK_AGE )
	for i = 1, 99, 1 do
		age:AddChoice( i )
	end
	
	-- DAY
	local day = vgui.Create( "DComboBox" )
	day:SetParent( ageCheckWindow ) -- Set parent to our "DermaPanel"
	day:SetPos( 100, 165 )
	day:SetSize( 100, 20 )
	day:SetValue( AGECHECK_DAY )
	for i = 1, 31, 1 do
		day:AddChoice( i )
	end
	
	-- MONTH
	local month = vgui.Create( "DComboBox" )
	month:SetParent( ageCheckWindow )
	month:SetPos( 250, 165 )
	month:SetSize( 100, 20 )
	month:SetValue( AGECHECK_MONTH )
	for i = 1, 12, 1 do
		month:AddChoice( i )
	end
	
	-- YEAR
	local year = vgui.Create( "DComboBox" )
	year:SetParent( ageCheckWindow )
	year:SetPos( 400, 165 )
	year:SetSize( 100, 20 )
	year:SetValue( AGECHECK_YEAR )
	for i = 1900, 2015, 1 do
		year:AddChoice( i )
	end
	
	-- ZODIAC SIGN
	local zodiac = vgui.Create( "DComboBox" )
	zodiac:SetParent( ageCheckWindow )
	zodiac:SetPos( 250, 200 )
	zodiac:SetSize( 100, 20 )
	zodiac:SetValue( AGECHECK_ZODIAC )
	for i = 1, #AGECHECK_ZODIACS, 1 do
		zodiac:AddChoice( AGECHECK_ZODIACS[i] )
	end
	
	-- SEND BUTTON
	local send = vgui.Create( "DButton" )
	send:SetParent( ageCheckWindow )
	send:SetText( AGECHECK_SUBMIT )
	send:SetPos( 250, 250 )
	send:SetSize( 100, 30 )
	send.DoClick = function ()
		if age:GetSelectedID() and day:GetSelectedID() and month:GetSelectedID() and year:GetSelectedID() and zodiac:GetSelectedID() then
			net.Start( "agecheck_send" )
			net.WriteString( LocalPlayer():SteamID() .. " " .. age:GetOptionText( age:GetSelectedID() ) .. " " .. day:GetOptionText( day:GetSelectedID() ) .. " " .. month:GetOptionText( month:GetSelectedID() ) .. " " .. year:GetOptionText( year:GetSelectedID() ) .. " " .. zodiac:GetOptionText( zodiac:GetSelectedID()) )
			net.SendToServer()
			
			ageCheckWindow:Remove()
			return 
		end
	end
	
end

-- In case of non-german, we change the text on the buttons and boxes
local function ageverify_loadLanguage()

	if AGECHECK_LANGUAGE == "german" then
		AGECHECK_AGE = "Alter"
		AGECHECK_DAY = "Tag"
		AGECHECK_MONTH = "Monat"
		AGECHECK_YEAR = "Jahr"
		AGECHECK_ZODIAC = "Sternzeichen"
		AGECHECK_SUBMIT = "Senden"
	end
	
end

-- Receival of the language strings and probability to show the form
net.Receive( "agecheck_checknecessity", function( len )
	
	AGECHECK_LANGUAGE = net.ReadString()
	AGECHECK_TITLE = net.ReadString()
	AGECHECK_TOP_TEXT_ONE = net.ReadString()
	AGECHECK_TOP_TEXT_TWO = net.ReadString()
	AGECHECK_FORM_TITLE = net.ReadString()
	AGECHECK_DISCLAIMER = net.ReadString()
	AGECHECK_ZODIACS = net.ReadTable()
	
	local shouldShow = net.ReadString()
	local probability = net.ReadFloat()
	
	if math.random(100) < probability and shouldShow == "true" then
		ageverify_loadLanguage()
		ageverify_runAgeCheck()
	end
	
end )

-- Run every time a player connects or loads a map, this is only possible client-side, so we need
-- to run net messages between client and server
function ageverify_onPlayerJoin()

	net.Start( "agecheck_onplayerconnect" )
	net.WriteString( LocalPlayer():SteamID() )
	net.SendToServer()
	
end
hook.Add( "InitPostEntity", "age_check_onjoin", ageverify_onPlayerJoin )

end