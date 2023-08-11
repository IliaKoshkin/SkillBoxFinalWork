# SkillBoxFinalWork
## Схема инфраструктуры ##

![Схема инфраструктуры](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/%D0%A1%D1%85%D0%B5%D0%BC%D0%B0%20%D0%B8%D0%BD%D1%84%D1%80%D0%B0%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D1%8B02.drawio.svg)

## Схема потоков данных ##

![Схема потока данных](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/%D0%9F%D0%BE%D1%82%D0%BE%D0%BA%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%8501.drawio.svg)

## **Руководство пользователя** ##

VPN (англ. virtual private network — «виртуальная частная сеть») — технология, позволяющая создать безопасное подключение пользователя к сети, организованной между несколькими компьютерами.

Данная технология удобна для:
- удаленнной работы;
- объединения сетей филиалов компаний;
- объединения и изоляции различных отделов компании;
- защиты передаваемой информации в недоверенной сети;
- обеспечения анонимности.

Инфраструктура, описанная данной документацией, использует для реализации VPN-туннелей open-source технологию OpenVPN.

Для предоставления доступа VPN необходимо обратиться к администратору.

## **Руководство системного  администратора** ##

Сервер Openvpn расположен по адресу 158.160.37.149 на виртуальной машине запущенной в облаке Yandex Cloud, необходимо подключаться под пользователем yc-user.

### Создание инфраструктуры ###

#### Создание удостоверяющего центра EasyRSA ####

На выделенной машине установить деб-пакет [easy-rsa-setup_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/easy-rsa-setup_1.0-1_all.deb)

```
sudo dpkg -i ~/easy-rsa-setup_1.0-1_all.deb
```
После установки пакета в директории /tmp появится скрипт easy-rsa-setup.sh и конфигурационный файл vars. Нужно запустить этот скрипт. Он запустит установку easy-rsa и развернет инфраструктуры ключей на основе конфига vars.

```
sudo /tmp/easy-rsa-setup.sh
```

#### Установка OpenVPN сервера ####

На выделенной машине установить деб-пакет [openvpn-setup_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/openvpn-setup_1.0-1_all.deb)

```
sudo dpkg -i ~/openvpn-setup_1.0-1_all.deb
```

После установки пакета в директории /tmp появится скрипт openvpn-setup.sh и конфигурационный файл server.conf. Нужно запустить этот скрипт. Он запустит установку openvpn и подменить рабочий файл с конфигурациями сервера.

```
sudo /tmp/openvpn-setup.sh
```

### Добавление доступа к VPN клиенту ###

Необходимо под пользователем yc-user на сервере Openvpn запустить скрипт с параметром client_name - имя клиента:

```
~/openvpn_scripts/gen-client-sert-and-key-pair.sh <client-name>
```
Скрипт отправляет запрос на подпись сертификата клиента в EasyRSA и размещает подписанный сертификат <client_name>.crt в директорию ~/client-configs/keys

Если выполнение скрипта завершилось успешно, то нужно создать конфигурационный файл для клиента на основе подписанного сертификата.
Для этого находясь на сервере Openvpn запускаем скрипт с параметром client_name - имя клиента (такое же как на предыдущем шаге):

```
~/home/yc-user/client-configs/make_config.sh <client-name>
```

После успешного выполнения скрипта будет создан файл конфигурации для клиента <client_name>.ovpn в директории

```
~/client-configs/files
```

Данный файл нужно передать на хост клиента (например через SSH) и положить в директорию с конфигурационными файлами клиента openvpn, предварительно установив OpenVPN если не установлен

```
Установка OpenVPN
sudo apt install openvpn;

Директория с конфигами клиента OpenVPN
/etc/openvpn/client
```
После этого на машине клиента запустить сервис openvpn.client:

```
sudo systemctl start openvpn.client
```

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

### Описание системы мониторинга ###
