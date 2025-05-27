local gfx <const> = playdate.graphics
local tmr <const> = playdate.timer
local inp <const> = playdate.inputHandlers

local playerSprite = nil
local playerSpriteIdle = nil
local playerArms = nil
local playerArmsIdle = nil
local playerArmsReach = nil
local topArmIdle = nil
local platformGearAnim = nil

function playerSpriteMoveBy(x,y)
	playerSprite:moveBy(x,y)
end

function playerSpriteMoveTo(x,y)
	playerSprite:moveTo(x,y)
end

function playerSpriteIdleCtrl(parameter,setting)
	playerSpriteIdle[parameter] = setting
end

function playerArmsIdleCtrl(parameter,setting)
	playerArmsIdle[parameter] = setting
end

function topArmIdleCtrl(parameter,setting)
	topArmIdle[parameter] = setting
end

function platformGearAnimCtrl(parameter,setting)
	platformGearAnim[parameter] = setting
end

function getPlayerSpriteX()
	return playerSprite.x
end

function getPlayerSpriteY()
	return playerSprite.y
end

function playerSpriteInit()
	local playerSpriteIdleTbl = gfx.imagetable.new("images/tables/playerSprite")
	playerSpriteIdle = gfx.animation.loop.new(500,playerSpriteIdleTbl,true)
	playerSprite = gfx.sprite.new(playerSpriteIdle:image())
	playerSprite:setCenter(0,0)
	playerSprite:setCollideRect(0,16,56,45)
	function playerSprite:update()
		playerSprite:setImage(playerSpriteIdle:image())
	end
	playerSprite:moveTo(56,64)
	playerSprite:setZIndex(10)
	playerSprite:add()

	local playerArmsIdleTbl = gfx.imagetable.new("images/tables/playerArmsIdle")
	playerArmsIdle = gfx.animation.loop.new(500,playerArmsIdleTbl,true)
	playerArms = gfx.sprite.new(playerArmsIdle:image())
	playerArms:setCenter(0,0)
	function playerArms:update()
		playerArms:moveTo(playerSprite.x,playerSprite.y)
		playerArms:setImage(playerArmsIdle:image())
	end
	playerArms:setZIndex(9)
	playerArms:add()

	local playerArmsReachTbl = gfx.imagetable.new("images/tables/playerArmsReach")
	playerArmsReach = gfx.animation.loop.new(250,playerArmsReachTbl,false)
	playerArmsReach.paused = true
	playerArmsReach.frame = 1

	local playerTopImg = gfx.image.new("images/playerTop")
	local playerTop = gfx.sprite.new(playerTopImg)
	playerTop:setCenter(0,0)
	function playerTop:update()
		playerTop:moveTo(playerSprite.x-12,0)
	end
	playerTop:setZIndex(5)
	playerTop:add()

	local topFeetTable = gfx.imagetable.new("images/tables/topFeet")
	local topFeetIdle = gfx.animation.loop.new(200,topFeetTable,true)
	local topFeet = gfx.sprite.new(topFeetIdle:image())
	topFeet:setCenter(0,0)
	function topFeet:update()
		topFeet:setImage(topFeetIdle:image())
		topFeet:moveTo(playerSprite.x-12,0)
	end
	topFeet:setZIndex(6)
	topFeet:add()

	local topArmTable = gfx.imagetable.new("images/tables/topArm")
	topArmIdle = gfx.animation.loop.new(500,topArmTable,true)
	topArmIdle.endFrame = 2
	local topArm = gfx.sprite.new(topArmIdle:image())
	topArm:setCenter(0,0)
	function topArm:update()
		topArm:setImage(topArmIdle:image())
		topArm:moveTo(playerSprite.x-12,0)
	end
	topArm:setZIndex(6)
	topArm:add()

	local platformGearTable = gfx.imagetable.new("images/tables/platformGear")
	platformGearAnim = gfx.animation.loop.new(200,platformGearTable,true)
	platformGearAnim.paused=true
	local platformGear = gfx.sprite.new(platformGearAnim:image())
	platformGear:setCenter(0,0)
	function platformGear:update()
		platformGear:moveTo(playerSprite.x-12,0)
		platformGear:setImage(platformGearAnim:image())
	end
	platformGear:setZIndex(5)
	platformGear:add()

	local playerLines = gfx.sprite.new()
	playerLines:setCenter(0,0)
	function playerLines:draw()
		gfx.pushContext()
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(3)
		gfx.drawLine(14,0,14,self.height)
		gfx.drawLine(36,0,36,self.height)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(1)
		gfx.drawLine(14,0,14,self.height)
		gfx.drawLine(36,0,36,self.height)
		gfx.popContext()
	end
	function playerLines:update() -- resize and move playerLines
		playerLines:setSize(64,playerSprite.y)
		playerLines:moveTo(playerSprite.x,32)
	end
	playerLines:setZIndex(0)
	playerLines:add()
end

function collisionTest()-- tests how far playerSprite is away from being centered on a particular tile
	local emptyInp={
	AButtonDown = function()
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
	inp.push(emptyInp)
	print("collisionTest")
	if (playerSprite.x%64 <= 16 or playerSprite.x%64 >= 48) and (playerSprite.y%64 <= 16 or playerSprite.y%64 >=48) then
		print(1+math.floor((playerSprite.x+32)/64).." "..math.floor((playerSprite.y+32)/64)+1)
		playerArmsIdle.paused=true
		playerArmsIdle.frame=1
		playerArms:setImage(playerArmsReach:image())
		function playerArms:update()
			playerArms:setImage(playerArmsReach:image())
		end
		playerArmsReach.paused = false
		tmr.performAfterDelay(1250,spriteTouch,math.floor((playerSprite.x+32)/64)+1,math.floor((playerSprite.y+32)/64)+1)
	else
		print("nope"..playerSprite.x.." "..playerSprite.y)
	end
end

function spriteTouch(x,y)
	print("spriteTouch")
	local inventory = getInventory()
	if inventory[1] and inventory[1] == theDistressed[y][x].type then
		print("Correct item!")
		removeItem(1)
		theHealthy[#theHealthy+1]={x=x,y=y}
		print(theHealthy[#theHealthy].x.." "..theHealthy[#theHealthy].y)
		bgChange(x,y,1)
		theDistressed[y][x] = nil
	elseif inventory[2] and inventory[2] == theDistressed[y][x].type then
		print("Correct item!")
		removeItem(2)
		theHealthy[#theHealthy+1]={x=x,y=y}
		print(theHealthy[#theHealthy].x.." "..theHealthy[#theHealthy].y)
		bgChange(x,y,1)
		theDistressed[y][x] = nil
	else
		print("Wrong items!")
	end
	playerArmsReach.step=4
	playerArmsReach.paused=true
	playerArmsReach.shouldLoop=true
	tmr.performAfterDelay(500,returnSpriteArms)
end

function returnSpriteArms()
	print("returnSpriteArms")
	playerArmsReach.frame=5
	playerArmsReach.paused=false
	tmr.performAfterDelay(1000,spriteArmsToIdle)
end

function spriteArmsToIdle()
	print("spriteArmsToIdle")
	playerArms:setImage(playerArmsIdle:image())
	playerArmsIdle.paused=false
	function playerArms:update()
		playerArms:moveTo(playerSprite.x,playerSprite.y)
		playerArms:setImage(playerArmsIdle:image())
	end
	playerArmsReach.paused=true
	playerArmsReach.frame=1
	playerArmsReach.shouldLoop=false
	playerArmsReach.step=1
	inp.pop()
end