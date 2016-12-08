#!/bin/env python2.7
# coding: utf-8

import pickle
import os
import random

STRINGS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
SECURE_CODE_LENGTH = 4
USER_FILE = r'users.pk'

# init account
init_user = 'admin'
init_pass = 'admin'
init_admin = {init_user: init_pass}

if not os.path.exists(USER_FILE):
    print ' Initilazies the admin accout '.center(50, '-')
    print '\tusername: %s' % init_user
    print '\tpassword: %s' % init_pass

    fp = open(USER_FILE, 'wb')
    pickle.dump(init_admin, fp)
    fp.close()
    print ' Initilazies admin account successful '.center(50, '-')
    print

# read account info from USER_FILE
fp = open(USER_FILE, 'rb')
users = pickle.load(fp)
fp.close()

# login
while True:
    secure_code = ''
    print ' login '.center(30, '*')
    username = raw_input('\tusername: ').strip()
    password = raw_input('\tpassword: ').strip()
    # generate secure code
    for _ in range(SECURE_CODE_LENGTH):
        secure_code += ''.join(random.choice(STRINGS))

    code = raw_input('\tcode(%s): ' % secure_code).strip()

    if username not in users:
        print
        print "username or password error!!!"
        print
        continue

    if password != users[username]:
        print
        print 'username or password error!!!'
        print
        continue

    if code.lower() != secure_code.lower():
        print
        print 'secure code mismatch!!!'
        print
        continue

    print ' login sueccess '.center(30, '*')
    print
    break


def add():
    fp = open(USER_FILE, 'rb')
    users = pickle.load(fp)
    fp.close()

    print
    u = raw_input('[add] username: ').strip()
    p = raw_input('[add] password: ')

    if not len(u) and not len(p):
        print 'username or password can not null !!!'
        return False

    if u not in users:
        users[u] = p
        fp = open(USER_FILE, 'wb')
        pickle.dump(users, fp)
        fp.close()
        print ' add user [%s] successful '.center(30, '*') % u
        print
        return True
    else:
        print 'username [%s] is exist, please use another username !!!' % u
        return False


def delete():
    fp = open(USER_FILE, 'rb')
    users = pickle.load(fp)
    fp.close()

    print
    u = raw_input('[del] username: ').strip()

    if not len(u):
        print 'username can not null !!!'
        print
        return False

    if u not in users:
        print '[%s] is not exist' % u
        print
        return False

    if u in users:
        del users[u]
        fp = open(USER_FILE, 'wb')
        pickle.dump(users, fp)
        fp.close()
        print ' delete [%s] successful '.center(30, '-') % u
        print
        return True


def show():
    fp = open(USER_FILE, 'rb')
    users = pickle.load(fp)
    fp.close()

    count = 0
    print
    print ' users list '.center(30, '-')
    for user in users:
        count += 1
        print 'user %d: %s' % (count, user)

    print ' users end'.center(30, '-')
    print


# menu
menu_options = ['a', 'd', 's']
menu_functions = [add, delete, show]
menu_select = dict(zip(menu_options, menu_functions))

menu = '''(S)how all users
(A)add user
(D)elete user
(Q)uit

please enter your select [A/D/E/Q/S]: '''

while True:
    print ' Menu '.center(30, '*')
    try:
        select = raw_input(menu).strip()[0].lower()
    except (IndexError, KeyboardInterrupt, EOFError), e:
        print
        print 'Invalid input , try again !!!'
        print
        continue

    if select == 'q':
        print ' Quit '.center(30, '*')
        break

    if select in menu_select:
        menu_select[select]()
    else:
        print
        print 'Invalid input , try again !!!'
        print
        continue
