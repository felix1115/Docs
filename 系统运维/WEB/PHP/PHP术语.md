# CGI
> CGI：Common Gateway Interface，通用网关接口。
最早的web服务器简单的响应浏览器发来的HTTP请求，并将存储在服务器上的HTML文件返回给浏览器，也就是静态html。事物总是不断发展，网站也是越来越复杂，后来就出现了动态技术。但是服务器并不能直接运行PHP、Perl这样的文件，自己不能做，就交给第三方做，既然是交给第三方做，就要和第三方做个约定(我给你什么，你给我什么，就是我把请求参数发给你，然后我将你发我给我的处理结果发送给客户端)，这个约定就是Common Gateway Interface，简称CGI。CGI只是个协议，不是任何语言，这个协议可以用C、PHP、Python、Bash、Perl等语言来实现。
流程如下：

![CGI流程图](https://github.com/felix1115/Docs/blob/master/Images/php-1.png)


> 当web server收到/index.php这个请求后，会启动对应的CGI程序，这里就是PHP的解析器。接下来PHP解析器会解析php.ini文件，初始化执行环境，然后处理请求，再以规定CGI规定的格式返回处理后的结果，退出进程。web server再把结果返回给浏览器。


* CGI工作原理

> CGI工作原理：每当客户端请求CGI的时候，WEB服务器就请求操作系统生成一个新的CGI解释器进程(如php-cgi)，CGI的一个进程处理完请求后退出，下一个请求来时在创建新的进程。在访问量很少没有并发的时候也可以，但是当访问量很大的时候，这种情况效率就非常低下了，于是就有了FastCGI。



# FastCGI

> CGI程序的性能问题在哪呢？"PHP解析器会解析php.ini文件，初始化执行环境"，就是这里了。标准的CGI对每个请求都会执行这些步骤，所以处理每个时间的时间会比较长。这明显不合理！那么Fastcgi是怎么做的呢？首先，Fastcgi会先启一个master，解析配置文件，初始化执行环境，然后再启动多个worker。当请求过来时，master会传递给一个worker，然后立即可以接受下一个请求。这样就避免了重复的劳动，效率自然是高。而且当worker不够用时，master可以根据配置预先启动几个worker等着；当然空闲worker太多时，也会停掉一些，这样就提高了性能，也节约了资源。这就是fastcgi的对进程的管理。


# PHP-FPM

> PHP的解释器是php-cgi。php-cgi只是个CGI程序，他自己本身只能解析请求，返回结果，不会进程管理。所以就出现了一些能够调度php-cgi进程的程序，比如说由lighthttpd分离出来的spawn-fcgi。好了PHP-FPM也是这么个东东，在长时间的发展后，逐渐得到了大家的认可（要知道，前几年大家可是抱怨PHP-FPM稳定性太差的），也越来越流行。