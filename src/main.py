#!/usr/bin/python3
from datetime import datetime

def main():
  with open("/tmp/test.txt","a") as f:
    f.write(f"Started (v1.0) at: {datetime.now()}\n")

if __name__=='__main__':
  main()

