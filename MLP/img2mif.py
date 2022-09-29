from PIL import Image
import numpy as np
import sys

def img2mif(imgfile, outfile):
    img = Image.open(imgfile)
    data = img.load()

    with open(outfile, 'w') as f:
        for i in range(img.size[0]):
            for j in range(img.size[1]):
                pixel = data[j,i]
                f.write(f"{pixel>>1:08b}\n")
        f.close()

if __name__ == "__main__":
    img2mif(sys.argv[1], sys.argv[2])