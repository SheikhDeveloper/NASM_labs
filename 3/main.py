def ceasar_cipher(text, key):
    result = ""
    for char in text:
        if char.isalpha():
            if char.isupper():
                result += chr((ord(char) + key - 65) % 26 + 65)
            else:
                result += chr((ord(char) + key - 97) % 26 + 97)
        else:
            result += char
    return result

with open("input") as f:
    key = int(f.readline())
    text = f.readline().strip()
    while text != "":
        print(ceasar_cipher(text, key))
        text = f.readline().strip()
