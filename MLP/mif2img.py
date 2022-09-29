from PIL import Image
import sys

def mif_to_image():
    with open(sys.argv[1]) as f:
        lines = f.readlines()
        imgdata_bytes = [int(i.strip(),2) for i in lines]
        buffer = bytearray()
        for i in imgdata_bytes:
            buffer.append(i<<1)
        img = Image.frombuffer('L', (28,28), buffer, 'raw', 'L', 0, 1)

        img.save(sys.argv[2])

if __name__ == "__main__":
    mif_to_image()