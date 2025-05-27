-- You'll want to import these in just about every project you'll work on:
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"
import "CoreLibs/animation"

import "startUp"
import "infoPgs"
import "playerSprites"
import "bgTiles"
import "itemCtrls"

local gfx <const> = playdate.graphics
local inp <const> = playdate.inputHandlers
local tmr <const> = playdate.timer
local ftmr <const> = playdate.frameTimer
local dat <const> = playdate.datastore

itemTable = {"Food","Meds","Water"}
theLiving = nil -- will hold count of still living pods; zero will trigger game fail state
theHealthy = {} -- will hold table of all living pods which have no active distress calls
theDistressed = {} -- will hold table of all living pods which have active distress calls
bgWidth,bgHeight=10,6 -- sets size of playing field

local gameIsActive=false
local gameIsOver=false
local statusMsg=nil
local distressTimer=nil

local crankInputVert = {
	AButtonDown = function()
		collisionTest()
	end,
	BButtonDown = function()
		local xCoord = getPlayerSpriteX()
		timersCtrl("pause")
		itemSelect(xCoord)
	end,
	upButtonDown = function()
	end,
	downButtonDown = function()
	end,
	leftButtonDown = function()
		crankInputSwap("vert")
	end,
	rightButtonDown = function()
		crankInputSwap("vert")
	end,
	cranked = function(change,accelChange)
		local offsetX,offsetY = gfx.getDrawOffset()
		local playerSpriteX = getPlayerSpriteX()
		if change > 0 then -- reel playerSprite up
			playerSpriteIdleCtrl("paused",true)
			playerArmsIdleCtrl("paused",true)
			topArmIdleCtrl("paused",true)
			playerSpriteMoveBy(0,-4)
			local playerSpriteY = getPlayerSpriteY()
			if playerSpriteY > 88 and playerSpriteY < bgHeight*64-152 then
				gfx.setDrawOffset(offsetX,-(playerSpriteY-88))
			end
			playerSpriteMoveTo(playerSpriteX,math.max(playerSpriteY,64))
		elseif change < 0 then -- feed playerSprite down
			playerSpriteIdleCtrl("paused",true)
			playerArmsIdleCtrl("paused",true)
			topArmIdleCtrl("paused",true)
			playerSpriteMoveBy(0,4)
			local playerSpriteY = getPlayerSpriteY()
			if playerSpriteY > 88 and playerSpriteY < bgHeight*64-152 then
				gfx.setDrawOffset(offsetX,-(playerSpriteY-88))
			end
			playerSpriteMoveTo(playerSpriteX,math.min(playerSpriteY,bgHeight*64-96))
		end
	end
}

local crankInputHoriz = {
	AButtonDown = function()
		collisionTest()
	end,
	BButtonDown = function()
		local xCoord = getPlayerSpriteX()
		timersCtrl("pause")
		itemSelect(xCoord)
	end,
	upButtonDown = function()
		crankInputSwap("horiz")
	end,
	downButtonDown = function()
		crankInputSwap("horiz")
	end,
	leftButtonDown = function()
	end,
	rightButtonDown = function()
	end,
	cranked = function(change,accelChange)
		local offsetX,offsetY = gfx.getDrawOffset()
		local playerSpriteY = getPlayerSpriteY()
		if change > 0 then -- scroll playerSprite right
			platformGearAnimCtrl("step",1)
			platformGearAnimCtrl("paused",false)
			playerSpriteIdleCtrl("paused",true)
			playerArmsIdleCtrl("paused",true)
			topArmIdleCtrl("paused",true)
			playerSpriteMoveBy(4,0)
			local playerSpriteX = getPlayerSpriteX()
			if playerSpriteX > 168 and playerSpriteX < bgWidth*64-232 then
				gfx.setDrawOffset(-(playerSpriteX-168),offsetY)
			end
			playerSpriteMoveTo(math.min(playerSpriteX,bgWidth*64-96),playerSpriteY)
		elseif change < 0 then -- scroll playerSprite left
			platformGearAnimCtrl("step",3)
			platformGearAnimCtrl("paused",false)
			playerSpriteIdleCtrl("paused",true)
			playerArmsIdleCtrl("paused",true)
			topArmIdleCtrl("paused",true)
			playerSpriteMoveBy(-4,0)
			local playerSpriteX = getPlayerSpriteX()
			if playerSpriteX > 168 and playerSpriteX < bgWidth*64-232 then
				gfx.setDrawOffset(-(playerSpriteX-168),offsetY)
			end
			playerSpriteMoveTo(math.max(playerSpriteX,32),playerSpriteY)
		end
	end
}

function crankInputSwap(current)
	inp.pop()
	crankUD:remove()
	crankLR:remove()
	local icon = nil
	if current == "horiz" then
		icon = crankUD
		inp.push(crankInputVert)
	elseif current == "vert" then
		icon = crankLR
		inp.push(crankInputHoriz)
	end
	icon:setIgnoresDrawOffset(true)
	icon:moveTo(358,10)
	icon:setZIndex(25)
	icon:add()
end

function timersCtrl(param)
	print("timersCtrl")
	local timerArray = tmr.allTimers()
	local ftimerArray = ftmr.allTimers()
	if param == "pause" then
		print("timersCtrl pause")
		for i,timer in ipairs(timerArray) do
			timer:pause()
		end
		for i,timer in ipairs(ftimerArray) do
			timer:pause()
		end
	elseif param == "start" then
		print("timersCtrl start")
		for i,timer in ipairs(timerArray) do
			timer:start()
		end
		for i,timer in ipairs(ftimerArray) do
			timer:start()
		end
	end
end

function setStatus(param)
	if statusMsg then
		statusMsg:remove()
		statusMsg = nil
	end
	if param == "inv" then
		statusMsg = gfx.sprite.new()
		statusMsg:setSize(80,12)
		statusMsg:setCenter(0,0)
		statusMsg:setZIndex(25)
		statusMsg:setIgnoresDrawOffset(true)
		function statusMsg:draw()
			gfx.pushContext(statusMsg)
			local font = gfx.font.new("images/font/T-Mek")
			gfx.setFont(font)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(0,0,statusMsg:getSize())
			gfx.drawText("INV FULL",4,3)
			gfx.setColor(gfx.kColorXOR)
			gfx.fillRect(0,0,statusMsg:getSize())
			gfx.popContext(statusMsg)
		end
		statusMsg:moveTo(300,220)
		statusMsg:add()
	end
	local statusTimer = tmr.new(750)
	statusTimer.timerEndedCallback = function()
		statusMsg:remove()
		statusMsg=nil
	end
end

local function timesUp(podX,podY)
	print("Time's up!")
	theDistressed[podY][podX]=nil
	bgChange(podX,podY,2)
	theLiving-=1
end

local function generateDistress()
	distressTimer:start()
	local distressPodIndex = math.random(#theHealthy)
	local distressPod = theHealthy[distressPodIndex]
	local i = distressPodIndex+1
	while theHealthy[i] do
		theHealthy[i-1] = theHealthy[i]
		i += 1
	end
	theHealthy[i-1] = nil
	local localX, localY = distressPod.x, distressPod.y
	if not theDistressed[localY] then
		theDistressed[localY]={}
	end
	theDistressed[localY][localX] = {}
	theDistressed[localY][localX].x = localX
	theDistressed[localY][localX].y = localY
	theDistressed[localY][localX].type = math.random(3)
	--local podTimer = tmr.new(100,50,0)
	local podTimer = tmr.new(25000+math.random(5000),50,0)
	theDistressed[localY][localX].timer = podTimer
	bgChange(localX,localY,theDistressed[localY][localX].type+11)
	print(localX.." "..localY.." "..theDistressed[localY][localX].type)
	podTimer.timerEndedCallback = function()
		timesUp(localX,localY)
	end
end

function gameInit(continue)
	math.randomseed(playdate.getSecondsSinceEpoch())
	bgLoad(bgWidth,bgHeight,continue)
	playerSpriteInit()
	if continue then
		local loadStateTbl=dat.read("ly200Xsave")
		playerSpriteMoveTo(loadStateTbl.x,loadStateTbl.y)
		theLiving=loadStateTbl.theLiving
		theHealthy=loadStateTbl.theHealthy
		theDistressed=loadStateTbl.theDistressed
		dat.delete("ly200Xsave")
		proFile.continue=false
		dat.write(proFile,"lightyear200X")
	end

	local crankUDTbl = gfx.imagetable.new("images/tables/crankUD")
	local crankUDAnim = gfx.animation.loop.new(500,crankUDTbl,true)
	crankUD = gfx.sprite.new(crankUDAnim:image())
	crankUD.update = function()
		crankUD:setImage(crankUDAnim:image())
	end
	crankUD:setCenter(0,0)
	local crankLRTbl = gfx.imagetable.new("images/tables/crankLR")
	local crankLRAnim = gfx.animation.loop.new(500,crankLRTbl,true)
	crankLR = gfx.sprite.new(crankLRAnim:image())
	crankLR.update = function()
		crankLR:setImage(crankLRAnim:image())
	end
	crankLR:setCenter(0,0)

	--distressTimer = tmr.new(100)
	distressTimer = tmr.new(8000)
	distressTimer.repeats = true
	distressTimer.timerEndedCallback = function()
		if #theHealthy > 0 then
			distressTimer:pause()
			tmr.performAfterDelay(math.random(2000),generateDistress)
			--generateDistress()
		else
			print("All pods in distress")
			distressTimer:pause()
		end
	end

	gameIsActive=true
	crankInputSwap("vert")
end

local function gameOver()
	gameIsOver=true
	gameIsActive=false
	timersCtrl("pause")
	inp.pop()
	local gameOverSprite=gfx.sprite.new()
	gameOverSprite:setSize(400,70)
	gameOverSprite:setIgnoresDrawOffset(true)
	local restartIcn=gfx.image.new("images/AIcon")
	function gameOverSprite:draw()
		gfx.pushContext(gameOverSprite)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0,0,gameOverSprite:getSize())
		local font = gfx.font.new("images/font/Roobert-24-Medium-Halved")
		gfx.setFont(font)
		gfx.drawText("Game Over",120,12)
		restartIcn:draw(160,45)
		font=gfx.font.new("images/font/Roobert-9-Mono-Condensed")
		gfx.setFont(font)
		gfx.drawText("Main menu",180,46)
		gfx.popContext(gameOverSprite)
	end
	gameOverSprite:moveTo(200,120)
	gameOverSprite:setZIndex(99)
	gameOverSprite:add()

	local gameOverInp = {
		AButtonDown = function()
			gameIsOver=false
			gfx.sprite.removeAll()
			inp.pop()
			startUp()
		end,
		BButtonDown = function()
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
	inp.push(gameOverInp)
end

function saveState()
	local saveStateTbl = {}
	saveStateTbl.x=getPlayerSpriteX()
	saveStateTbl.y=getPlayerSpriteY()
	saveStateTbl.theLiving=theLiving
	saveStateTbl.theHealthy=theHealthy
	saveStateTbl.theDistressed=theDistressed
	proFile.continue=true
	dat.write(saveStateTbl,"ly200Xsave")
	dat.write(proFile,"lightyear200X")
end

function playdate.deviceWillLock()
	if gameIsActive then
		saveState()
	end
end

function playdate.gameWillPause()
	if gameIsActive then
		saveState()
	end
end

startUp()

function playdate.update()
	local crankChange, crankAccel = playdate.getCrankChange()
	if crankChange == 0 and gameIsActive then
		playerSpriteIdleCtrl("paused",false)
		playerArmsIdleCtrl("paused",false)
		topArmIdleCtrl("paused",false)
		platformGearAnimCtrl("paused",true)
	end

	if theLiving == 0 and gameIsActive then
		print("Game Over")
		gameOver()
	end

	--[[if playdate.buttonIsPressed(playdate.kButtonA) and gameIsOver then
		gameIsOver=false
		gfx.sprite.removeAll()
		gfx.clear()
		startUp()
	end]]

	gfx.sprite.update()
	tmr.updateTimers()
	ftmr.updateTimers()
end