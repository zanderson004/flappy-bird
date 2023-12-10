-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Seed Randomness
math.randomseed(os.time())

-- Initialise Physics
local physics = require("physics")
physics.start()
physics.setGravity(0, 40)

-- Create Fonts
local flappyCounterFont = native.newFont("flappyCounterFont.ttf")
local flappyFont = native.newFont("flappyfont.ttf")

-- Create Background
local background = display.newImageRect("background.png", 700, 400)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Create Floor Table
floors = {}

-- Create Score Display
local scoreDisplay = display.newText({text=0, x=display.contentCenterX, y=50, font=flappyCounterFont, fontSize=50})
scoreDisplay:setFillColor(0, 0, 0)

-- Create Final Score Display
local finalScoreDisplay = display.newText({text=0, x=display.contentCenterX, y=50, font=flappyCounterFont, fontSize=50})
finalScoreDisplay:setFillColor(0, 0, 0)

-- Create Top Border
local topBorder = display.newLine(50, display.screenOriginY-150, 150, display.screenOriginY-150)
topBorder:toBack()
physics.addBody(topBorder, "static")

-- Game Function
local function game()

  -- Remove Restart Button, Bird and Floors
  display.remove(floor)
  display.remove(floor)
  display.remove(restartButton)
  display.remove(restartText)
  display.remove(bird)

  -- Create Bird
  bird = display.newImageRect("bird.png", 50, 35)
  physics.addBody(bird, "dynamic")
  bird.x = 100
  bird.y = 100
  bird.rotation = -20

  -- Bird Flap
  local function birdFlap()

    -- Pushes Bird Up
    bird:setLinearVelocity(0, 0)
    bird:applyLinearImpulse(0, -0.25, bird.x, bird.y)

    -- Defualts Bird Rotation
    bird.angularVelocity = 0
    bird.rotation = -20
    if not (birdRotateTimer == nil) then timer.cancel(birdRotateTimer) end
    if not (birdDiveTimer == nil) then timer.cancel(birdDiveTimer) end

    -- Bird Rotate
    local function birdRotate()
      bird.rotation = bird.rotation + 5
    end

    -- Bird Dive
    local function birdDive()
      birdRotateTimer = timer.performWithDelay(1, birdRotate, 22)
    end
    birdDiveTimer = timer.performWithDelay(500, birdDive)

  end

  -- Bird Flap Listener
  Runtime:addEventListener("tap", birdFlap)

  -- Create Floor
  local floor = display.newImageRect("floor.png", 2000, 75)
  floor.x = display.contentCenterX
  floor.y = 320
  physics.addBody(floor, "static")
  transition.moveBy(floor, {x=-3400, y=0, time=20000})
  local function removeFloor()
    display.remove(floor)
    table.remove(floors, 1)
  end
  table.insert(floors, timer.performWithDelay(20000, removeFloor))

  -- Move Floor
  local function createFloor()
    local floor = display.newImageRect("floor.png", 2000, 75)
    floor.x = display.contentCenterX + 1990
    floor.y = 320
    physics.addBody(floor, "static")
    transition.moveBy(floor, {x=-3400, y=0, time=20000})
    local function removeFloor()
      display.remove(floor)
      table.remove(floors, 1)
    end
    table.insert(floors, timer.performWithDelay(20000, removeFloor))
  end
  createFloor()
  createFloorTimer = timer.performWithDelay(5000, createFloor, 0)

  -- Reset Score Display
  scoreDisplay.text = 0
  scoreDisplay:toFront()
  finalScoreDisplay:toBack()

  -- Create Pipes Function
  local function createPipes()

    -- Random Y Position
    local randomY = math.random(160, 280)

    -- Top Pipe
    local pipeTop = display.newImageRect("pipeTop.png", 75, 300)
    pipeTop.anchorY = 1
    pipeTop.x = 600
    pipeTop.y = randomY - 150
    physics.addBody(pipeTop, "static")
    transition.moveBy(pipeTop, {x=-850, y=0, time=5000})
    local function removePipeTop()
      display.remove(pipeTop)
    end
    timer.performWithDelay(5000, removePipeTop)

    -- Bottom Pipe
    local pipeBottom = display.newImageRect("pipeTop.png", 75, 300)
    pipeBottom.yScale = -1
    pipeBottom.x = 600
    pipeBottom.y = randomY + 150
    physics.addBody(pipeBottom, "static")
    transition.moveBy(pipeBottom, {x=-850, y=0, time=5000})
    local function removePipeBottom()
      display.remove(pipeBottom)
    end
    timer.performWithDelay(5000, removePipeBottom)

    -- Score
    scoreDisplay:toFront()
    local function score()
      scoreDisplay.text = scoreDisplay.text + 1
    end
    scoreTimer = timer.performWithDelay(3000, score)

  end

  -- Create Pipes Timer
  createPipesTimer = timer.performWithDelay(1500, createPipes, 0)

  -- Game Over Function
  local function gameOver()

    -- Shows Final Score
    finalScoreDisplay.text = scoreDisplay.text
    finalScoreDisplay:toFront()
    scoreDisplay:toBack()

    -- Cancel Timers and Listeners
    transition.cancel()
    timer.cancel(floors[1])
    timer.cancel(floors[2])
    table.remove(floors, 1)
    table.remove(floors, 1)
    timer.cancel(createFloorTimer)
    timer.cancel(createPipesTimer)
    bird:removeEventListener("collision", gameOver)

    -- Restart Button
    restartButton = display.newRect(display.contentCenterX, display.contentCenterY, 250, 150)
    restartButton.fill = {0, 0, 0, 0.01}
    restartText = display.newText({text="Restart", x=restartButton.x, y=restartButton.y, font=flappyFont, fontSize=100})
    restartText.fill = {0, 0, 0, 0.5}

    -- Activate Restart Button Function
    local function activateRestartButton()
      restartText.fill = {0, 0, 0, 1}
      restartButton:addEventListener("tap", game)
    end
    timer.performWithDelay(5000, activateRestartButton)

  end

  -- Game Over Listener
  bird:addEventListener("collision", gameOver)

end

-- Starts The Game
game()
