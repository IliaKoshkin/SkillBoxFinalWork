#!/bin/python3

import subprocess
import yaml
import logging
import os

#ф-ция для вызова rsync с заданными параметрами
def call_rsync(host=None, dir_from=None, dir_to=None, exclude_files=None):
    
    #имя хоста и директория которая бэкапится
    host_dir_from = host + ':' + dir_from
    #подготовка параметра --exclude для утилиты rsync (файлы которые не надо бэкапить)
    if not exclude_files:
        exclude_param =  ''
    elif len(exclude_files) == 1:
        exclude_param = '--exclude=' + exclude_files[0]
    elif len(exclude_files) > 1:
        exclude_param = '--exclude={' + ','.join(f"'{file}'" for file in exclude_files) + '}'
    #cmd - команда rsync с параметрами которая и будет запускаться в оболочке bash
    cmd = ' '.join(['rsync', '-av', exclude_param, host_dir_from, dir_to])
    proc =  subprocess.Popen(cmd, shell=True, executable='/bin/bash', stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='utf-8')
    #вывод команды rsync после ее запуска
    outs, errs = proc.communicate()
    logging.info(f'Program rsync terminated with code {proc.poll()}')
    logging.info(f'Output:\n{outs}')
    if errs:
        logging.error(f'Errors:\n{errs}')

try:

    logging.basicConfig(level=logging.INFO, filename='/var/logs/backup_log/backup.log',
            format="%(asctime)s %(levelname)s %(message)s")
    logging.info('#######################################################')
    logging.info(f'Start program backup.py with PID {os.getpid()}')
    #чтение конфигурационного файла
    with open('backup-config.yml') as f:
        configs = yaml.safe_load(f)
        logging.info('READING configs.yaml file.')
    #в цикле вызывается функция call_rsync для каждого хоста пееречисленного в конфигурационном файле
    for config in configs:
        logging.info(f'Call rsync with parameters {config}')
        call_rsync(**config)
    
    logging.info(f'Program with PID {os.getpid()} terminated')
    print('Program terminated without exceptions.')
    logging.info('#######################################################')

#на случай любой ошибки, описание ошибки запишется в лог с тегом ERROR
except Exception as e:
    print('Exeption occured. Program terminated. See log.')
    logging.error(e)
    logging.info('#######################################################')


