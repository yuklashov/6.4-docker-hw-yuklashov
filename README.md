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

В файл `docker-compose.yml` добавлен сервис Grafana:

```yaml
  grafana:
    image: grafana/grafana:10.1.5
    container_name: yuklashov-am-netology-grafana
    restart: always
    environment:
      - GF_PATHS_CONFIG=/etc/grafana/grafana.ini
    ports:
      - "80:3000"
    volumes:
      - ./grafana.ini:/etc/grafana/grafana.ini
      - grafana_data:/var/lib/grafana
    networks:
      - yuklashov-am-my-netology-hw

```
![Конфигурация и запуск Grafana](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task6.png)
![Интерфейс Grafana в браузере](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task7.png)

---

### Задание 6

В итоговой конфигурации `docker-compose.yml` выполнены следующие настройки:
1. Настроена поочередность запуска контейнеров с помощью директивы `depends_on` (Prometheus ждет Pushgateway, Grafana ждет Prometheus).
2. Для всех контейнеров установлен режим автоматического перезапуска `restart: always`.
3. Все сервисы объединены в одну внутреннюю сеть `yuklashov-am-my-netology-hw`.
4. Запуск произведен в detached режиме (флаг `-d`).

![Финальный запуск всех контейнеров в detached режиме](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task8.png)
![Проверка статуса сервисов в Prometheus Targets](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task9.png)

---

### Задание 7

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.47.0
    container_name: yuklashov-am-netology-prometheus
    restart: always
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - yuklashov-am-my-netology-hw
    depends_on:
      - pushgateway

  pushgateway:
    image: prom/pushgateway:v1.6.2
    container_name: yuklashov-am-netology-pushgateway
    restart: always
    networks:
      - yuklashov-am-my-netology-hw
    ports:
      - "9091:9091"

  grafana:
    image: grafana/grafana:10.1.5
    container_name: yuklashov-am-netology-grafana
    restart: always
    environment:
      - GF_PATHS_CONFIG=/etc/grafana/grafana.ini
    ports:
      - "80:3000"
    volumes:
      - ./grafana.ini:/etc/grafana/grafana.ini
      - grafana_data:/var/lib/grafana
    networks:
      - yuklashov-am-my-netology-hw
    depends_on:
      - prometheus

networks:
  yuklashov-am-my-netology-hw:
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16

volumes:
  prometheus_data:
  grafana_data:

```

Для выполнения задания была отправлена пользовательская метрика в Pushgateway, настроен Data Source в Grafana и построен график.

1. Отправка метрики:
`echo "yuklashov_am 5" | curl --data-binary @- http://localhost:9091/metrics/job/netology`

2. Скриншот команды `docker ps`:
![Результат docker ps](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task12.png)

3. Скриншот метрики в Pushgateway:
![Метрика в Pushgateway](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task10.png)

4. Скриншот итогового графика в Grafana:
![График с метрикой yuklashov_am](https://github.com/yuklashov/6.4-docker-hw-yuklashov/blob/main/img/task11.png)

---
