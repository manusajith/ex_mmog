# ExMmog - A Massive Multiplayer Online Game

### Context

The game is played on a 2D grid. The player is looking from the top down. Each field in the grid
can be either a wall or a walkable/empty tile.

The player controls a hero, which is rendered on the grid. The hero can move freely on the empty
tiles, but not on the wall tiles. When other players connect to the game, your enemies, they are
also rendered on the grid. Your hero should always be distinguishable from the enemies.

While moving, if an enemy is already on a tile, your hero can still move to that tile. Your hero
should be rendered above the enemies so that your hero is always visible. When your hero or an
enemy is dead, it should be distinguishable from others.

### Game mechanics

- Browser based game, visit: http://localhost:4000/game to get started.
  Your hero will be assigned a random name.
  If you need your hero to be named, pass the name http://localhost:4000/game?name=manu
- If a player connects to the game with a name that already exists and is controlled by another
  player, both players control the same hero.
- Your hero can move freely over all empty/walkable tiles. They can also walk on tiles where
  enemies are already standing.
- Each hero can attack everyone else within the radius of 1 tile around him in all directions + the
  tile they are standing on.
- If there are multiple enemies in range, all of them are attacked at the same time. One hit is
  enough to kill the enemy.
- If an enemy attacks you, your hero dies. When your hero is dead, it cannot perform any actions
- Every 5 seconds all dead heroes are removed (and randomly re-spawned if the player is still
  playing the game)

### TODO

- UI/UX improvements. tidy up and style the board.
- Highlight your hero.
- Animations when your here is attacked.

### Get started

  #### Prerequisites

  Assuming you have [asdf](https://github.com/asdf-vm/asdf) installed.

  ```
  asdf install elixir 1.10.0
  asdf local elixir 1.10.0

  asdf install erlang 22.2.6
  asdf local erlang 22.2.6

  asdf install nodejs 12.14.0
  asdf local nodejs 12.14.0
  ```

  #### With nix

  ```
  nix-shell --pure

  # Install dependencies
  mdg

  # start server
  mps

  # run tests
  test
  ```


  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Deployment.

Deployments are handled using elixir releases, and app is deployed to Gigalixir.

To view the app, visit the [link](https://fussy-yearly-carp.gigalixirapp.com/)
