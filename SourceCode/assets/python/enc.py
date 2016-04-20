"""
USAGE:
    python enc.py '"String to be encrypted"' key
    
    key: Must be 24bytes in length

"""


from tri_des import *
import sys

def main(data, key):
    IV = "\0\0\0\0\0\0\0\0"
    k = triple_des(key, IV)
    #print "Encrypted: %r" % k.encrypt(data)
    sys.stdout.write(k.encrypt(data))
    
    
if __name__ == "__main__":
    main(sys.argv[1], str(sys.argv[2]))
