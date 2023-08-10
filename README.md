# SkillBoxFinalWork
## Схема инфраструктуры ##



## Руководство системного  администратора ##
### Процедура восстановления ###

При эксплуатации инфраструктуры требуется осуществление резервного копирования следующих данных:

1. Файл конфигурации OpenVPN сервера
   - расположение *158.160.37.149:/etc/openvpn/server/server.conf*
   - backup *192.168.100.9:/home/ilkosh/backup/openvpn/server/server.conf*
3. Файлы конфигурации клиентов OpenVPN сервера
   - расположение *158.160.37.149:/home/yc-user/client-configs/*
   - backup *192.168.100.9:/home/ilkosh/backup/openvpn/client-configs/*
5. Скрипты автоматизации настройки OpenVPN сервера
   - расположение *158.160.37.149:/home/yc-user/openvpn-scripts/*
   - backup *192.168.100.9:/home/ilkosh/backup/openvpn/openvpn-scripts/*
7. Инфраструктуры EasyRSA
   - расположение

Резервное копирование осуществляется централизовано на сервере *192.168.100.9* с помощью скрипта backup.py, который хранится в директории *192.168.100.9:/home/ilkosh/backup_scripts/backup.py* и который пишет лог в *192.168.100.9:/home/ilkosh/backup_log/backup.log.* Скрипт запускается в кроне каждую неделю.

Скрипт backup.py имеет конфигурационный файл в формате YAML, который находится в *192.168.100.9:/home/ilkosh/backup_scripts/backup-config.yml*

Данный конфигурационный файл имеет следующий формат настроек:

```
   - host: #название хоста или ip
     dir_from: #директория которую нужно бэкапить
     dir_to: #где хранится бэкап на бекап-сервере
     exclude_files: #не обязательное поле. файлы который нужно исключить из бекапа, перечисляются как список 
       - filename
```
При необходимости восстановить данные необходимо на сервере *192.168.100.9* по пользователем ilkosh выполнить следующие команды:

- восстановление конфигурационного файла OpenVPN:
  ```
  rsync -av /home/ilkosh/backup/openvpn/server/ 158.160.37.149:/etc/openvpn/server/
  ```
- восстановление конфигурационных файлов клиентов OpenVPN:
  ```
  rsync -av /home/ilkosh/backup/openvpn/client-configs/ 158.160.37.149:/home/yc-user/client-configs/
  ```
- восстановление скриптов автоматизации OpenVPN:
  ```
  rsync -av /home/ilkosh/backup/openvpn/openvpn-scripts/ 158.160.37.149:/home/yc-user/openvpn-scripts/
  ```
