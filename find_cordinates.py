import mouse
import keyboard
import time

print("Press X to end!")

while True:
    pos = mouse.get_position()
    print(f"Mouse position: {pos}", end="\r")  # show pos without flooding the terminal
    time.sleep(0.1)
    
    if keyboard.is_pressed('x'):
        print("\nProgram quitted!")
        break
