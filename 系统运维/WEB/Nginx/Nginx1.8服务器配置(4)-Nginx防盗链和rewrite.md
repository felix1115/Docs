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