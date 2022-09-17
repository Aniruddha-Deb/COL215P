import numpy as np

if __name__ == "__main__":

    a1, a2, b, rstarr = [], [], [], []

    for i in range(64):
        rst = np.random.randint(16)
        n1, n2 = np.random.randint(255), np.random.randint(255)

        a1.append(n1)
        a2.append(n2)
        if rst == 15:
            b.append(n1*n2)
            rstarr.append(1)
        else:
            if b:
                b.append((n1*n2+b[-1])%256)
            else:
                b.append(n1*n2)
            rstarr.append(0)


    print(f"signal din1_arr: unsigned_arr := (")
    print(',\n'.join([f"    {i} => to_unsigned({a1[i]},8)" for i in range(64)]))
    print(");\n")

    print(f"signal din2_arr: unsigned_arr := (")
    print(',\n'.join([f"    {i} => to_unsigned({a2[i]},8)" for i in range(64)]))
    print(");\n")

    print(f"signal dout_arr: unsigned_arr := (")
    print(',\n'.join([f"    {i} => to_unsigned({b[i]},8)" for i in range(64)]))
    print(");\n")

    print(f"signal rst_arr: std_logic_vector(63 downto 0) := (")
    print(',\n'.join([f"    {i} => '{rstarr[i]}'" for i in range(64)]))
    print(");\n")

    # cool!