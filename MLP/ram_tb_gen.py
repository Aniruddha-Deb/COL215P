import numpy as np

def print_data_arr(arr, name, size):
    print(f"signal {name}: unsigned_arr := (")
    print(',\n'.join([f"    {i} => to_unsigned({arr[i]},{size})" for i in range(len(arr))]))
    print(");\n")
   
if __name__ == "__main__":

    data = [np.random.randint(65536) for i in range(1024)]
    idxs = np.random.permutation(1024)

    print_data_arr(data, "data_arr", 16)
    print_data_arr(idxs, "idxs_arr", 16)
    
    # cool!