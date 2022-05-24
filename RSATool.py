from Crypto import Random
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5 as PKCS1_cipher
import base64
import asyncio
import websockets
from pyDes import *
import binascii

def get_key(key_file):
    with open(key_file) as f:
        data = f.read()
        key = RSA.importKey(data)

    return key


def encrypt_data(msg):
    public_key = get_key('rsa_public_key.pem')
    cipher = PKCS1_cipher.new(public_key)
    encrypt_text = base64.b64encode(cipher.encrypt(bytes(msg.encode("utf8"))))
    return encrypt_text.decode('utf-8')


def decrypt_data(encrypt_msg):
    private_key = get_key('rsa_private_key.pem')
    cipher = PKCS1_cipher.new(private_key)
    back_text = cipher.decrypt(base64.b64decode(encrypt_msg), 0)
    return back_text.decode('utf-8')





if __name__ == '__main__':
    while(1):
        a = input("获取密钥输入1，加密输入2，解密输入3：")
        if a == "1":
            random_generator = Random.new().read
            rsa = RSA.generate(2048, random_generator)
            # 生成私钥
            private_key = rsa.exportKey()
            print("私钥：")
            print(private_key.decode('utf-8'))
            # 生成公钥
            public_key = rsa.publickey().exportKey()
            print("公钥：")
            print(public_key.decode('utf-8'))
        if a == "2":
            cont = input("请输入需要加密内容：")
            print(encrypt_data(cont))
        if a == "3":
            cont = input("请输入需要解密内容：")
            print(decrypt_data(cont))
