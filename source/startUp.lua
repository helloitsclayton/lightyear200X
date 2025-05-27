local gfx <const> = playdate.graphics
local inp <const> = playdate.inputHandlers

function startUp()
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.clear()

	proFile=playdate.datastore.read("lightyear200X")
	if not proFile then
		newGameProfile()
		print("Generating new game profile")
		proFile=playdate.datastore.read("lightyear200X")
	else
		print("Saved profile found")
	end

	local menuList={}
	if proFile.continue then
		menuList={"New game","Continue","How to play","Credits"}
		print("Continue")
	else
		menuList={"New game","How to play","Credits"}
		print("No continue")
	end
	local menuSelectMax=#menuList
	local menuSelectNo=1

	local font = gfx.font.new("images/font/Roobert-11-Mono-Condensed")
	gfx.setFont(font)

	local AIconImg=gfx.image.new("images/AIcon")
	local AIcon=gfx.sprite.new(AIconImg)
	AIcon:setCenter(0,0)
	AIcon:setZIndex(10)
	AIcon:moveTo(20,20)
	AIcon:add()

	for i=1,menuSelectMax do
		menuList[menuList[i]]=gfx.sprite.spriteWithText(menuList[i],100,20)
		menuList[menuList[i]]:setCenter(0,0)
		menuList[menuList[i]]:setZIndex(10)
		menuList[menuList[i]]:moveTo(40,20*i)
		menuList[menuList[i]]:add()
	end

	--[[local deathCount = gfx.sprite.spriteWithText(proFile.deathCount.." colonists lost.",200,20)
	deathCount:setCenter(0,0)
	deathCount:setZIndex(10)
	deathCount:moveTo(250,200)
	deathCount:add()]]

	local startUpInp = {
		AButtonDown = function()
			if menuList[menuSelectNo]=="New game" then
				gfx.sprite.removeAll()
				inp.pop()
				gameInit(false)
			elseif menuList[menuSelectNo]=="Continue" then
				gfx.sprite.removeAll()
				inp.pop()
				gameInit(true)
			elseif menuList[menuSelectNo]=="How to play" then
				gfx.sprite.removeAll()
				inp.pop()
				howToPlay()
			elseif menuList[menuSelectNo]=="Credits" then
				gfx.sprite.removeAll()
				inp.pop()
				credits()
			end
		end,
		BButtonDown = function()
		end,
		upButtonDown = function()
			if menuSelectNo == 1 then
				menuSelectNo = menuSelectMax
				AIcon:moveBy(0,20*(menuSelectMax-1))
			else
				menuSelectNo -= 1
				AIcon:moveBy(0,-20)
			end
		end,
		downButtonDown = function()
			if menuSelectNo == menuSelectMax then
				menuSelectNo = 1
				AIcon:moveBy(0,-20*(menuSelectMax-1))
			else
				menuSelectNo += 1
				AIcon:moveBy(0,20)
			end
		end,
		leftButtonDown = function()
		end,
		rightButtonDown = function()
		end,
		cranked = function(change,accelChange)
		end
	}
	inp.push(startUpInp)
end

function newGameProfile()
	proFile = {}
	proFile.deathCount = 0
	proFile.continue = false
	playdate.datastore.write(proFile,"lightyear200X")
end