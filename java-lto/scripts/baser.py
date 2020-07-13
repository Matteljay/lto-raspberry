#!/usr/bin/python3
# required: pip3 install pyblake2 base58
import sys, argparse
from hashlib import sha256
from pyblake2 import blake2b
import base58

def secureHash(message):
    h = blake2b(digest_size=32)
    h.update(message.encode())
    return sha256(h.digest()).digest()

if __name__ == "__main__":
    isAtty = sys.stdin.isatty() # see if a line is being piped to this script
    parser = argparse.ArgumentParser(description='Base58 encode a string with optional hashing')
    parser.add_argument('--hash', dest='hashFirst', action='store_true', help='perform blake2b/sha256 hash before base58')
    args = parser.parse_args()
    if args.hashFirst:
        notice = 'Paste the string you\'d like to hash first and then base58 encode:\n'
        line = input(notice if isAtty else '')
        msg = secureHash(line)
    else:
        notice = 'Paste the string you\'d like to base58 encode:\n'
        msg = input(notice if isAtty else '')
    based = base58.b58encode(msg)
    print(based.decode())

#EOF
