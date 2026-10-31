# Shannon Switching Game
![Shannon Switching Game Main Menu](https://github.com/Griffia/shannon-switching-game/blob/main/ReadMe%20Image)
A Shannon Switching game is a two player game in which players take turn as the "Short" player, who is trying to build a path from the 
start node to the goal node. The "Cut" player, is trying to prevent the "Short" player from creating this pathway.

If the pathway is built "Short" wins.
If no paths exists from the start node to the goal node, "Cut" wins.

## How to Play
You can play the game here on GitHub at [https://github.com/Griffia/shannon-switching-game/deployments/github-pages](https://griffia.github.io/shannon-switching-game/)

## Game Modes
1. Shannon Switching Game
2. Gale's Game (Variant)

## Running the source

Open `project.godot` in Godot 4.6 or newer and run the project.
The menus and graph artwork are drawn at the window's resolution, with
antialiased lines and scalable text.

- **M** toggles sound; the preference is saved between sessions.
- **R** asks to restart the current board; **Esc** asks to return to the menu.
- **How to play** pauses the game while the rules are open.
- Restart and replay keep the same random layout or custom start/goal nodes.
- The custom editor checks that the selected start and goal are connected.

The checked-in `index.*` files are a separate web export. After changing the
source, use Godot's **Web** export preset to rebuild `index.html` and its assets
before deploying to GitHub Pages.
