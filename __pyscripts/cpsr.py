import sys

def usage():
    print("Usage: python3 cpsr.py [bits]")
    print("[bits] -> the list of bits to decrypt")
    exit(0)

def valid_bits(bits):
    if bits == "": return False
    for i in bits:
        if i != "0" and i != "1":
            return False
    return True

if len(sys.argv) < 2:
    print("Invalid number of arguments!")
    usage()

bits = sys.argv[1]

if not valid_bits(bits):
    print("Given value is invalid (should only contain 0s and 1s)!")
    usage()

bits = "0" * (32 - len(bits)) + bits

print(f"""N       -> {bits[0]}
Z       -> {bits[1]}
C       -> {bits[2]}
V       -> {bits[3]}
Q       -> {bits[4]}
J       -> {bits[7]}
E       -> {bits[22]}
A       -> {bits[23]}
I       -> {bits[24]}
F       -> {bits[25]}
T       -> {bits[26]}
IT      -> {bits[16:22]}{bits[5:7]}
IT COND -> {bits[16:19]}
IT NEXT -> {bits[19:22]}{bits[5:7]}
GE      -> {bits[12:16]}
M       -> {bits[27:32]}""")


