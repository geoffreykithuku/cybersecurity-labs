# Lab 3: Bash Recon Tool

## 1. Objective

The goal of this lab was to create a simple Bash reconnaissance tool that only runs against authorised targets and uses common enumeration utilities in a controlled way.

## 2. Workspace Setup

I first created the required working directory and confirmed my shell location:

```bash
mkdir -p ~/lab3-recon
cd ~/lab3-recon
pwd
```

Result:

- Working directory: `/home/kali/lab3-recon`

## 3. Required Tools Check

Before writing the script, I verified that the required commands were available in the environment:

```bash
command -v bash
command -v nmap
command -v whatweb
command -v dirb
```

Observed paths:

- `/usr/bin/bash`
- `/usr/bin/nmap`
- `/usr/bin/whatweb`
- `/usr/bin/dirb`

All required tools were present, so I proceeded to create the Bash script.

I followed the lab instructions to create a script named recon_tool.sh. It's contents are captured in the screenshots and also the attached recon_tool.sh file.

I made it executable

```

┌──(kali㉿kali)-[~/lab3-recon]
└─$ chmod +x recon_tool.sh

┌──(kali㉿kali)-[~/lab3-recon]
└─$ ls -l
total 4
-rwxrwxr-x 1 kali kali 1320 Sep  6 14:21 recon_tool.sh

┌──(kali㉿kali)-[~/lab3-recon]
└─$

```

I ran the the script and recorded the screenshots of the outputs. I noticed the invalid input error everytime I entered an option but fixed it.

For easier assessment, I also recorded the script run in Loom:

- [Loom recording](https://www.loom.com/share/4758b5adf4b146e1aabc9ac58540b791)

## Part 9 - Explanation Guide

    1. Purpose of the script. - To automate the process of reconnaissance on authorised targets using common enumeration utilities.
    2. How read stores the target. - The `read` command prompts the user for input and stores the entered value in a variable, in this case, `$target`.
    3. How the menu stores choice. - The menu uses a `case` statement to evaluate the user's input and execute the corresponding command based on the selected option.
    4. How case selects a tool. - The `case` statement matches the user's choice against predefined options (1, 2, 3, 4) and executes the associated commands for each tool (Nmap, WhatWeb, DIRB, or exit).
    5. Why no target is hardcoded. - Hardcoding the target would make the script less flexible and harder to maintain, as it would only work for a specific target.
    6. Why chmod +x is required. - The `chmod +x` command makes the script executable, allowing it to be run directly from the command line.
    7. Why authorisation matters. - Authorisation ensures that the script is only used on authorised targets, preventing misuse and potential legal issues.

## Part 10 - Understanding Questions

1. What does the shebang do? - It tells the system to use Bash to run the script.
2. What does read -rp do? - It prompts for input and stores the answer in a variable.
3. Why quote "$target"? - It keeps the target as one value, even if it contains spaces.
4. What does -z test? - It checks whether a string is empty.
5. What is the purpose of exit 1? - It stops the script with an error code.
6. Why is case suitable for menus? - It makes menu choices easy to handle.
7. What does ;; mean? - It ends the current case block.
8. What does \* mean in the case statement? - It is the default choice for unmatched input.
9. Why does WhatWeb/DIRB use http://$target? - They need the HTTP protocol to scan a web target.
10. What does nmap -sV do? - It checks open ports and detects service versions.
11. What does command -v check? - It checks whether a command exists in PATH.
12. What does chmod +x do? - It makes the script executable.
13. What does ./ mean? - It runs a file from the current folder.
14. What does tee do? - It shows output on screen and saves it to a file.
15. Which requirement prevents hardcoding? - The target must be entered at runtime, not hardcoded.
