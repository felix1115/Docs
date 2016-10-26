# CGI
> CGI：Common Gateway Interface，通用网关接口。
最早的web服务器简单的响应浏览器发来的HTTP请求，并将存储在服务器上的HTML文件返回给浏览器，也就是静态html。事物总是不断发展，网站也是越来越复杂，后来就出现了动态技术。但是服务器并不能直接运行PHP、Perl这样的文件，自己不能做，就交给第三方做，既然是交给第三方做，就要和第三方做个约定(我给你什么，你给我什么，就是我把请求参数发给你，然后我将你发我给我的处理结果发送给客户端)，这个约定就是Common Gateway Interface，简称CGI。CGI只是个协议，不是任何语言，这个协议可以用C、PHP、Python、Bash、Perl等语言来实现。
流程如下：

![CGI流程图](https://github.com/felix1115/Docs/blob/master/Images/php-1.png)


> 当web server收到/index.php这个请求后，会启动对应的CGI程序，这里就是PHP的解析器。接下来PHP解析器会解析php.ini文件，初始化执行环境，然后处理请求，再以规定CGI规定的格式返回处理后的结果，退出进程。web server再把结果返回给浏览器。


* CGI工作原理

> CGI工作原理：每当客户端请求CGI的时候，WEB服务器就请求操作系统生成一个新的CGI解释器进程(如php-cgi)，CGI的一个进程处理完请求后退出，下一个请求来时在创建新的进程。在访问量很少没有并发的时候也可以，但是当访问量很大的时候，这种情况效率就非常低下了，于是就有了FastCGI。



# FastCGI
> 


> FastCGI就像一个常驻(Long-live)型的CGI，它可以一直执行着，只要激活它，不会每次都会花费时间去fork一次。提高效率。


* FastCGI的工作流程
```
FastCGI的工作流程：
1. Web Server启动时载入FastCGI进程管理器
2. FastCGI进程管理器自身初始化，启动多个CGI解释器进程(可见多个php-cgi)并等待来自Web Server的连接。
3. 当客户端请求到达Web Server时，FastCGI进程管理器选择并连接到一个CGI解释器。 Web server将CGI环境变量和标准输入发送到FastCGI子进程php-cgi。
4. FastCGI子进程完成处理后将标准输出和错误信息从同一连接返回Web Server。当FastCGI子进程关闭连接时， 请求便告处理完成。FastCGI子进程接着等待并处理来自FastCGI进程管理器(运行在Web Server中)的下一个连接。 在CGI模式中，php-cgi在此便退出了。


在上述情况中，你可以想象CGI通常有多慢。使用FastCGI，所有这些都只在进程启动时发生一次。
```

* PHP-CGI的不足
```

```