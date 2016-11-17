# Nginx������

> Nginx�ķ�������Ҫʹ�õ���refererģ�顣


* valid_referers
```
�﷨��
valid_referers none | blocked | server_names | <string> ...

˵��������HTTP����ͷ����Referer�ֶΣ������$invalid_referer��������Ϊ���ַ���������$invalid_referer��������Ϊ1. ƥ��ʱ�����ִ�Сд

none����ʾ����ͷ��û��Referer�ֶΡ�
blocked����ʾ����ͷ����Referer�ֶΣ����Ǹ��ֶε�ֵ�Ѿ�������ǽ�����Ǵ��������ɾ���ˣ�������"http://"������"https://"��ͷ
server_names������ͷ��Referer�ֶΰ�������һ��server name��
string����ʾ������ַ�����������һ��server name������server name��URI�Ľ�ϣ�����ʹ����server name�Ŀ�ͷ�ͽ�β����ʹ��*�����Ҳ�����Referer�ֶεķ������Ķ˿ںš�
    Ҳ����ʹ��������ʽ����ƥ�䣬���Ҫʹ��������ʽ�����һ�����ű�����"~"�����ұ��ʽƥ�������Ӧ����"http://"������"https://"�Ժ�����ݡ�
```

* ����ʾ��
```
location ~ \.(png|jpg|jpeg|gif)$ {
    valid_referers none blocked server_names
            *.kakaogift.cn  *.kakaogift.com;

    if ($invalid_referer) {
        return 403;
    }   
} 
```

# Rewrite
* rewriteģ�����ṩ��ָ��Ĵ���˳��
```
1. rewriteģ�����ṩ��ָ���server���У����ݳ��ֵ��Ⱥ�˳��ִ�С�
2. ����������ظ�ִ�У�
    2.1 ���������URI����location
    2.2 ��location�ڲ���rewriteģ�����ṩ��ָ�˳���ִ�С�
    2.3 ��������URI����д�����ظ��˹��̡�������д��಻����10�Σ���������500(Internal server error)
```

* break
```
����server��location��if���С�
���ã�ֹͣ���������rewriteģ�����ṩ��ָ����Ƿ�rewriteģ�����ṩ��ָ����������
```

* rewrite_log
```
����http��server��location��if���С�
Ĭ��ֵ��rewrite_log off;
���ã��Ƿ�����rewrite log���ܡ�rewrite��log��д�뵽error_log�У���־�ȼ�Ϊnotice��
```

* set
```
����server��location��if���С�
�﷨��ʽ��set $variable value
���ã�Ϊָ����variable����ֵ��value���԰����ı����������������ߵ���ϡ�

ʾ����
set $rewrite 1;
```

* if
```
����server��location���С�
�﷨��ʽ��if (condition) { ... }
���ã����ָ����conditionΪ�棬��ִ�д������е�ָ�

condition���ܵ�������£�
1. condition��һ�����������������ֵΪ���ַ���������0����Ϊ�١�if ($invalid_referer) { ... }
2. ���������ַ���ʹ��"="��"!="���бȽϡ� if ($flag = "f") { ... }
3. ʹ��������ʽ����ƥ��
    ~����ʾƥ�䣬���ִ�Сд��
    ~*����ʾƥ�䣬�����ִ�Сд��
    !~����ʾ��ƥ�䣬���ִ�Сд��
    !~*����ʾ��ƥ�䣬�����ִ�Сд��
4. ����ļ��Ƿ���ڡ�-f��!-f
5. ���Ŀ¼�Ƿ���ڡ�-d��!-d
6. ����ļ���Ŀ¼����������Ƿ���ڡ�-e��!-e
7. ����ļ��Ƿ��ִ�С�-x��!-x
```

* return
```
����server��location��if���С�
�﷨��ʽ��
return code [text];
return code URL;
return URL;

���ã�ֹͣ�������ҷ���ָ���Ĵ��������ͻ��ˡ�

1. ���code��301��302��303��307�������ʹ�õ���URL��
2. �����������code����������ʹ��text�����text��ʾ����response body�����ݡ�
3. URL��text�����԰���������
4. ���ʹ�õ��ǵڶ���return��ʽ����url����������һ��URI��/index.html��ʽ�ģ���������http��https��ͷ��һ������URL��
5. ���ʹ�õ��ǵ�����return��ʽ����url������������http��https��ͷ��URL��Ĭ�ϵ�response code��302.
```

* rewrite
```
����server��location��if���С�
�﷨��ʽ��rewrite regex replacement [flag];

��������URIƥ����regex����URI�ᱻreplacement�����滻�����replacement��http://����https://��ͷ�����ֹͣ���������ظ��ͻ��ˡ�
rewrite����ݳ����������ļ��е��Ⱥ�˳��ִ�С�

��ѡ��flag����������֮һ��
1. last��ֹͣ����ǰ��Rewriteָ�������ʹ���µ�URI��������location��һ������
2. break��ֹͣ����ǰ��Rewriteָ������ǲ���ʹ���µ�URI����location����ͬ��breakָ�һ������
3. redirect������һ��302��ʱ�ض������Ӧ����ͻ��ˡ��ͻ��˻�ʹ���µ�URI�������󡣻�����������
4. permanent������һ��301�����ض������Ӧ����ͻ��ˡ��ͻ��˻�ʹ���µ�URI�������󡣻�����������

```