# Домашнее задание к занятию "`Название занятия`" - `Фамилия и имя студента`


### Инструкция по выполнению домашнего задания

   1. Сделайте `fork` данного репозитория к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/git-hw или  https://github.com/имя-вашего-репозитория/7-1-ansible-hw).
   2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
   3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
      - впишите вверху название занятия и вашу фамилию и имя
      - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
      - для корректного добавления скриншотов воспользуйтесь [инструкцией "Как вставить скриншот в шаблон с решением](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
      - при оформлении используйте возможности языка разметки md (коротко об этом можно посмотреть в [инструкции  по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md))
   4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
   5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
   6. Любые вопросы по выполнению заданий спрашивайте в чате учебной группы и/или в разделе “Вопросы по заданию” в личном кабинете.
   
Желаем успехов в выполнении домашнего задания!
   
### Дополнительные материалы, которые могут быть полезны для выполнения задания

1. [Руководство по оформлению Markdown файлов](https://gist.github.com/Jekins/2bf2d0638163f1294637#Code)

---

### Задание 1

Docker Compose — это инструмент для описания и запуска многоконтейнерных приложений, позволяющий управлять всей инфраструктурой проекта (базами данных, веб-серверами, кэшем) через один конфигурационный YAML-файл. Лично мне, как специалисту по контекстной рекламе и будущему системному администратору, он помогает автоматизировать развертывание тестовых сред для лендингов и аналитических инструментов: вместо десяти сложных команд в терминале я использую одну. Это минимизирует риск ошибок при настройке, гарантирует идентичность окружения на разных ПК и существенно экономит время на рутине, которое можно направить на развитие бизнеса или общение с семьей.

![Установка Docker Compose](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task1.png)

---

### Задание 2

Текст конфигурационного файла `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Добавляем базовый сервис, чтобы конфиг был рабочим
  node_exporter:
    image: prom/node-exporter:v1.6.1
    container_name: node_exporter
    networks:
      - yuklashov-am-my-netology-hw

networks:
  # Твоя персональная сеть по заданию
  yuklashov-am-my-netology-hw:
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16

volumes:
  # Объявляем тома для будущих заданий
  prometheus_data:
  grafana_data:
```

---

### Задание 3

![Конфигурация и запуск контейнера](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task2.png)
![Интерфейс Prometheus в браузере](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task3.png)

---

### Задание 4

Для выполнения задания в файл `docker-compose.yml` был добавлен сервис Pushgateway:

```yaml
  pushgateway:
    image: prom/pushgateway:v1.6.2
    container_name: yuklashov-am-netology-pushgateway
    restart: always
    networks:
      - yuklashov-am-my-netology-hw
    ports:
      - "9091:9091"
```
![Конфигурация и запуск контейнера](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task4.png)
![Статус Pushgateway в Prometheus](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task5.png)
---

### Задание 5