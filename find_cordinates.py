import mouse
import keyboard

mouse.get_position()

print("Press X to end!")

while True:
    if keyboard.is_pressed('x'):
        print("Program quitted!")
        break

print(mouse.get_position())