# geoguessrXP (PowerShell Edition)

## Requirements

- **Windows 10 or 11**
- **PowerShell 5.1 or later**
- **Python3** (only required if using `find_coordinates.py`)
- Script execution permissions (see below)

## Project Files

- `main.ps1` – main PowerShell automation script
- `config.json` – configuration file containing screen coordinates
- `log.txt` – generated during runtime with timestamps for each click cycle

## Configuration

The `config.json` file should contain the following format:

{  
    "MAP_POS": "123, 456",  
    "PLACE_FLAG_POS": "234, 567",  
    "GUESS_BUTTON_POS": "345, 678",  
    "CONTINUE_BUTTON_POS": "456, 789",  
    "ERROR_BUTTON_CLOSE_POS": "567, 890"  
}

(Each entry represents screen coordinates in X, Y format.)
## How to Run

1. Make sure main.ps1 and config.json are in the same folder.

2. Open PowerShell in that directory.

3. Run the script using:

`powershell -ExecutionPolicy Bypass -File .\main.ps1`

4. You will be prompted whether to update coordinates. Type y if you want to run the Python tool find_coordinates.py (must be present and Python must be installed).

5. The script will start clicking automatically. Press ESC at any time to stop the loop.

### Setting Coordinates (optional)

You can manually enter coordinates in config.json, or use the optional find_coordinates.py helper script to select positions interactively using the mouse.
## Exiting

To safely stop the click loop, press the ESC key. The script checks for this during each cycle.
### Notes

    Uses low-level Windows API for mouse movement and clicks.

    Works only on Windows.

    Must be run from a .ps1 file — partial execution in the console will break path handling logic ($MyInvocation).
## Script Execution Policy

If needed, temporarily allow script execution using:

Set-ExecutionPolicy Bypass -Scope Process

Or permanently (user scope):

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# License

[MIT](https://raw.githubusercontent.com/Kewals2PL/openguesserXP/refs/heads/main/LICENSE)


***alternatively use macro lol***
