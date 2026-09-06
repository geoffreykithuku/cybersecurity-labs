# Lab 2: Web Application Security Testing

## 1. Introduction

This report documents web application testing performed in an intentionally vulnerable training environment. The focus of this lab was to observe HTTP traffic, inspect file-upload validation, run Nikto and DIRB against the target, map user-controlled inputs in Mutillidae, and perform a limited SQL injection exercise using approved lab-only targets.

### Scope and authorisation

- Only authorised lab targets were used.
- No public or production applications were tested.
- All activities were completed within the classroom training environment.
- This lab followed the instructor-approved vulnerable applications only.

### Environment and target details

- Target application(s): DVWA, Mutillidae, or other instructor-approved vulnerable app
- Target URL(s):
  - DVWA: http://192.168.122.116/dvwa/
  - Mutillidae: http://192.168.122.116/mutillidae/
- Testing tool(s): Firefox Developer Tools, Burp Suite, Nikto, DIRB, SQLMap
- Date: 05/09/2026
- Author: Geoffrey Kithuku

---

## 2. Part 1 - Web Basics

### HTTP concepts

| Term         | Meaning                                                        |
| ------------ | -------------------------------------------------------------- |
| GET          | Requests a resource; parameters are often included in the URL. |
| POST         | Sends data in the request body.                                |
| Parameter    | User-controlled name/value input.                              |
| Header       | Request or response metadata.                                  |
| Cookie       | Browser-stored value often used for session state.             |
| Status code  | Server result such as 200, 302, 403, or 404.                   |
| Content-Type | Label describing the data being sent.                          |

### Key observations

- GET requests transfer parameters in the URL.
- POST requests send parameters in the body.
- Cookies and headers are important for understanding session and application behaviour.
- Content-Type identifies how the server should interpret the body of a request.

---

## 3. Part 2 - Open DVWA

### Step 1: Confirm the application URL

- DVWA URL used: http://192.168.122.116/dvwa/
- Result: The page loaded successfully and rendered a login page.

### Step 2: Set DVWA Security to Low

- Action taken: Opened DVWA Security settings and selected Low.
- Result: Low remained selected. Screenshot is under the screenshots directory.

## 4. Part 3 - Browser Developer Tools

### Step 3: Open Network tools

- Action: Opened Firefox Developer Tools → Network and refreshed the DVWA page.
- One normal request captured:
  - Method: GET
  - URL: http://192.168.122.116/dvwa/dvwa/images/logo.png
  - Status: 200 OK

### Step 4: Identify cookies

- Cookie names observed under storage.
  - PHPSESSID
  - security

---

## 5. Part 4 - Burp Suite

### Step 5: Start Burp

- Tool used: Burp Suite Community Edition
- Result: Proxy functionality was available and the tool started successfully.

### Step 6: Open Burp browser

- Action: Used Burp → Proxy → Intercept → Open Browser.
- Result: A browser opened with Burp configured as a proxy.

### Step 7: Intercept a harmless request

- Mode: Intercept enabled
- Action: Refreshed DVWA and forwarded the request after inspecting it.
- Request details observed:

```
GET /dvwa/login.php HTTP/1.1
Host: 192.168.122.116
Cookie: security, PHPSESSID



```

### Summary

- The browser request consisted of a standard HTTP GET with headers including host and user-agent.
- Cookies were present to maintain session state.

---

## 6. Part 5 - DVWA File Upload

### Step 8: Create a harmless file

```bash
echo 'ICDFA beginner upload test' > icdfa-upload-test.txt
ls -l icdfa-upload-test.txt
```

- File created: icdfa-upload-test.txt
- File type: plain text

### Step 9: Open the File Upload module

- Action: Navigated to the DVWA File Upload page.
- Result: Upload form loaded.

### Step 10: Normal upload

- Action: Uploaded the plain text file without modifying the request.
- Result: The application rejected the file.
- Exact response: Your image was not uploaded.
- Upload path or output: http://192.168.122.116/dvwa/vulnerabilities/upload/#

### Step 11: Intercept upload

- Action: Enabled Burp intercept and uploaded the harmless file again.
- Observed multipart request fields:
  - Method: POST
  - Path: /dvwa/...
  - Field name: uploaded
  - Filename: icdfa-upload-test.txt
  - MIME type: text/plain

### Example observed headers

```http
POST /dvwa/vulnerabilities/upload/ HTTP/1.1

Content-Disposition: form-data; name="MAX_FILE_SIZE"

100000
Content-Disposition: form-data; name="uploaded"; filename=""
Content-Type: application/octet-stream
Content-Disposition: form-data; name="Upload"
```

---

## 7. Part 6 - Safe File Validation Experiments

### Step 12: Extension handling

```bash
cp icdfa-upload-test.txt icdfa-upload-test.log
```

- File changed only by extension from .txt to .log.
- Results compared:
  - .txt: rejected
  - .log: rejected

### Step 13: MIME handling

- Action: Intercepted the upload and changed only the request header from `Content-Type: text/plain` to `Content-Type: image/jpeg`.
- Result: The application accepted
- Response: No error message, and the file was uploaded successfully.
- Risk explanation: Client-supplied MIME values are not trustworthy. A weak app may rely on them instead of checking the actual file content.

### Step 14: Storage location

- This lab, I did not see the uploaded file. Maybe an error on my lab environment. I will redo this step with another setup to see if I get similar results.

---

## 8. Part 7 - Nikto (Web Server Assessment)

### Step 15: Run Nikto

```bash
nikto -h http://192.168.122.116
```

Output

```
┌──(kali㉿kali)-[~]
└─$ nikto -h http://192.168.122.116
- Nikto v2.6.0
---------------------------------------------------------------------------
+ Target IP:          192.168.122.116
+ Target Hostname:    192.168.122.116
+ Target Port:        80
+ Platform:           Unknown
+ Start Time:         2026-09-06 03:58:47 (GMT-4)
---------------------------------------------------------------------------
+ Server: Apache/2.2.8 (Ubuntu) DAV/2
+ ERROR: Failed to check for updates: 403
+ [999986] /: Retrieved x-powered-by header: PHP/5.2.4-2ubuntu5.10.
+ [750500] /icons/: Directory indexing found.
+ No CGI Directories found (use '-C all' to force check all possible dirs). CGI tests skipped.
+ [013587] /: Suggested security header missing: x-content-type-options. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
+ [013587] /: Suggested security header missing: strict-transport-security. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
+ [013587] /: Suggested security header missing: permissions-policy. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Permissions-Policy
+ [013587] /: Suggested security header missing: content-security-policy. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
+ [013587] /: Suggested security header missing: referrer-policy. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
+ [999100] /index: Uncommon header(s) 'tcn' found, with contents: list.
+ [999965] /index: Apache mod_negotiation is enabled with MultiViews, which allows attackers to easily brute force file names. The following alternatives for 'index' were found: index.php. See: http://www.wisec.it/sectou.php?id=4698ebdc59d15,https://exchange.xforce.ibmcloud.com/vulnerabilities/8275
+ [600050] Apache/2.2.8 appears to be outdated (current is at least 2.4.66).
+ [600625] PHP/5.2.4-2ubuntu5.10 appears to be outdated (current is at least 8.5.1).
+ [999967] /: Web Server returns a valid response with junk HTTP methods which may cause false positives.
+ [000434] /: HTTP TRACE method is active and replies which suggests the host is vulnerable to XST. See: https://owasp.org/www-community/attacks/Cross_Site_Tracing
+ [750510] /phpinfo.php: Output from the phpinfo() function was found.
+ [750500] /doc/: Directory indexing found.
+ [001213] /doc/: The /doc/ directory is browsable. This may be /usr/doc. See: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-1999-0678
+ [001384] /?=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000: PHP Easter Eggs reveals potentially sensitive information via HTTP requests that contain specific QUERY strings. See: https://labs.detectify.com/writeups/do-you-dare-to-show-your-php-easter-egg/
+ [001385] /?=PHPE9568F36-D428-11d2-A769-00AA001ACF42: PHP Easter Egg reveals potentially sensitive information via HTTP requests that contain specific QUERY strings. See: https://labs.detectify.com/writeups/do-you-dare-to-show-your-php-easter-egg/
+ [001386] /?=PHPE9568F34-D428-11d2-A769-00AA001ACF42: PHP Easter Egg reveals potentially sensitive information via HTTP requests that contain specific QUERY strings. See: https://labs.detectify.com/writeups/do-you-dare-to-show-your-php-easter-egg/
+ [001387] /?=PHPE9568F35-D428-11d2-A769-00AA001ACF42: PHP Easter Egg reveals potentially sensitive information via HTTP requests that contain specific QUERY strings. See: https://labs.detectify.com/writeups/do-you-dare-to-show-your-php-easter-egg/
+ [001795] /phpMyAdmin/changelog.php: phpMyAdmin is for managing MySQL databases, and should be protected or limited to authorized hosts.
+ [999984] /phpMyAdmin/ChangeLog: Server may leak inodes via ETags, header found with file /phpMyAdmin/ChangeLog, inode: 92462, size: 40540, mtime: Tue Dec  9 12:24:00 2008. See: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2003-1418
+ [001796] /phpMyAdmin/ChangeLog: phpMyAdmin is for managing MySQL databases, and should be protected or limited to authorized hosts.
+ [750500] /test/: Directory indexing found.
+ [001894] /test/: This might be interesting.
+ [002989] /phpinfo.php: PHP is installed, and a test script which runs phpinfo() was found. This gives a lot of system information. See: CWE-552
+ [003584] /icons/README: Apache default file found. See: https://www.vntweb.co.uk/apache-restricting-access-to-iconsreadme/

```

### Findings summary

I reviewed the Nikto output and selected five relevant observations:

1. Outdated software versions
   - 600050: Apache/2.2.8 appears to be outdated (current is at least 2.4.66).
   - 600625: PHP/5.2.4-2ubuntu5.10 appears to be outdated (current is at least 8.5.1).
   - Why it matters: Outdated software may contain known vulnerabilities that can be exploited.
2. Missing security headers
   - 013587: Suggested security header missing: x-content-type-options, strict-transport-security, permissions-policy, content-security-policy, referrer-policy.
   - Why it matters: Missing headers can lead to security issues such as MIME sniffing, clickjacking, and information leakage.
3. phpinfo() output found
   - 750510: /phpinfo.php: Output from the phpinfo() function was found.
   - Why it matters: phpinfo() reveals sensitive information about the server configuration, which can be useful for attackers.
4. HTTP TRACE method is active
   - 000434: /: HTTP TRACE method is active and replies which suggests the host is vulnerable to XST.
   - Why it matters: The TRACE method can be exploited for Cross-Site Tracing (XST) attacks, allowing attackers to steal sensitive information from HTTP headers.
5. phpMyAdmin exposure
   - 001795: /phpMyAdmin/changelog.php: phpMyAdmin is for managing MySQL databases, and should be protected or limited to authorized hosts.
   - Why it matters: Exposing phpMyAdmin can allow attackers to access the database management interface, potentially leading to unauthorized access or data manipulation.

### Step 16: Save Nikto output

```bash
nikto -h http://192.168.122.116 -output lab2-nikto.txt
```

- Output file created: lab2-nikto.txt. Screenshot of the output is under the screenshots directory.

---

## 9. Part 8 - DIRB (Content Discovery)

### Step 17: Run DIRB

```bash
dirb http://192.168.122.116
```

Output

```
┌──(kali㉿kali)-[~]
└─$ dirb http://192.168.122.116

-----------------
DIRB v2.22
By The Dark Raver
-----------------

START_TIME: Sun Sep  6 04:34:44 2026
URL_BASE: http://192.168.122.116/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt

-----------------

                                                                             GENERATED WORDS: 4612

---- Scanning URL: http://192.168.122.116/ ----
                                                                             + http://192.168.122.116/cgi-bin/ (CODE:403|SIZE:296)
                                                                             ==> DIRECTORY: http://192.168.122.116/dav/
+ http://192.168.122.116/index (CODE:200|SIZE:891)
+ http://192.168.122.116/index.php (CODE:200|SIZE:891)
+ http://192.168.122.116/phpinfo (CODE:200|SIZE:48107)
+ http://192.168.122.116/phpinfo.php (CODE:200|SIZE:48119)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/
+ http://192.168.122.116/server-status (CODE:403|SIZE:301)
                                                                             ==> DIRECTORY: http://192.168.122.116/test/
                                                                             ==> DIRECTORY: http://192.168.122.116/twiki/

---- Entering directory: http://192.168.122.116/dav/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/ ----
                                                                             + http://192.168.122.116/phpMyAdmin/calendar (CODE:200|SIZE:4145)
+ http://192.168.122.116/phpMyAdmin/changelog (CODE:200|SIZE:74593)
+ http://192.168.122.116/phpMyAdmin/ChangeLog (CODE:200|SIZE:40540)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/contrib/
+ http://192.168.122.116/phpMyAdmin/docs (CODE:200|SIZE:4583)
+ http://192.168.122.116/phpMyAdmin/error (CODE:200|SIZE:1063)
+ http://192.168.122.116/phpMyAdmin/export (CODE:200|SIZE:4145)
+ http://192.168.122.116/phpMyAdmin/favicon.ico (CODE:200|SIZE:18902)
+ http://192.168.122.116/phpMyAdmin/import (CODE:200|SIZE:4145)
+ http://192.168.122.116/phpMyAdmin/index (CODE:200|SIZE:4145)
+ http://192.168.122.116/phpMyAdmin/index.php (CODE:200|SIZE:4145)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/js/
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/lang/
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/libraries/
+ http://192.168.122.116/phpMyAdmin/license (CODE:200|SIZE:18011)
+ http://192.168.122.116/phpMyAdmin/LICENSE (CODE:200|SIZE:18011)
+ http://192.168.122.116/phpMyAdmin/main (CODE:200|SIZE:4227)
+ http://192.168.122.116/phpMyAdmin/navigation (CODE:200|SIZE:4145)
+ http://192.168.122.116/phpMyAdmin/phpinfo (CODE:200|SIZE:0)
+ http://192.168.122.116/phpMyAdmin/phpinfo.php (CODE:200|SIZE:0)
+ http://192.168.122.116/phpMyAdmin/phpmyadmin (CODE:200|SIZE:21389)
+ http://192.168.122.116/phpMyAdmin/print (CODE:200|SIZE:1063)
+ http://192.168.122.116/phpMyAdmin/readme (CODE:200|SIZE:2624)
+ http://192.168.122.116/phpMyAdmin/README (CODE:200|SIZE:2624)
+ http://192.168.122.116/phpMyAdmin/robots (CODE:200|SIZE:26)
+ http://192.168.122.116/phpMyAdmin/robots.txt (CODE:200|SIZE:26)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/scripts/
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/setup/
+ http://192.168.122.116/phpMyAdmin/sql (CODE:200|SIZE:4145)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/test/
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/themes/
+ http://192.168.122.116/phpMyAdmin/TODO (CODE:200|SIZE:235)
+ http://192.168.122.116/phpMyAdmin/webapp (CODE:200|SIZE:6902)

---- Entering directory: http://192.168.122.116/test/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/twiki/ ----
                                                                                                                                                          ==> DIRECTORY: http://192.168.122.116/twiki/bin/
+ http://192.168.122.116/twiki/data (CODE:403|SIZE:298)
+ http://192.168.122.116/twiki/index (CODE:200|SIZE:782)
+ http://192.168.122.116/twiki/index.html (CODE:200|SIZE:782)
                                                                             ==> DIRECTORY: http://192.168.122.116/twiki/lib/
+ http://192.168.122.116/twiki/license (CODE:200|SIZE:19440)
                                                                             ==> DIRECTORY: http://192.168.122.116/twiki/pub/
+ http://192.168.122.116/twiki/readme (CODE:200|SIZE:4334)
+ http://192.168.122.116/twiki/templates (CODE:403|SIZE:303)

---- Entering directory: http://192.168.122.116/phpMyAdmin/contrib/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/js/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/lang/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/libraries/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/scripts/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/setup/ ----
                                                                             + http://192.168.122.116/phpMyAdmin/setup/config (CODE:303|SIZE:1370)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/setup/frames/
+ http://192.168.122.116/phpMyAdmin/setup/index (CODE:200|SIZE:8619)
+ http://192.168.122.116/phpMyAdmin/setup/index.php (CODE:200|SIZE:8627)
                                                                             ==> DIRECTORY: http://192.168.122.116/phpMyAdmin/setup/lib/
+ http://192.168.122.116/phpMyAdmin/setup/scripts (CODE:200|SIZE:21967)
+ http://192.168.122.116/phpMyAdmin/setup/styles (CODE:200|SIZE:6218)

---- Entering directory: http://192.168.122.116/phpMyAdmin/test/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/themes/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/twiki/bin/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/twiki/lib/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/twiki/pub/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/setup/frames/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

---- Entering directory: http://192.168.122.116/phpMyAdmin/setup/lib/ ----
                                                                             (!) WARNING: Directory IS LISTABLE. No need to scan it.
    (Use mode '-w' if you want to scan it anyway)

-----------------
END_TIME: Sun Sep  6 04:35:29 2026
DOWNLOADED: 18448 - FOUND: 42

┌──(kali㉿kali)-[~]

```

### Observed results

| Result                             | Status | Meaning |
| ---------------------------------- | ------ | ------- |
| http://192.168.122.116/dav/        | 200    | Success |
| http://192.168.122.116/twiki/      | 200    | Success |
| http://192.168.122.116/phpMyAdmin/ | 200    | Success |
| http://192.168.122.116/mutillidae/ | 200    | Success |
| http://192.168.122.116/uploads/    | 200    | Success |

### Step 18: Relate DIRB to uploads

- I checked paths that suggested uploads, files, or image storage.
- Relevant path(s): http://192.168.122.116/dav
- The result shows the directory is listable, which may allow attackers to view uploaded files or other sensitive content.

### Step 19: Save DIRB output

```bash
dirb http://192.168.122.116 -o lab2-dirb.txt
```

- Output file created: lab2-dirb.txt
- Evidence stored: Screenshot of the output is under the screenshots directory.

---

## 10. Part 9 - Mutillidae Input Mapping

### Step 20: Open Mutillidae

- Mutillidae URL used: http://192.168.122.116/mutillidae/
- Result: The application loaded successfully.
- Evidence: Screenshot of the Mutillidae home page is under the screenshots directory.

### Step 21: Identify user-controlled inputs

| Page      | Parameter | Method | Normal value |
| --------- | --------- | ------ | ------------ |
| login.php | username  | POST   | admin        |
| login.php | password  | POST   | password     |

### Step 22: Establish baseline

```
GET /mutillidae/index.php?page=user-info.php HTTP/1.1
Host: 192.168.122.116
Cache-Control: max-age=0
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://192.168.122.116/mutillidae/index.php?page=user-info.php&username=admin&password=password&user-info-php-submit-button=View+Account+Details
Accept-Encoding: gzip, deflate, br
Cookie: username=REDACTED; uid=REDACTED; PHPSESSID=REDACTED
If-Modified-Since: Sun, 06 Sep 2026 09:20:48 GMT
Connection: keep-alive

```

---

## 11. Part 10 - Manual SQL Injection Concepts

### Scope

The SQL injection tests below were limited to the intentionally vulnerable classroom exercise only. The defensive lesson is to use parameterised queries, prepared statements, and safe error handling.

```sql
SELECT * FROM users WHERE id = ''';
```

### Step 23: Single quote test

- Input tested: '
- Result: The application returned invalid username or password

### Step 24: True vs false condition

- True condition: `1' OR '1'='1`
- False condition: `1' AND '1'='2`

### Observed difference

- True expression behaviour: I was able to log in successfully and view the user account details.
- False expression behaviour: I could not log in and received an error message indicating invalid credentials.

### Step 25: Inspect in Burp

- Burp request location: Proxy → HTTP History

```
POST /mutillidae/index.php?page=login.php HTTP/1.1
Host: 192.168.122.116
Content-Length: 93
Cache-Control: max-age=0
Accept-Language: en-US,en;q=0.9
Origin: http://192.168.122.116
Content-Type: application/x-www-form-urlencoded
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://192.168.122.116/mutillidae/index.php?page=login.php
Accept-Encoding: gzip, deflate, br
Cookie: PHPSESSID=REDACTED
Connection: keep-alive

username=1%27+OR+%271%27%3D%271&password=1%27+OR+%271%27%3D%271&login-php-submit-button=Login
```

- Request details:
  - Method: POST
  - Path: /mutillidae/index.php?page=login.php
  - Parameter name: username
  - Parameter value: `1' OR '1'='1`
  - Session data hidden: PHPSESSID

### Summary

Manual testing confirmed that the user input was reaching the server and was being interpreted as part of the SQL query logic.

---

## 12. Part 11 - SQLMap Guided Verification

### Step 26: Understand SQLMap syntax

```bash
sqlmap -u '<target-url>'
```

- Purpose: Identify the exact approved parameter before automated testing.
- Initial GET target tested: `page=user-info.php&id=1`
- Result: sqlmap did not find an injectable GET parameter on that URL.
- Approved parameter selected: `username` in the POST request to `login.php`

### Step 27: Test one approved parameter

```bash
sqlmap -u 'http://192.168.122.116/mutillidae/index.php?page=login.php' --data='username=1&password=1&login-php-submit-button=Login' -p username --cookie='PHPSESSID=REDACTED' --batch
```

- Injection type detected: boolean-based blind, error-based, time-based blind, and UNION query
- DBMS detected: MySQL >= 4.1

### Step 28: List lab databases

```bash
sqlmap -u 'http://192.168.122.116/mutillidae/index.php?page=login.php' --data='username=1&password=1&login-php-submit-button=Login' -p username --cookie='PHPSESSID=REDACTED' --dbs --batch
```

- Database names observed:
  - 2

### Step 29: List tables

```bash
sqlmap -u 'http://192.168.122.116/mutillidae/index.php?page=login.php' --data='username=1&password=1&login-php-submit-button=Login' -p username --cookie='PHPSESSID=REDACTED' -D mutillidae --tables --batch
```

- Relevant tables: none returned for `mutillidae`.
- A second check against `owasp10` also returned no tables.


### Part 14 - Student Questions
1. What is the difference between GET and POST?
- GET requests send parameters in the URL, while POST requests send parameters in the request body. GET is typically used for retrieving data, while POST is used for submitting data to be processed.
2. What is a parameter? 
- A parameter is a user-controlled input that can be included in a request, either in the URL (for GET requests) or in the body (for POST requests). Parameters can influence the behavior of the application and are often used to pass data between the client and server.
3. Why should cookies be hidden in reports?
- Cookies often contain sensitive information, such as session identifiers or authentication tokens. Exposing these values in reports can lead to security risks, including session hijacking or unauthorized access. Therefore, cookies should be redacted or hidden in reports to protect user privacy and application security.
4. What is multipart/form-data?
- `multipart/form-data` is a content type used for submitting forms that include files, allowing the form data to be sent in multiple parts. Each part can contain a different type of data, such as text fields and file uploads, making it suitable for handling complex form submissions.
5. Why are extension and MIME type different?
- The file extension is part of the filename and indicates the intended file type (e.g., `.txt`, `.jpg`), while the MIME type is a label sent in the HTTP headers that describes the actual content type of the file (e.g., `text/plain`, `image/jpeg`). They can differ because a user can rename a file to have a different extension without changing its actual content, leading to potential security risks if the server relies solely on extensions for validation.
6. Why is trusting client Content-Type weak?
- Trusting the client-supplied `Content-Type` header is weak because it can be easily manipulated by an attacker. An attacker can change the `Content-Type` to bypass server-side validation, potentially allowing them to upload malicious files or execute unintended actions. Therefore, servers should validate the actual content of uploaded files rather than relying solely on the `Content-Type` provided by the client.
7. Why should uploads be stored outside an executable web directory?
- Store uploads outside an executable web directory so malicious files cannot be run by the web server. This reduces the risk of code execution and keeps uploaded files safer.
8. What kind of information did Nikto report?
- Nikto reported various security issues, including outdated software versions, missing security headers, exposure of sensitive information through phpinfo(), active HTTP TRACE method, and exposure of phpMyAdmin. These findings indicate potential vulnerabilities that could be exploited by attackers.
9. What do 200, 301/302, 403 and 404 generally mean in DIRB output?
- 200: Success - The requested resource was found and returned successfully.
- 301/302: Redirection - The requested resource has been moved to a different URL, and the client should follow the new location.
- 403: Forbidden - The server understood the request but refuses to authorize it, indicating that access is denied.
- 404: Not Found - The requested resource could not be found on the server, indicating that the URL does not exist or is incorrect.
10. Why establish a baseline before SQL tests?
- Establishing a baseline before SQL tests helps to understand the normal behavior of the application and its responses to valid inputs. This allows testers to identify anomalies or unexpected behaviors when testing for SQL injection vulnerabilities, making it easier to detect potential security issues.
11. What happened with a single quote?
- When a single quote was entered as input, the application returned an error message indicating invalid username or password. This suggests that the input was not properly sanitized and was interpreted as part of the SQL query, leading to a syntax error in the database query.
12. How did the true and false conditions differ?
- The true condition (`1' OR '1'='1`) allowed successful login and access to user account details, while the false condition (`1' AND '1'='2`) resulted in an error message indicating invalid credentials. This difference demonstrates how SQL injection can manipulate the logic of the SQL query to bypass authentication.
13. What did SQLMap automate that you already observed manually?
- SQLMap automated the process of identifying injectable parameters, testing various SQL injection techniques (such as boolean-based blind, error-based, time-based blind, and UNION query), and enumerating databases and tables. It streamlined the testing process by automating repetitive tasks that were previously done manually, allowing for more efficient and comprehensive testing of SQL injection vulnerabilities.
14. Why do prepared statements stop input from being interpreted as SQL syntax?
- Prepared statements prevent input from being interpreted as SQL syntax by separating the SQL code from the user-supplied data. When using prepared statements, the SQL query is defined with placeholders for parameters, and the actual values are bound to these placeholders at execution time. This ensures that user input is treated strictly as data, rather than executable code, effectively mitigating the risk of SQL injection attacks.
15. Why is authorisation mandatory?
- Authorization is mandatory to ensure that users have the appropriate permissions to access specific resources or perform certain actions within an application. It helps protect sensitive data and functionality from unauthorized access, reducing the risk of data breaches, privilege escalation, and other security vulnerabilities. Proper authorization mechanisms enforce access control policies and maintain the integrity and confidentiality of the system.