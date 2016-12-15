# Python装饰器

[参考](http://foofish.net/decorator.html)

* 什么是装饰器

>装饰器本质上是一个函数，该函数用来处理其他函数，它可以让其他函数在不需要修改代码的前提下增加额外的功能，装饰器的返回值也是一个函数对象。它经常用于有切面需求的场景，如：插入日志、性能测试、事务处理、缓存、权限校验等等。装饰器是解决这类问题的绝佳设计，有了装饰器，我们就可以抽离出大量与函数功能本身无关的雷同代码并继续重用。
>
>概括的说：装饰器的作用就是为已经存在的对象添加额外的功能。


* 引入装饰器
```
1. 定义一个函数，该函数输出当前时间
def local_time():
    print 'Current time:', time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

local_time()

2. 现在有一个新的需求，需要在该函数的基础上，增加日志输出功能，于是改函数变成了下面的样子
def local_time():
    print 'Current time:', time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
    logging.warn("local_time is running")


local_time()

3. 如果还有其他函数，如test1()、test2()呢，如果都使用这种方法的话，则需要在每个函数内部都增加了雷同的代码。
为了减少代码重复量，我们可以创建一个新的函数，该函数专门用来输出日志。

于是我们的函数变成了下面的样子：
def local_time():
    print 'Current time:', time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

def use_logging(func_name):
    logging.warn("%s is running..." % func_name.__name__)

use_logging(local_time)

4. 如果有其他的函数，也需要这种功能的话，则函数调用方式改为了use_logging(function_name), 这种情况，就破坏了原有的逻辑结构，之前执行函数是直接bar()，现在变成了use_logging(bar)，还不是很好，于是就有了装饰器。

简单的装饰器：
def use_logging(func_name):
    def wrapper(*args, **kwargs):
        logging.warn("%s is running..." % func_name.__name__)
        return func_name(*args, **kwargs)
    return wrapper

def local_time():
    print 'Current time:', time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

def test1(name='world'):
    print "hello", name

local_time = use_logging(local_time)
local_time()

test1 = use_logging(test1)
test1('felix')

说明：use_logging函数接收一个函数作为参数，并且返回一个函数对象,此时use_logging就是装饰器。

@符号是装饰器的语法结构，在定义函数时，为了避免再一次赋值操作。

因此上述语法改为：
def use_logging(func_name):
    def wrapper(*args, **kwargs):
        logging.warn("%s is running..." % func_name.__name__)
        return func_name(*args, **kwargs)
    return wrapper


@use_logging
def local_time():
    print 'Current time:', time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())


@use_logging
def test1(name='world'):
    print "hello", name


local_time()
test1('felix')

注意：装饰器一定要在最上面
```

* 带有参数的装饰器
```
在上述的装饰器中，装饰器唯一的参数就是我们要装饰的函数，装饰器的语法允许我们在调用时，提供其他参数。这样就为装饰器的编写和使用提供了更大的灵活性。

编写带有参数的装饰器，只需要在增加一层函数即可。


def use_logging(level):
    def decorator(func_name):
        def wrapper(*args, **kwargs):
            if level == 'warn':
                logging.warn("%s is running..." % func_name.__name__)
            if level == 'error':
                logging.error("%s is running..." % func_name.__name__)
            return func_name(*args, **kwargs)
        return wrapper
    return decorator


@use_logging(level='warn')
def local_time():
    print 'Current time:', time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())


@use_logging(level='error')
def test1(name='world'):
    print "hello", name


local_time()
test1('felix')
```