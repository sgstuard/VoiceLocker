from tri_des import *
import sys

def main(encrypted_data):
    key = "123456123456123456123456"
    IV = "\0\0\0\0\0\0\0\0"
    k = triple_des(key, IV)
    #print "Decrypted: %r" % k.decrypt(encrypted_data)
    sys.stdout.write(repr(k.decrypt(encrypted_data)))
    #return "Decrypted: %r" % k.decrypt(encrypted_data)
    
    
if __name__ == "__main__":
    main(str(sys.argv[1]))