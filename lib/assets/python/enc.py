from tri_des import *
import sys

def main(data):
    #print data
    #print type(data)
    key = "123456123456123456123456"
    IV = "\0\0\0\0\0\0\0\0"
    k = triple_des(key, IV)
    #print k.encrypt(data)
    reload(sys)  
    sys.setdefaultencoding('utf8')
    sys.stdout.write((k.encrypt(data)).encode('utf8'))
    #return "Encrypted: %r" % k.encrypt(data)
    
    
if __name__ == "__main__":
    main(sys.argv[1])
