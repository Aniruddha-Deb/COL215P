import sys

if __name__ == "__main__":
    with open(sys.argv[1],"w") as f:
        for i in range(int(sys.argv[2]), int(sys.argv[3])):
            f.write(f"{i%128:08b}\n")
        f.close()
        
