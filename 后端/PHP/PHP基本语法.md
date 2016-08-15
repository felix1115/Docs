# 数据类型
```text
PHP的数据类型有：String、Integer、Boolean、Float、Array、Resource、Object、NULL

String：.用于将字符串连接起来。
Boolean: true/false
NULL: NULL表示变量没有值，NULL是数据类型NULL的值。

PHP常量：常量在整个脚本中都可以使用(包括函数)。值是不能改变的。
定义一个变量：define(变量名,变量值,true/false) ，true表示大小写不敏感，false表示大小写敏感，默认为false.
```

# 判断
## if判断
```text
单分支if语句
if (条件判断表达式) {
    statement
    ...
}

双分支if语句
if (条件判断表达式) {
    statement
    ...
} else {
    statement
    ...
}

多分支if语句
if (条件判断表达式) {
    statement
    ...
} elseif (条件判断表达式) {
    statement
    ...
} elseif (条件判断表达式) {
    statement
    ...
} else {
    statement
    ...
}

```

## switch判断
```text
switch(variable) {
    case "value1":
        statement
        ...
        break;
    case "value2":
        statement
        ...
        break;
    case "value3":
        statement
        ...
        break;
    ...

    default:
        statement
        ...
        break;
}
```

# 循环
## while循环
```text
while (条件判断表达式) {
    statement;
    ...
}
```

## do while循环
```text
do {
    statement;
    ...
} while (条件判断表达式);
```

## for循环
```text
for (初始值;结束条件;变化值) {
    statement;
    ...
}
```

## foreach
```text
foreach循环用于遍历数组。

foreach ($array as $value)
{
    要执行代码;
}
```

## break/continue/exit
```text
break：终止循环。
continue：终止此次循环，继续下次循环。continue后面的语句不会执行。
exit：退出程序。
```

# PHP变量作用域
```text
局部变量：在函数内部定义的变量，仅在函数内部有效。

全局变量：在函数外部定义的变量，除了函数外，全局变量可以在脚本中的任何位置使用。如果要在函数内部使用全局变量，则需要使用global关键字。PHP将所有的全局变量都存放在$GLOBALS[index]数组中，index保存的是变量的名称。这个数组可以直接在函数内部访问，也可以用来更新全局变量。

static作用域：当一个函数执行完毕后，在函数内部所定义的变量通常都会删除，有时候希望某个局部变量不要被删除，这时，就可以在定义变量时，使用static关键字。

参数作用域：参数是作为函数的一部分声明的。
```

