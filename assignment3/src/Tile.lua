--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

local shinyColors = {
  [1] = {255 / 255, 255 / 255, 255 / 255, 127.5 / 255}, -- brighter shine
  [2] = {255 / 255, 255 / 255, 255 / 255, 25.5 / 255} -- dimmer shine
}

Tile = Class{}

function Tile:init(x, y, color, variety)

    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    self.isShiny = math.random(1, 2) == 1 and true or false
    -- only set timer if tile is shiny
    self.shinyTimer = self.isShiny and Timer.every(1.5, function()
      local temp = shinyColors[1]
      Timer.tween(1.5, {
        [shinyColors[1]] = shinyColors[2],
        [shinyColors[2]] = temp
      })
    end) or nil
end

function Tile:render(x, y)

    -- draw shadow
    love.graphics.setColor(34 / 255, 32 / 255, 52 / 255, 255 / 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.isShiny then
      love.graphics.setColor(shinyColors[1])
      love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32, 4)
      love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    end
end
