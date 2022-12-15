import sys
import os

if __name__ == "__main__":
    cart_name = os.getcwd().split("/")[-1]

    cart_contents = open(f"{cart_name}.js", "r").read()
    out_code_contents = open(sys.argv[1],"r").read()

    # clean tic80 wrapper
    out_code_contents = out_code_contents.replace("__TIC80WRAPPER.", "")

    header = """
// title:  Doggy
// author: Dadum
// desc:   Proof of concept platformer to make a TIC80 game with Haxe.
// saveid: DoggyHaxeExample4589
// script: js

"""

    tic_adapter = """
function TIC(){Main.TIC()}
"""

    cart_after_code = cart_contents[cart_contents.index("// <TILES>"):]
    
    with open(f"{cart_name}.js", "w") as f:
        f.write(header + out_code_contents + tic_adapter + cart_after_code)