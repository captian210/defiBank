# until hardhat flatten tast removes extra SPDX identfiers this is my quick and ditry solution
import os

os.system("npx hardhat flatten contracts/bank.sol > contracts/flattened/flatten.sol")


bad_words = ['SPDX', 'pragma']

with open('contracts/flattened/flatten.sol') as oldfile, open('contracts/flattened/flat.sol', 'w') as newfile:
    for line in oldfile:
        if not any(bad_word in line for bad_word in bad_words):
            newfile.write(line)
            
filename = "contracts/flattened/flat.sol"

string = "// SPDX-License-Identifier: MIT \n pragma solidity ^0.8.0; \n"
            
def insert(originalfile,string):
    with open(originalfile,'r') as f:
        with open('newfile.txt','w') as f2: 
            f2.write(string)
            f2.write(f.read())
    os.rename('newfile.txt',originalfile)
    
insert(filename,string)

os.remove("contracts/flattened/flatten.sol")
