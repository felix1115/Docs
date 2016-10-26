# CGI
> CGI：Common Gateway Interface，通用网关接口。
最早的web服务器简单的响应浏览器发来的HTTP请求，并将存储在服务器上的HTML文件返回给浏览器，也就是静态html。食物总是不断发展，网站也是越来越复杂，后来就出现了动态技术。但是服务器并不能直接运行PHP、Perl这样的文件，自己不能做，就交给第三方做，既然是交给第三方做，就要和第三方做个约定(我给你什么，你给我什么，就是我把请求参数发给你，然后我将你发我给我的处理结果发送给客户端)，这个约定就是Common Gateway Interface，简称CGI。CGI只是个协议，不是任何语言，这个协议可以用C、PHP、Python、Bash、Perl等语言来实现。
流程如下：

![CGI流程图](https://github.com/felix1115/Docs/blob/master/Images/php-1.png)