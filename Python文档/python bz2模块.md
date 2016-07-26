# 单次压缩和解压缩
+ 单次压缩(bz2.compress)
```python
In [40]: compressStr = 'use bz2 module to compress string'
In [41]: bz2.compress(compressStr,6)
Out[41]: 'BZh61AY&SY\xa5i\x9c"\x00\x00\x0f\x99\x80@\x00\x10\x00\x1e\xa7\xde\x10 \x001M2111\x08\x9ai\xa0h\xf56\xa3\xc3\x06.\x8fh\xf0S{\x83!KF{\xa4i\'\xe2\xeeH\xa7\n\x12\x14\xad3\x84@'
In [42]:
```

+ 单次解压缩(bz2.decompress)
```python
In [43]: bz2.decompress('BZh61AY&SY\xa5i\x9c"\x00\x00\x0f\x99\x80@\x00\x10\x00\x1e\xa7\xde\x10 \x001M2111\x08\x9ai\xa0h\xf56\xa3\xc3\x06.\x8fh\xf0S{\x83!KF{\xa4i\'\xe2\xeeH\xa7\n\x12\x14\xad3\x84@')
Out[43]: 'use bz2 module to compress string'
In [44]:
```

# 创建一个bz2压缩文件
## 从字符串创建一个bz2压缩文件
```python
#!/usr/bin/env python
import bz2
import os

linesep = os.linesep
compressStr = 'use bz2 module to compress string'
compressFilename = r'/tmp/test.bz2'

f = bz2.BZ2File(compressFilename, 'w', compresslevel=6)
f.write('%s%s' % (compressStr,linesep))

f.close()
```

测试
```bash
[root@control tmp]# python 1.py
[root@control tmp]# ls -l /tmp/test.bz2
-rw-r--r-- 1 root root 71 Jul 26 08:56 /tmp/test.bz2
[root@control tmp]# bzcat /tmp/test.bz2
use bz2 module to compress string
[root@control tmp]#
```

## 从一个文件创建bz2压缩文件
```python
#!/usr/bin/env python
import bz2
import os

linesep = os.linesep
compressFilename = r'/tmp/test2.bz2'
compressFromFile = r'/etc/issue'

compressIn = open(compressFromFile, 'r')
compressOut = bz2.BZ2File(compressFilename, 'w', compresslevel=6)
compressOut.writelines(compressIn)

compressOut.close()
compressIn.close()
```


测试
```bash
[root@control tmp]# python 2.py
[root@control tmp]# ls -l /tmp/test2.bz2
-rw-r--r-- 1 root root 90 Jul 26 09:04 /tmp/test2.bz2
[root@control tmp]# bzcat /tmp/test2.bz2
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@control tmp]#
```

## 使用shutil模块的copyfileobj方法实现类文件对象复制
```python
#!/usr/bin/env python
import bz2
import shutil

compressFilename = r'/tmp/test3.bz2'
compressFromFile = r'/etc/issue'

compressIn = open(compressFromFile, 'r')
compressOut = bz2.BZ2File(compressFilename, 'w', compresslevel=6)

shutil.copyfileobj(compressIn, compressOut)

compressOut.close()
compressIn.close()
```

测试
```bash
[root@control tmp]# python 3.py
[root@control tmp]# ls -l /tmp/test3.bz2
-rw-r--r-- 1 root root 90 Jul 26 09:22 /tmp/test3.bz2
[root@control tmp]# bzcat /tmp/test3.bz2
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@control tmp]#
```


# 查看bz2压缩文件的内容
```python
#!/usr/bin/env python
import bz2

compressFilename = r'/tmp/test3.bz2'

f = bz2.BZ2File(compressFilename, 'r')

for eachLine in f:
    print eachLine,

f.close()
```

测试
```bash
[root@control tmp]# python 4.py
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@control tmp]#
```
