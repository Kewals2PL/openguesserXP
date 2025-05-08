import json
import time
import keyboard
import pyautogui
from datetime import datetime
import os
import sys
import subprocess

try:
    import ctypes
    ctypes.windll.user32.SetProcessDPIAware()
except:
    pass

# Funkcja do załadowania konfiguracji
def load_config(filename):
    path = resource_path(filename)
    try:
        with open(path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return { "MAP_POS": "0, 0", "PLACE_FLAG_POS": "0, 0", "GUESS_BUTTON_POS": "0, 0", "CONTINUE_BUTTON_POS": "0, 0", "ERROR_BUTTON_CLOSE_POS": "0, 0" }

# Funkcja do konwersji współrzędnych
def parse_position(pos_str):
    x, y = map(int, pos_str.split(","))
    return x, y

# Funkcja do uzyskania ścieżki do pliku w wersji exe
def resource_path(relative_path):
    """Zwraca ścieżkę do pliku, działa też w .exe po spakowaniu."""
    try:
        base_path = sys._MEIPASS  # tylko w PyInstaller
    except AttributeError:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

def prompt_for_coordinates():
    choice = input("\nDo you want to choose new coordinates? (y/n): ").strip().lower()
    if choice == "y":
        subprocess.run(["python", resource_path("find_coordinates.py")])
        print("\nRestarting the application to apply new coordinates...")
        time.sleep(2)


def reload_coordinates(filename):
    config = load_config(filename)
    print("\nCurrent coordinates:")
    for key, value in config.items():
        print(f'  {key}: "{value}"')
    return config        


def main():
    config = reload_coordinates("config.json")
    prompt_for_coordinates()
    config = reload_coordinates("config.json")    

    map_x, map_y = parse_position(config["MAP_POS"])
    place_x, place_y = parse_position(config["PLACE_FLAG_POS"])
    guess_x, guess_y = parse_position(config["GUESS_BUTTON_POS"])
    continue_x, continue_y = parse_position(config["CONTINUE_BUTTON_POS"])
    err_x, err_y = parse_position(config["ERROR_BUTTON_CLOSE_POS"])

    print("Be ready!")
    time.sleep(2)
    print(3)
    time.sleep(1)
    print(2)
    time.sleep(1)
    print(1)
    time.sleep(1)
    print("Hold ESCAPE to end!")

    def move_and_click(x, y):
        pyautogui.moveTo(x, y, duration=0.1)
        pyautogui.click()

    log_path = "log.txt"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("Log start\n")

    attempt = 1

    while True:
        if keyboard.is_pressed('esc'):
            print("Program quitted!")
            break

        now = datetime.now().strftime("%H:%M:%S")
        log_entry = f"att:{attempt} at {now}"
        print(f"\n{log_entry}")

        with open(log_path, "a", encoding="utf-8") as log_file:
            log_file.write(log_entry + "\n")

        attempt += 1

        move_and_click(map_x, map_y)
        move_and_click(place_x, place_y)
        move_and_click(guess_x, guess_y)
        move_and_click(continue_x, continue_y)
        move_and_click(err_x, err_y)

if __name__ == '__main__':
    main()