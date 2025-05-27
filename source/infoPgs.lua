local gfx <const> = playdate.graphics
local inp <const> = playdate.inputHandlers

local font = gfx.font.new("images/font/Roobert-11-Mono-Condensed")
gfx.setFont(font)

local infoInp={
	AButtonDown = function()
	end,
	BButtonDown = function()
		gfx.sprite.removeAll()
		inp.pop()
		startUp()
	end,
	upButtonDown = function()
	end,
	downButtonDown = function()
	end,
	leftButtonDown = function()
	end,
	rightButtonDown = function()
	end,
	cranked = function(change,accelChange)
	end
}

function howToPlay()
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.clear()

	local howToPlayMsg=gfx.sprite.spriteWithText("I haven't done this yet, press B to go back.",200,120)
	howToPlayMsg:setCenter(0,0)
	howToPlayMsg:setZIndex(10)
	howToPlayMsg:moveTo(40,40)
	howToPlayMsg:add()

	inp.push(infoInp)
end

function credits()
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.clear()

	local creditsMsg=gfx.sprite.spriteWithText("I haven't done this yet, press B to go back.",200,120)
	creditsMsg:setCenter(0,0)
	creditsMsg:setZIndex(10)
	creditsMsg:moveTo(40,40)
	creditsMsg:add()

	inp.push(infoInp)
end