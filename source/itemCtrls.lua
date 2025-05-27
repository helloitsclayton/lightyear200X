local gfx <const> = playdate.graphics
local inp <const> = playdate.inputHandlers
local tmr <const> = playdate.timer
local ftmr <const> = playdate.frameTimer

local orbSpriteTbl = gfx.imagetable.new("images/tables/orb")
local orbSpriteAnim = gfx.animation.loop.new(50,orbSpriteTbl,true)
local inventory = {} -- this will contain the player's inventory
local menuSprites = {} -- holds menu sprites for removal later

function getInventory()
	return inventory
end

function removeItem(itemNo)
	inventory[itemNo] = nil
	if itemNo == 1 and inventory[2] then
		inventory[1] = inventory[2]
		inventory[2] = nil
	end
end

local function inventoryAdd(itemNo)
	if #inventory < 2 then
		if inventory[1] == nil then
			inventory[1] = itemNo
			print(inventory[1])
		else
			inventory[2] = itemNo
			print(inventory[2])
		end
	else
		setStatus("inv")
		print("Inventory full!")
		print(inventory[1].." "..inventory[2])
	end
end

local function orbTime(xCoord,itemNo)
	local orbTypeImg = gfx.image.new("images/orb"..itemTable[itemNo])
	local orbSprite = gfx.sprite.new()
	orbSprite:setSize(16,16)
	orbSprite:setCollideRect(0,0,orbSprite:getSize())
	orbSprite.collisionResponse = "overlap"
	orbSprite:setZIndex(7)
	orbSprite:moveTo(xCoord+24,48)
	local orbTimer = tmr.new(10000,48,(bgHeight+2)*64) -- Start timer paused?
	orbSprite.update = function()
		local actualX, actualY, collisions, numberOfCollisions = orbSprite:moveWithCollisions(xCoord+24,orbTimer.value)
		if numberOfCollisions > 0 then
			orbSprite:remove()
			inventoryAdd(itemNo)
		end
	end
	orbTimer.timerEndedCallback = function()
		orbSprite:remove()
	end
	orbSprite:add()
	function orbSprite:draw()
		orbSpriteAnim:draw(0,0)
		orbTypeImg:draw(0,0)
	end
end

local function purgeInv(invNo)
	inventory[invNo] = nil
	if invNo == 1 and inventory[2] then
		inventory[1] = inventory[2]
		inventory[2] = nil
	end
	local orbDropSprite = gfx.sprite.new(orbSpriteAnim:image())
	local orbDropTimer = tmr.new(10000,getPlayerSpriteY()+48,(bgHeight+2)*64)
	local orbDropX = getPlayerSpriteX()+24
	orbDropSprite:setCenter(0,0)
	orbDropSprite:setZIndex(7)
	function orbDropSprite:update()
		orbDropSprite:setImage(orbSpriteAnim:image())
		orbDropSprite:moveTo(orbDropX,orbDropTimer.value)
	end
	function orbDropTimer.timerEndedCallback()
		orbDropSprite:remove()
	end
	orbDropSprite:add()
end

local function repositionCursor(cursor,sprite)
	cursor:setSize(sprite.width+32,sprite.height+10)
	cursor:moveTo(sprite.x-8,sprite.y-6)
end

local function createTimerViz(value,xCoord,yCoord)
	gfx.pushContext()
	local timerViz = gfx.sprite.new()
	timerViz:setSize(54,10)
	function timerViz:draw()
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0,0,self:getSize())
		gfx.setPattern({0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA})
		gfx.fillRect(2,2,50,6)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(2,2,value,6)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawLine(3,4,value,4)
	end
	gfx.popContext()
	menuSprites[#menuSprites+1] = timerViz
	timerViz:setCenter(0,0)
	timerViz:setZIndex(31)
	timerViz:moveTo(xCoord,yCoord)
	timerViz:add()
end

function itemSelect(xCoord)
	local offsetX,offsetY = gfx.getDrawOffset()
	local menuSelectList = {} -- generates list of items to cycle through in pause menu

	local menuBgImg = gfx.image.new(250,240,gfx.kColorWhite)
	local menuBg = gfx.sprite.new(menuBgImg)
	menuSprites[#menuSprites+1] = menuBg
	menuBg:setCenter(0,0)
	menuBg:setZIndex(30)
	menuBg:moveTo(-offsetX,-offsetY)
	menuBg:add()

	local rummageBgImg = gfx.image.new("images/rummageBg")
	local rummageBg = gfx.sprite.new(rummageBgImg)
	menuSprites[#menuSprites+1] = rummageBg
	rummageBg:setCenter(0,0)
	rummageBg:setZIndex(31)
	rummageBg:moveTo(20-offsetX,5-offsetY)
	rummageBg:add()

	local rummagePlayerTopImg = gfx.image.new("images/playerTop")
	local rummagePlayerTop = gfx.sprite.new(rummagePlayerTopImg)
	menuSprites[#menuSprites+1] = rummagePlayerTop
	rummagePlayerTop:setCenter(0,0)
	rummagePlayerTop:setZIndex(32)
	rummagePlayerTop:moveTo(20-offsetX,5-offsetY)
	rummagePlayerTop:add()

	local rummageTopFeetTbl = gfx.imagetable.new("images/tables/topFeet")
	local rummageTopFeetIdle = gfx.animation.loop.new(200,rummageTopFeetTbl,true)
	local rummageTopFeet = gfx.sprite.new(rummageTopFeetIdle:image())
	menuSprites[#menuSprites+1] = rummageTopFeet
	function rummageTopFeet:update()
		rummageTopFeet:setImage(rummageTopFeetIdle:image())
	end
	rummageTopFeet:setCenter(0,0)
	rummageTopFeet:setZIndex(33)
	rummageTopFeet:moveTo(20-offsetX,5-offsetY)
	rummageTopFeet:add()

	local rummageTopArmTbl =  gfx.imagetable.new("images/tables/topArm")
	local rummageTopArmAnim = gfx.animation.loop.new(500,rummageTopArmTbl,true)
	rummageTopArmAnim.startFrame = 4
	rummageTopArmAnim.endFrame = 5
	local rummageTopArm = gfx.sprite.new(rummageTopArmAnim:image())
	menuSprites[#menuSprites+1] = rummageTopArm
	function rummageTopArm:update()
		rummageTopArm:setImage(rummageTopArmAnim:image())
	end
	rummageTopArm:setCenter(0,0)
	rummageTopArm:setZIndex(33)
	rummageTopArm:moveTo(20-offsetX,5-offsetY)
	rummageTopArm:add()

	-- add menus
	local font = gfx.font.new("images/font/Roobert-11-Mono-Condensed")
	gfx.setFont(font)
	local menuTitle = gfx.sprite.new()
	menuTitle:setSize(240,20)
	menuSprites[#menuSprites+1] = menuTitle
	menuTitle.text = "What do you need?"
	menuTitle.currentText = ""
	menuTitle:setCenter(0,0)
	menuTitle:moveTo(104-offsetX,20-offsetY)
	menuTitle:setZIndex(31)
	menuTitle:add()

	-- draw one letter at a time
	local titleRevealTimer = ftmr.new(30,1,#menuTitle.text)
	function titleRevealTimer:updateCallback()
		menuTitle:markDirty()
		menuTitle.currentText = string.sub(menuTitle.text,1,math.floor(titleRevealTimer.value))
	end
	function menuTitle:draw()
		gfx.drawText(menuTitle.currentText,0,0)
	end

	gfx.pushContext()
	local font = gfx.font.new("images/font/fixeight")
	gfx.setFont(font)
	for i=1,3 do
		menuSelectList[i] = gfx.sprite.spriteWithText(string.upper(itemTable[i]),48,10)
		menuSprites[#menuSprites+1] = menuSelectList[i]
		menuSelectList[i]:setCenter(0,0)
		menuSelectList[i]:moveTo(108-offsetX,28+16*i-offsetY)
		menuSelectList[i]:setZIndex(31)
		menuSelectList[i]:add()
	end
	gfx.popContext()

	local inventoryText = gfx.sprite.spriteWithText("Purge\ninventory:",240,40)
	menuSprites[#menuSprites+1] = inventoryText
	inventoryText:setCenter(0,0)
	inventoryText:moveTo(20-offsetX,85-offsetY)
	inventoryText:setZIndex(31)
	inventoryText:add()
	local orbTypeImg = nil
	local inventoryMenu = {}
	if inventory[1] then
		orbTypeImg = gfx.image.new("images/bigOrb"..itemTable[inventory[1]])
		inventoryMenu[1] = gfx.sprite.new(orbTypeImg)
		menuSelectList[4]=inventoryMenu[1]
	else
		orbTypeImg = gfx.image.new("images/bigOrbEmpty")
		inventoryMenu[1] = gfx.sprite.new(orbTypeImg)
	end
	if inventory[2] then
		orbTypeImg = gfx.image.new("images/bigOrb"..itemTable[inventory[2]])
		inventoryMenu[2] = gfx.sprite.new(orbTypeImg)
		menuSelectList[5]=inventoryMenu[2]
	else
		orbTypeImg = gfx.image.new("images/bigOrbEmpty")
		inventoryMenu[2] = gfx.sprite.new(orbTypeImg)
	end
	for i=1,2 do
		inventoryMenu[i]:setCenter(0,0)
		inventoryMenu[i]:moveTo(108-offsetX,54+40*i-offsetY)
		inventoryMenu[i]:setZIndex(31)
		inventoryMenu[i]:add()
	end

	local itemCursorImg = gfx.image.new("images/menuSelect")
	local selectIconImg = gfx.image.new("images/AIcon")
	local itemCursor = gfx.sprite.new()
	menuSprites[#menuSprites+1] = itemCursor
	itemNo = 1
	itemCursor:setCenter(0,0)
	itemCursor:setZIndex(32)
	repositionCursor(itemCursor,menuSelectList[1])
	itemCursor:add()
	function itemCursor:draw()
		selectIconImg:draw(itemCursor.width-16,itemCursor.height/2-8)
		itemCursorImg:draw(0,itemCursor.height-6,"flipY")
		itemCursorImg:draw(itemCursor.width-24,0,"flipX")
	end

	local distressListBgImg = gfx.image.new(150,240,gfx.kColorWhite)
	local distressListBg = gfx.sprite.new(distressListBgImg)
	menuSprites[#menuSprites+1] = distressListBg
	distressListBg:setCenter(0,0)
	distressListBg:moveTo(250-offsetX,-offsetY)
	distressListBg:setZIndex(30)
	distressListBg:add()

	local distressList = {}

	gfx.pushContext()
	local font = gfx.font.new("images/font/Flak Attack")
	gfx.setFont(font)
	if theDistressed then
		for y,distressRow in pairs(theDistressed) do
			for x,distressPod in pairs(distressRow) do
				distressList[#distressList+1] = gfx.sprite.spriteWithText(string.char(distressPod.x+63)..distressPod.y.." "..string.sub(itemTable[distressPod.type],1,1),150,20)
				distressList[#distressList]:setCenter(0,0)
				distressList[#distressList]:setZIndex(31)
				distressList[#distressList]:moveTo(270-offsetX,20*#distressList-offsetY)
				distressList[#distressList]:add()
				createTimerViz(math.floor(distressPod.timer.value),310-offsetX,20*#distressList-1-offsetY)
			end
		end
	end
	gfx.popContext()

	local cancelIconImg = gfx.image.new("images/BIcon")
	local cancelIcon = gfx.sprite.new(cancelIconImg)
	menuSprites[#menuSprites+1] = cancelIcon
	cancelIcon:setCenter(0,0)
	cancelIcon:moveTo(20-offsetX,210-offsetY)
	cancelIcon:setZIndex(31)
	cancelIcon:add()
	local cancelText = gfx.sprite.spriteWithText("Cancel",240,20)
	menuSprites[#menuSprites+1] = cancelText
	cancelText:setCenter(0,0)
	cancelText:moveTo(40-offsetX,211-offsetY)
	cancelText:setZIndex(31)
	cancelText:add()

	local menuInputHandler = {
		AButtonDown = function()
			if itemNo <= 3 then
				orbTime(xCoord,itemNo)
				gfx.sprite.removeSprites(menuSprites)
				gfx.sprite.removeSprites(inventoryMenu)
				gfx.sprite.removeSprites(distressList)
				timersCtrl("start")
				inp.pop()
			elseif inventory[itemNo-3] then
				purgeInv(itemNo-3)
				gfx.sprite.removeSprites(menuSprites)
				gfx.sprite.removeSprites(inventoryMenu)
				gfx.sprite.removeSprites(distressList)
				timersCtrl("start")
				inp.pop()
			end
		end,
		BButtonDown = function()
			gfx.sprite.removeSprites(menuSprites)
			gfx.sprite.removeSprites(inventoryMenu)
			gfx.sprite.removeSprites(distressList)
			timersCtrl("start")
			inp.pop()
		end,
		upButtonDown = function()
			if itemNo == 1 then
				itemNo = #menuSelectList
			else
				itemNo -= 1
			end
			repositionCursor(itemCursor,menuSelectList[itemNo])
		end,
		downButtonDown = function()
			if itemNo == #menuSelectList then
				itemNo = 1
			else
				itemNo += 1
			end
			repositionCursor(itemCursor,menuSelectList[itemNo])
		end,
		leftButtonDown = function()
		end,
		rightButtonDown = function()
		end,
		cranked = function()
		end
	}
	inp.push(menuInputHandler)
end