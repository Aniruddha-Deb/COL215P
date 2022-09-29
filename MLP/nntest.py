import numpy as np
import sys

np.seterr(all='raise')

def tc2int(s):
    if (s[0] == '1'):
        return -2**(len(s)-1)+int(s[1:],2)
    else:
        return int(s,2)

def read_weights_and_biases(wt_bias_file):
    wts = []
    with open(wt_bias_file) as f:
        for l in f:
            wts.append(tc2int(l.strip()))

    mat = np.array(wts, dtype=np.int16)
    w1, b1, w2, b2 = mat[:784*64], \
                     mat[784*64:784*64+64], \
                     mat[784*64+64:784*64+64+64*10], \
                     mat[784*64+64+64*10:784*64+64+64*10+10]

    w1 = w1.reshape((784,64), order='F')
    b1 = b1.reshape((1,64), order='F')
    w2 = w2.reshape((64,10), order='F')
    b2 = b2.reshape((1,10), order='F')

    return (w1,b1,w2,b2)

def read_img(img_file):
    img = []

    with open(img_file) as f:
        for l in f:
            img.append(tc2int(l.strip()))

    mat = np.array(img, dtype=np.int16)
    mat.reshape((1,784))
    return mat

def relu(x):
    return np.where(x >= 0, x, 0)

def predict(img_file, wt_bias_file):
    img = read_img(img_file)
    (w1,b1,w2,b2) = read_weights_and_biases(wt_bias_file)

    l1 = relu(((img@w1) + b1)//32)
    l2 = relu(((l1@w2) + b2)//32).flatten()
    pred = np.argmax(l2)
    
    print(l1)
    print(l2)
    print(pred)

if __name__ == "__main__":
    predict(sys.argv[1],sys.argv[2]);


