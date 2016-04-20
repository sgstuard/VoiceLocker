"""
USAGE:
    python dec.py '"String to be encrypted"' key
    
    key: Must be 24bytes in length

"""

from tri_des import *
import sys

def main(encrypted_data, key):
    IV = "\0\0\0\0\0\0\0\0"
    k = triple_des(key, IV)
    #print "Decrypted: %r" % k.decrypt(encrypted_data)
    #return "Decrypted: %r" % k.decrypt(encrypted_data)
    sys.stdout.write(k.decrypt(encrypted_data))
    
    
if __name__ == "__main__":
    main(str(sys.argv[1]), str(sys.argv[2]))
