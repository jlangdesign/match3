--[[
    GD50
    Match-3 Remake

    -- BeginGameState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in right before we start playing;
    should fade in, display a drop-down "Level X" message, then transition
    to the PlayState, where we can finally use player input.
]]

BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()

    -- start our transition alpha at full, so we fade in
    self.transitionAlpha = 255

    -- -- spawn a board and place it toward the right
    -- self.board = Board(VIRTUAL_WIDTH - 272, 16)

    -- start our level # label off-screen
    self.levelLabelY = -64
end

function BeginGameState:possibleMatchExists()
  -- for each tile, try swapping with each tile surrounding it and see if it
  -- would result in a match
  -- if there is at least one match, return true
  local matchPossible = false;
  for i = 1, 8 do
    for j = 1, 8 do
      -- get current tile
      local thisTile = self.board.tiles[j][i]

      for k = 1, 4 do -- for top, bottom, left, right
        local otherTile = self.board.tiles[j][i]
        -- get tile on top, bottom, left, or right if it exists
        if k == 1 and j > 1 then
          otherTile = self.board.tiles[j - 1][i]
        elseif k == 2 and j < 8 then
          otherTile = self.board.tiles[j + 1][i]
        elseif k == 3 and i > 1 then
          otherTile = self.board.tiles[j][i - 1]
        elseif k == 4 and i < 8 then
          otherTile = self.board.tiles[j][i + 1]
        end

        if thisTile ~= otherTile then
          -- swap the tiles
          local tempX = thisTile.gridX
          local tempY = thisTile.gridY

          thisTile.gridX = otherTile.gridX
          thisTile.gridY = otherTile.gridY
          otherTile.gridX = tempX
          otherTile.gridY = tempY

          -- swap tiles in the tiles table
          self.board.tiles[otherTile.gridY][otherTile.gridX] = otherTile
          self.board.tiles[thisTile.gridY][thisTile.gridX] = thisTile

          -- check if possible match exists
          -- (can't break or return here because we need to revert the tiles)
          if self.board:calculateMatches() then
            matchPossible = true;
          end

          -- return tiles to their original positions
          otherTile.gridX = thisTile.gridX
          otherTile.gridY = thisTile.gridY
          thisTile.gridX = tempX
          thisTile.gridY = tempY

          self.board.tiles[thisTile.gridY][thisTile.gridX] = thisTile
          self.board.tiles[otherTile.gridY][otherTile.gridX] = otherTile

          if matchPossible then
            break; -- no need to check rest of board
          end
        end
      end
    end
  end

  return matchPossible;
end

function BeginGameState:enter(def)

    -- grab level # from the def we're passed
    self.level = def.level
    -- spawn a board and place it toward the right
    self.board = Board(VIRTUAL_WIDTH - 272, 16, self.level)
    while not self:possibleMatchExists() do
      self.board = Board(VIRTUAL_WIDTH - 272, 16, self.level)
    end

    --
    -- animate our white screen fade-in, then animate a drop-down with
    -- the level text
    --

    -- first, over a period of 1 second, transition our alpha to 0
    Timer.tween(1, {
        [self] = {transitionAlpha = 0}
    })

    -- once that's finished, start a transition of our text label to
    -- the center of the screen over 0.25 seconds
    :finish(function()
        Timer.tween(0.25, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })

        -- after that, pause for one second with Timer.after
        :finish(function()
            Timer.after(1, function()

                -- then, animate the label going down past the bottom edge
                Timer.tween(0.25, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })

                -- once that's complete, we're ready to play!
                :finish(function()
                    gStateMachine:change('play', {
                        level = self.level,
                        board = self.board
                    })
                end)
            end)
        end)
    end)
end

function BeginGameState:update(dt)
    Timer.update(dt)
end

function BeginGameState:render()

    -- render board of tiles
    self.board:render()

    -- render Level # label and background rect
    love.graphics.setColor(95 / 255, 205 / 255, 228 / 255, 200 / 255)
    love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level),
        0, self.levelLabelY, VIRTUAL_WIDTH, 'center')

    -- our transition foreground rectangle
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, self.transitionAlpha / 255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end
