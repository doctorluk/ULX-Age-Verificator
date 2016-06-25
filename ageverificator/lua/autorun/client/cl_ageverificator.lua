-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3
-- https://github.com/doctorluk/ULX-Age-Verificator

if CLIENT then

surface.CreateFont( "Agetest_title", {
	font = "Consolas",
	extended = false,
	size = 22,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Agetest_form_title", {
	font = "Consolas",
	extended = false,
	size = 20,
	weight = 20,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

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
	ageCheckWindow:SetSize( ScrW() * 0.6 , ScrH() * 0.6 )
	-- Test resolutions:
	-- ageCheckWindow:SetSize( 640,480 )
	-- ageCheckWindow:SetSize( 800,600 )
	-- ageCheckWindow:SetSize( 1280, 720 )
	-- ageCheckWindow:SetSize( 1600,1024 )
	ageCheckWindow:SetMinimumSize( 640, 480 )
	ageCheckWindow:Center()
	ageCheckWindow:SetTitle( AGECHECK_TITLE )
	ageCheckWindow:SetVisible( true )
	ageCheckWindow:SetDraggable( false )
	ageCheckWindow:ShowCloseButton( false )
	ageCheckWindow:SetDeleteOnClose( true )
	ageCheckWindow:MakePopup()
	ageCheckWindow.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
		draw.RoundedBox( 5, 0, 0, w, h, Color( 100, 100, 120, 250 ) )
	end
	
	local fullX, fullY = ageCheckWindow:GetSize()
	
	
	-- Topmost headline
	top_greeting = vgui.Create( "DPanel", ageCheckWindow )
	local padding_sides = 20
	top_greeting:SetSize( fullX - padding_sides, 100 )
	top_greeting:Center()
	top_greeting:SetPos(top_greeting:GetPos(1), 0)
	local w, h = top_greeting:GetSize()
	local x, y = top_greeting:GetPos()
	top_greeting:SetWrap(true)
	top_greeting.Paint = function()
		draw.RoundedBox( 20, x, 25, fullX - (2 * padding_sides), 75, Color( 150, 150, 170, 250 ) )
		draw.SimpleTextOutlined( AGECHECK_TOP_TEXT_ONE, "Agetest_title", w / 2, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 10, 10, 10, 255 ) )
	end
	
	-- Text below headline
	top_description = vgui.Create( "DPanel", ageCheckWindow )
	top_description:SetSize( 600, 150 )
	top_description:Center()
	top_description:SetPos(top_description:GetPos(1), 0)
	local w, h = top_description:GetSize()
	top_description:SetWrap(true)
	top_description.Paint = function()
		draw.SimpleTextOutlined( AGECHECK_TOP_TEXT_TWO, "Trebuchet18", w / 2, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 10, 10, 10, 255 ) )
	end
	
	-- Headline for the formula
	form_title = vgui.Create( "DPanel", ageCheckWindow )
	form_title:SetSize( 600, 150 )
	form_title:Center()
	form_title:SetPos(fullX * 0.5 - 300, fullY * 0.11)
	local w, h = form_title:GetSize()
	form_title:SetWrap(true)
	form_title.Paint = function()
		draw.SimpleTextOutlined( AGECHECK_FORM_TITLE, "Agetest_form_title", w / 2, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 10, 10, 10, 255 ) )
	end
	
	-- Disclaimer Background
	disclaimer_bg = vgui.Create( "DPanel", ageCheckWindow )
	if fullY == 480 then
		disclaimer_bg:SetSize( 10 + fullX * 0.9, 50 + 500 / (0.02 * fullY) )
	else
		disclaimer_bg:SetSize( 10 + fullX * 0.9, 50 + 700 / (0.03 * fullY) )
	end
	disclaimer_bg:SetPos( fullX * 0.05, fullY * 0.75 - 5 )
	disclaimer_bg.Paint = function()
		draw.RoundedBox( 5, 0, 0, fullX * 0.9, 50 + 1000 / (0.02 * fullY), Color( 60, 60, 75, 250 ) )
	end
	
	-- Disclaimer at the bottom
	bottom_disclaimer = vgui.Create( "DTextEntry", ageCheckWindow )
	local w, h = disclaimer_bg:GetSize()
	local x, y = disclaimer_bg:GetPos()
	local disclaimer_padding = 5
	bottom_disclaimer:SetPos( x + disclaimer_padding, y )
	-- bottom_disclaimer:Center()
	bottom_disclaimer:SetSize( w - (2 * disclaimer_padding), h )
	bottom_disclaimer:SetText( AGECHECK_DISCLAIMER )
	bottom_disclaimer:SetTextColor( Color( 200, 200, 0, 255 ) );		
	bottom_disclaimer:SetDrawBackground( false )
	bottom_disclaimer:SetDrawBorder( false )
	bottom_disclaimer:SetEditable( false )
	bottom_disclaimer:SetFont( "Trebuchet18" )
	bottom_disclaimer:SetMultiline( true )

	
	-- CHOICES (DAY, MONTH, YEAR)
	
	-- AGE
	local age = vgui.Create( "DComboBox" )
	age:SetParent( ageCheckWindow )
	age:Center()
	-- age:SetPos( 250, 130 )
	age:SetPos( fullX * 0.5 - 65, fullY * 0.3 )
	age:SetSize( 130, 30 )
	age:SetValue( AGECHECK_AGE )
	for i = 1, 99, 1 do
		age:AddChoice( i )
	end
	
	-- DAY
	local day = vgui.Create( "DComboBox" )
	day:SetParent( ageCheckWindow ) -- Set parent to our "DermaPanel"
	day:Center()
	day:SetPos( fullX * 0.25 - 65, fullY * 0.4 )
	day:SetSize( 130, 30 )
	day:SetValue( AGECHECK_DAY )
	for i = 1, 31, 1 do
		day:AddChoice( i )
	end
	
	-- MONTH
	local month = vgui.Create( "DComboBox" )
	month:SetParent( ageCheckWindow )
	month:Center()
	month:SetPos( fullX * 0.5 - 65, fullY * 0.4 )
	month:SetSize( 130, 30 )
	month:SetValue( AGECHECK_MONTH )
	for i = 1, 12, 1 do
		month:AddChoice( i )
	end
	
	-- YEAR
	local year = vgui.Create( "DComboBox" )
	year:SetParent( ageCheckWindow )
	year:Center()
	year:SetPos( fullX * 0.75 - 65, fullY * 0.4 )
	year:SetSize( 130, 30 )
	year:SetValue( AGECHECK_YEAR )
	for i = 1900, 2015, 1 do
		year:AddChoice( i )
	end
	
	-- ZODIAC SIGN
	local zodiac = vgui.Create( "DComboBox" )
	zodiac:SetParent( ageCheckWindow )
	zodiac:Center()
	zodiac:SetPos( fullX * 0.5 - 65, fullY * 0.5 )
	zodiac:SetSize( 130, 30 )
	zodiac:SetValue( AGECHECK_ZODIAC )
	for i = 1, #AGECHECK_ZODIACS, 1 do
		zodiac:AddChoice( AGECHECK_ZODIACS[i] )
	end
	
	-- SEND BORDER
	local send_border = vgui.Create( "DButton" )
	send_border:SetParent( ageCheckWindow )
	send_border:Center()
	send_border:SetPos( fullX * 0.5 - 70, fullY * 0.61 - 5 )
	send_border:SetSize( 140, 55 )
	send_border.Paint = function( self, w, h )
		draw.RoundedBox( 5, 0, 0, w, h, Color( 30, 30, 30, 255 ) ) -- Draw a blue button
	end
	
	-- SEND BUTTON
	local send = vgui.Create( "DButton" )
	send:SetParent( ageCheckWindow )
	send:SetText( AGECHECK_SUBMIT )
	send:Center()
	send:SetPos( fullX * 0.5 - 65, fullY * 0.61 )
	send:SetSize( 130, 45 )
	send:SetTextColor( Color( 255, 255, 255, 255 ) );
	send.Paint = function( self, w, h )
		draw.RoundedBox( 5, 0, 0, w, h, Color( 41, 128, 185, 255 ) ) -- Draw a blue button
	end
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