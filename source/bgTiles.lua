local gfx <const> = playdate.graphics
--local geo <const> = playdate.geometry
--local tmr <const> = playdate.timer

local bg = nil
local bgMap = nil
local bgMask = nil
local bgMaskTable = nil
local bgMaskMap = nil
local bgLoadFile = nil

function bgChange(podX,podY,tileNo)
	bgMap:setTileAtPosition(podX,podY,tileNo)
	bgLoadFile[podY][podX]=tileNo
	playdate.datastore.write(bgLoadFile,"podMatrix")
end

function bgLoad(width,height,continue)
	gfx.setBackgroundColor(gfx.kColorBlack)
	gfx.clear()

	if continue then
		print("Continue")
	else
		print("New game")
		generateTable(width,height)
	end
	bgLoadFile = playdate.datastore.read("podMatrix")
	local podTiles = gfx.imagetable.new("images/tables/pods")
	bgMapW = bgLoadFile["width"]
	bgMapH = bgLoadFile["height"]
	bgMap = gfx.tilemap.new()
	bgMap:setImageTable(podTiles)
	bgMap:setSize(bgMapW,bgMapH)

	theLiving=0
	for y=1,bgMapH do
		for x=1,bgMapW do
			bgMap:setTileAtPosition(x,y,bgLoadFile[y][x])
			if bgLoadFile[y][x] == 1 then
				theHealthy[#theHealthy+1]={}
				theHealthy[#theHealthy].x=x
				theHealthy[#theHealthy].y=y
				theLiving+=1
			end
		end
	end

	print(theLiving)

	bg = gfx.sprite.new()
	bg:setTilemap(bgMap)
	bg:setCenter(0,0)

	bgMaskTable = gfx.imagetable.new(4,2) -- this will contain masks that will overlay the bg tiles
	for x = 1,4 do
		local maskImg = gfx.image.new(64,64)
		local maskImgMask = maskImg:getMaskImage():copy()
		gfx.pushContext(maskImgMask)
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern((9-x)/8, gfx.image.kDitherTypeBayer8x8)
		gfx.fillRect(0,0,maskImgMask:getSize())
		gfx.popContext()
		maskImg:setMaskImage(maskImgMask)
		bgMaskTable:setImage(x,maskImg)
	end
	bgMaskMap = gfx.tilemap.new() -- this will map the masks in bgMaskTable
	bgMaskMap:setImageTable(bgMaskTable)
	bgMaskMap:setSize(bgMapW,bgMapH)
	bgMask = gfx.sprite.new()
	bgMask:setTilemap(bgMaskMap)
	bgMask:setCenter(0,0)

	function bgMask:update() -- updates mask tiles based on distance to playerSprite
		for y=1,bgMapH do
			for x=1,bgMapW do
				if tileDist(x,y,1) then
					bgMaskMap:setTileAtPosition(x,y,1)
				elseif tileDist(x,y,2) then
					bgMaskMap:setTileAtPosition(x,y,2)
				elseif tileDist(x,y,3) then
					bgMaskMap:setTileAtPosition(x,y,3)
				else
					bgMaskMap:setTileAtPosition(x,y,4)
				end
			end
		end
	end

	bg:moveTo(0,0)
	bg:setZIndex(-10)
	bg:add()
	bgMask:moveTo(0,0)
	bgMask:setZIndex(20)
	bgMask:add()
end

function generateTable(width,height)
	local bgSaveFile={}
	bgSaveFile["width"]=width
	bgSaveFile["height"]=height
	bgSaveFile[1]={}
	bgSaveFile[height]={}
	bgSaveFile[1][1]=4
	bgSaveFile[1][width]=6
	bgSaveFile[height][1]=9
	bgSaveFile[height][width]=11
	for y=2,height-1 do
		bgSaveFile[y]={}
		bgSaveFile[y][1]=7
		bgSaveFile[y][width]=8
		for x=2,width-1 do
			bgSaveFile[1][x]=5
			bgSaveFile[height][x]=10
			bgSaveFile[y][x]=1
		end
	end
	playdate.datastore.write(bgSaveFile,"podMatrix")
end

function tileDist(x,y,n) -- determines if playerSprite is within n tiles of the bg tile at x,y
	if math.abs(64*(x-1)-getPlayerSpriteX()) <= 64*n+32 and math.abs(64*(y-1)-getPlayerSpriteY()) <= 64*n+32 then
		return true
	else
		return false
	end
end