# 压缩
## 创建一个压缩文件
```python
#!/usr/bin/env python
import gzip
import os
linesep = os.linesep
content = 'use gzip module to compress some content'
compressFilename = r'/tmp/test.gz'
compressOut = gzip.open(compressFilename,'wb',compresslevel=6)
compressOut.writelines('%s %s' % (content, linesep))
compressOut.close()
```

```bash
[root@control tmp]# ls -l test.gz
-rw-r--r-- 1 root root 65 Jul 25 13:23 test.gz
[root@control tmp]# zcat test.gz
use gzip module to compress some content
[root@control tmp]#
```
## 从已有的文件创建一个压缩文件
```python
#!/usr/bin/env python
import gzip
compressFilename = r'/tmp/issue.gz'
compressFromFile = r'/tmp/issue'
compressIn = open(compressFromFile,'rb')
compressOut = gzip.open(compressFilename, 'wb', compresslevel=6)
compressOut.writelines(compressIn)
compressOut.close()
compressIn.close()
```
查看压缩文件的内容
```bash
[root@control tmp]# ls -l issue.gz
-rw-r--r-- 1 root root 73 Jul 25 13:28 issue.gz
[root@control tmp]# zcat issue.gz
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@control tmp]#
```

# 查看压缩文件的内容
```python
#!/usr/bin/env python
import gzip
compressFilename = r'/tmp/issue.gz'
f = gzip.open(compressFilename, 'rb')
for eachLine in f:
    print eachLine,

f.close()
```

示例：
```bash
[root@control tmp]# cat 3.py
#!/usr/bin/env python
import gzip
compressFilename = r'/tmp/issue.gz'
f = gzip.open(compressFilename, 'rb')
for eachLine in f:
    print eachLine,

f.close()
[root@control tmp]#

[root@control tmp]# python 3.py
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@control tmp]#
```
