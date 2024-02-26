import { getTimestamp } from './seed.js'

const SAVED_GAME_KEY = "savedGame"
const GRID_KEY = "grid"
const TIMESTAMP_KEY = "timestamp"

const buildFlags = (grid, timestamp) => ({
  [TIMESTAMP_KEY]: timestamp,
  [GRID_KEY]: grid
})

const getGameTimestamp = game => game[TIMESTAMP_KEY]
const getGameGrid = game => game[GRID_KEY]

const isValidSavedGame = (game) => game && getGameTimestamp(game) && getGameGrid(game)

const isCurrentSavedGame = (game) => {
  const currentTimestamp = getTimestamp();

  return getGameTimestamp(game) == currentTimestamp;
}

const parseJson = json => {
  try {
    const parsed = JSON.parse(json)
    if (isValidSavedGame(parsed)) {
      return parsed;
    }
    return null;
  } catch (_exception) {
    return null;
  }
}

const readSavedGame = () => {
  const storageValue = localStorage.getItem(SAVED_GAME_KEY);

  if (storageValue) {
    const savedGame = parseJson(storageValue);
     if (isValidSavedGame(savedGame) && isCurrentSavedGame(savedGame)) {
       return getGameGrid(savedGame);
     }
  }

  return null;
}

export const storageToFlags = () => buildFlags(readSavedGame(), getTimestamp());

export const saveGame = (grid) => {
  const timestamp = getTimestamp();

  localStorage.setItem(SAVED_GAME_KEY, JSON.stringify(buildFlags(grid, timestamp)));
}
