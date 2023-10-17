# How to contribute to The Maze
- Follow a Git workflow of fork -> clone -> branch -> pr -> merge
- If you're new to Git look [here](https://docs.github.com/en/get-started/quickstart/contributing-to-projects)

## general 
- Keep file and folder names in `snake_case` (godot 4 standard)

## code
- Make sure your godot code follows the [GDQuest Style Guide](https://gdquest.gitbook.io/gdquests-guidelines/godot-gdscript-guidelines)
- Use [Static Typing](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/static_typing.html) AT ALL TIMES
- Connect signals and groups through code, NOT through the GUI
- Try to use composition instead of inheritance