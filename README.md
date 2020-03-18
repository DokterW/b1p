# b1p

b1p is short for _Bitwarden to 1Password_. A very basic script that takes the exported JSON file from Bitwarden and generates a valid CSV file for 1Password import.

### Usage
_b1p.sh <file name>_
This exports all entries in the JSON file to one CSV file.

_b1p.sh <file name> <folder name>_
This exports only entries from a specific Bitwarden folder to a CSV file with the same name.

_b1p.sh <file name> list-folders_
List Bitwarden folders.

### Roadmap
* Keep tweaking the code.

### Changelog

#### 2020-03-18
* Added listing of folders.

#### 2020-03-16
* Officially finished, tested and used.
