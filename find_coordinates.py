import json
import pyautogui
import keyboard
import time

FIELD_KEYS = {
    '1': "MAP_POS",
    '2': "PLACE_FLAG_POS",
    '3': "GUESS_BUTTON_POS",
    '4': "CONTINUE_BUTTON_POS",
    '5': "ERROR_BUTTON_CLOSE_POS",
}

CONFIG_PATH = "config.json"

def load_config():
    try:
        with open(CONFIG_PATH, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return {key: "0, 0" for key in FIELD_KEYS.values()}

def save_config(config):
    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=4)

def main():
    print("Move the mouse to the desired position and press a key (1–5) to save it.")
    print("Press 'ESC' to save.\n")

    config = load_config()

    while True:
        for key, field in FIELD_KEYS.items():
            if keyboard.is_pressed(key):
                x, y = pyautogui.position()
                config[field] = f"{x}, {y}"
                save_config(config)
                print(f"[{field}] saved as: {x}, {y}")
                time.sleep(0.3)

        if keyboard.is_pressed('esc'):
            print("Saving...")
            break

if __name__ == "__main__":
    main()