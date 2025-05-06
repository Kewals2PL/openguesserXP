import json
import mouse
import time
import keyboard

def load_config(filename):
    with open(filename, "r") as f:
        return json.load(f)

# "x,y" na "x, y"
def parse_position(pos_str):
    x, y = map(int, pos_str.split(","))
    return x, y

config = load_config("config.json")

map_x, map_y = parse_position(config["MAP_POS"])
place_x, place_y = parse_position(config["PLACE_FLAG_POS"])
guess_x, guess_y = parse_position(config["GUESS_BUTTON_POS"])
continue_x, continue_y = parse_position(config["CONTINUE_BUTTON_POS"])
err_x, err_y = parse_position(config["ERROR_BUTTON_CLOSE_POS"])

# TEST IF IT WORKS - **currently THE # DON'T WORK**
#
# print("MAP_POS:", map_pos)
# print("PLACE_FLAG_POS:", place_flag_pos)
# print("GUESS_BUTTON_POS:", guess_button_pos)
# print("CONTINUE_BUTTON_POS:", continue_button_pos)

print("Be ready!")
time.sleep(2)
print(3)
time.sleep(1)
print(2)
time.sleep(1)
print(1)
time.sleep(1)
print("Press X to end!")



while True:
    if keyboard.is_pressed('x'):
        print("Program quitted!")
        break

    mouse.move(map_x, map_y, absolute=True, duration=0.1)
    #time.sleep(2)
    mouse.move(place_x,place_y, absolute=True, duration=0.1)
    mouse.click('left')
    #time.sleep(2)
    mouse.move(guess_x,guess_y, absolute=True, duration=0.1)
    mouse.click('left')
    #time.sleep(2)
    mouse.move(continue_x,continue_y, absolute=True, duration=0.1)
    mouse.click('left')
    #time.sleep(2)
    mouse.move(err_x, err_y, absolute=True, duration=0.1) # zamyka error - oczywiscie TYLKO jak sie pojawi
    mouse.click('left')
    #time.sleep(2)