# SkillBoxFinalWork
## Схема инфраструктуры ##

![Схема инфраструктуры](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/%D0%A1%D1%85%D0%B5%D0%BC%D0%B0%20%D0%B8%D0%BD%D1%84%D1%80%D0%B0%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D1%8B02.drawio.svg)

## Схема потоков данных ##

![Схема потока данных](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/%D0%9F%D0%BE%D1%82%D0%BE%D0%BA%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%8501.drawio.svg)

## **Руководство системного  администратора** ##

Сервер Openvpn расположен по адресу 158.160.37.149 на виртуальной машине запущенной в облаке Yandex Cloud, необходимо подключаться под пользователем yc-user.

### Создание инфраструктуры ###
***

#### Создание ВМ на Yandex Cloud ####
***

На машине 192.168.100.6 устовлена и настроена утилита yc для работы с облаком.

Создание новой виртуальной машины на облаке автоматизировано с помощью скрипта [create_vm_in_cloud.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/create_vm_in_cloud.sh) под пользователеем ilkosh.

_Для иформации: чтобы начать работу с облаком с другой машины, нужно воспользоваться инструкцией [YC QuickStart](https://cloud.yandex.ru/docs/cli/quickstart)._

Для вызова справки по скрипту нужно запустить его без параметров:

```
./create_vm_in_cloud.sh
```
[Пример вывода справки](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/Snag_185aa5f2.png)

[Пример запуска с параметрами](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/Snag_185cb8a5.png), [Штатное завершение](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/Snag_185db9ba.png)

При успешном запуске скрипт создаст ВМ с заданными параметрами (имя, количество ядер, RAM) И выдаст подробную информацию о созданной ВМ. Подключаться к ней можно через ssh использую закрытый ключ /home/ilkosh/.ssh/yacloud_key_id_01.

_Для информации: в скрипте есть проверка на наличие на машине пары ключей yacloud_key_id_01, yacloud_key_id_01.pub, если требуется подключаться к ВМ по другому ключу его необходимо создать и скорректировать скрипт. Также это актуально при запуске скрипта на другой машине._


#### Создание удостоверяющего центра EasyRSA ####

На выделенной машине установить деб-пакет [easy-rsa-setup_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/easy-rsa-setup_1.0-1_all.deb)

```
sudo dpkg -i ~/easy-rsa-setup_1.0-1_all.deb
```
После установки пакета в директории /tmp появится скрипт [easy-rsa-setup.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/easy-rsa-setup.sh) и конфигурационный файл [vars](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/vars). Нужно запустить этот скрипт. Он запустит установку easy-rsa и развернет инфраструктуры ключей на основе конфига [vars](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/vars) в директории /usr/share/easy-rsa

```
sudo /tmp/easy-rsa-setup.sh
```
Нужно выполнить на сервере EasyRSA и сервере OpenVPN


#### Установка OpenVPN сервера ####

На выделенной машине установить деб-пакет [openvpn-setup_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/openvpn-setup_1.0-1_all.deb)

```
sudo dpkg -i ~/openvpn-setup_1.0-1_all.deb
```

После установки пакета в директории /tmp появится скрипт [openvpn-setup.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/openvpn-setup.sh) и конфигурационный файл [server.conf](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/server.conf). Нужно запустить этот скрипт. Он запустит установку openvpn и добавит рабочий конфигурационный файл для сервера.

```
sudo /tmp/openvpn-setup.sh
```

Далее на сервере OpenVPN установить деб-пакет [openvpn-scripts_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/openvpn-scripts_1.0-1_all.deb).
После установки пакета появится директория /usr/share/openvpn_scripts и в ней будут находиться скрипты:
- [gen-server-sert-and-key-pair.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/gen-server-sert-and-key-pair.sh)
- [gen-client-sert-and-key-pair.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/gen-client-sert-and-key-pair.sh)
- [iptables-conf.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/iptables-conf.sh)
- [copy-server-and-ca-sert-to-openvpn.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/copy-server-and-ca-sert-to-openvpn.sh)

- [x] Для создания сертификата для сервера OpenVPN необходимо запустить под yc-user скрипт
```
/usr/share/openvpn_scripts/gen-server-sert-and-key-pair.sh
```
При успешном выполнении скрипта подписанный удостоверяющим центром сертификат будет лежать в директории /tmp.
Далее следует переместить сертификаты из директории /tmp в директорию сервера /etc/openvpn и создать ключ ta.key для дополнительного шифрования. Для этого надо запустить скрипт:

```
/usr/share/openvpn_scripts/copy-server-and-ca-sert-to-openvpn.sh
```

- [x] Для настройки безопасности на сервере OpenVPN необходимо выполнить следующие действия:
```
#узнать имя сетевого интерфейса
ip a
#скопировать имя интерфейса

#запустить скрипт с указанными параметрами:

/usr/share/openvpn_scripts/iptables-conf.sh <имя_интерфейса> udp 1194
 
```

Добавить OpenVPN  в автозагрузку:
```
sudo systemctl -f enable openvpn-server@server.service
 
```
Запустить OpenVPN сервер:
```
sudo systemctl start openvpn-server@server.service
 
```
- [x] Для создания сертификата для клиента необходимо под пользователем yc-user на сервере Openvpn запустить скрипт с параметром client_name - имя клиента:

```
/usr/share/openvpn_scripts/gen-client-sert-and-key-pair.sh <client-name>
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
sudo systemctl start openvpn-client@client_name
```

### Процедура восстановления ###
***
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
   - расположение *158.160.104.119:/usr/share/easy-rsa/*
   - backup *192.168.100.9:/home/ilkosh/backup/backup-EasyRSA/*

Резервное копирование осуществляется централизовано на сервере *192.168.100.9* с помощью скрипта [backup.py](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/backup.py), который хранится в директории *192.168.100.9:/usr/share/backup_scripts/backup.py* и который пишет лог в *192.168.100.9:/var/log/backup_log/backup.log.* Скрипт запускается в кроне каждую неделю.

Скрипт [backup.py](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/backup.py) имеет конфигурационный файл в формате YAML, который находится в *192.168.100.9:/home/ilkosh/backup_scripts/backup-config.yml*

Пример конфигурационного файла: [backup-config.yml](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/backup-config.yml)

Данный конфигурационный файл имеет следующий формат настроек:

```
   - host: #название хоста или ip
     dir_from: #директория которую нужно бэкапить
     dir_to: #где хранится бэкап на бекап-сервере
     exclude_files: #не обязательное поле. файлы который нужно исключить из бекапа, перечисляются как список 
       - filename
```

#### Установка системы резервного копирования ####
***

На backup сервере необходимо установить деб-пакет [backup-scripts_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/backup-scripts_1.0-1_all.deb).
  ```
  sudo apt install -f ./backup-scripts_1.0-1_all.deb
  ```

_Для информации: данный деб пакет имеет зависимость от пакета python3, также приустановке пакета запускается скрипт postinst, который устанавливает библиотеку pyyaml для Python, так как скрипт бэкапа загружает ее при запуске._

После установки деб пакета скрипт и конфигурационный файл появятся в директории /usr/share/backup_scripts
Для корректной работы системы бекапа нужно запускать скрипт backup.py в кроне, пример записи в кроне:

  ```
  00 23 * * 1 /usr/share/backup_scripts/backup.py
  ```
***
#### Действия при необходимости восстановления данных ####

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
  - восстановление скриптов автоматизации OpenVPN:
  ```
  rsync -av /home/ilkosh/backup/backup-EasyRSA/ 158.160.104.119:/usr/share/easy-rsa/

  # !!! В случае утраты закрытого ключа его можно восстановить на основе зашифрованного варианта, который хранится на бекапе. В этом случае нужно будет расшифровать закрытый ключ после восстановления из бекапа с помощью пароля (должен хранится где-то в защищенном месте/у специального сотрудника)
  ```

  При необходимости восстановить не только конфигурационные файлы, но и всю систему целиком (или отдельный сервис, к примеру OpenVPN сервер, необходимо проделать шаги из пункта инструкции по установке соответствующей системы из деб-пакетов).

### Описание системы мониторинга ###
#### Установка Prometheus сервера ####

На хост Prometheus необходимо скачать деб-пакет [prometheus-conf_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/prometheus-conf_1.0-1_all.deb). В директории куда скачан деб-пакет выполнить:

  ```
  sudo apt install -f ./prometheus-conf_1.0-1_all.deb
  ```
_Для справки: в установленном деб-пакете заданы зависимости prometheus, prometheus-alertmanager, prometheus-node-exporter, prometheus-process-exporter. После установки зависимостей устанавливаются преднастроенные конфигурационные файлы prometheus.yml.new, alertmanager.yml.new и rules.yml.new, которые скриптом postint заменяют стандартные файлы конфигурации в /etc/prometheus._
***
#### Настройка таргетов #####

ЧТобы на сервер Prometheus получать метрики от таргетов (хостов), необходимо установить на этих машинах соответствующие экспортеры, например prometheus-node-exporter, prometheus-process-exporter с помощью команды
  ```
  sudo apt install <название_эксмпортера_прометеус>
  ```
***
#### Конфигурирование Prometheus сервера ####

На сервер Prometheus необходимо установить деб-пакет [set-alert-job-scripts_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/set-alert-job-scripts_1.0-1_all.deb).
  ```
  sudo dpkg -i ./set-alert-job-scripts_1.0-1_all.deb
  ```
После установки деб-пакета в директории /usr/share/prometheus_scripts добавятся два скрипта: [add_new_prometheus_job.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/add_new_prometheus_job.sh) [add_new_prometheus_node_rules.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/add_new_prometheus_node_rules.sh)

С помощью скрипта [add_new_prometheus_job.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/add_new_prometheus_job.sh) можно поставить на мониторинг новый таргет (хост), с помощью опций --client и --ip указав имя таргета и его ip адрес соответственно:
  ```
  /usr/share/prometheus_scripts/add_new_prometheus_job.sh --client <client_name> --ip <ip_adress>
  ```
С помощью скрипта [add_new_prometheus_node_rules.sh](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/add_new_prometheus_node_rules.sh) можно автоматически настроить мониторинг основных показателей работы хоста: ЦПУ, оперативная память, общая доступность, с помощью опций --client и --ip указав имя таргета и его ip адрес соответственно:
  ```
  /usr/share/prometheus_scripts/add_new_prometheus_node_rules.sh --client <client_name> --ip <ip_adress>
  ```
***
#### Оповещение #####

При установке деб пакета [prometheus-conf_1.0-1_all.deb](https://github.com/IliaKoshkin/SkillBoxFinalWork/blob/main/prometheus-conf_1.0-1_all.deb) на сервер Prometheus устанавливается Alertmanager с преднастроенным конфигурационным файлом alertmanager.yml.

Alertmanager отправляет алерты по протоколу SMTP на почту mr.koshkin.iu@yandex.ru
