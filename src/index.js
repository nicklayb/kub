import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import { getTimestamp } from './seed.js'
import { saveGame, storageToFlags } from './storage.js'

const ROOT = 'root'

const flags = storageToFlags();

const app = Elm.Main.init({
  node: document.getElementById(ROOT),
  flags
});

app.ports.persistGame.subscribe(grid => {
  saveGame(grid);
})

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
