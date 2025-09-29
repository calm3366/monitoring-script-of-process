## Задание 

Написать скрипт на bash для мониторинга процесса test в среде linux. Скрипт должен отвечать следующим требованиям:
1. Запускаться при запуске системы (предпочтительно написать юнит systemd в дополнение к скрипту)
2. Отрабатывать каждую минуту
3. Если процесс запущен, то стучаться(по https) на https://test.com/monitoring/test/api
4. Если процесс был перезапущен, писать в лог /var/log/monitoring.log (если процесс не запущен, то ничего не делать)
5. Если сервер мониторинга не доступен, так же писать в лог.


## Решение 

Запускаем виртуалку `vagrant up` и подключаемся `vagrant ssh`

#### Список активных таймеров
`systemctl list-timers | grep monitor`

#### Логи сервиса
`sudo journalctl -u monitor-test.service -n 20`
```bash
Sep 29 15:26:11 rl9-test systemd[1]: Starting Monitoring script for process "test"...
Sep 29 15:26:11 rl9-test systemd[1]: monitor-test.service: Deactivated successfully.
Sep 29 15:26:11 rl9-test systemd[1]: Finished Monitoring script for process "test".
Sep 29 15:27:30 rl9-test systemd[1]: Starting Monitoring script for process "test"...
Sep 29 15:27:30 rl9-test systemd[1]: monitor-test.service: Deactivated successfully.
Sep 29 15:27:30 rl9-test systemd[1]: Finished Monitoring script for process "test".
```

#### Лог‑файл
`tail -f /var/log/monitoring.log`
```bash
2025-09-29 15:31:40 - Сервер мониторинга недоступен
2025-09-29 15:33:19 - Процесс test был перезапущен (PID 24301 -> 24334)
2025-09-29 15:33:29 - Сервер мониторинга недоступен
2025-09-29 15:34:40 - Сервер мониторинга недоступен
```



#### Команды для создания и удаления фонового процесса
```bash
exec -a test bash -c 'while true; do sleep 60; done' &
ps -eo pid,args | grep '[t]est'
pkill -f 'test -c'
```

#### Статус процессов

`systemctl status monitor-test.timer`
```bash
● monitor-test.timer - Run monitor-test.service every minute
     Loaded: loaded (/etc/systemd/system/monitor-test.timer; enabled; preset: disabled)
     Active: active (waiting) since Mon 2025-09-29 15:26:11 MSK; 1min 37s ago
      Until: Mon 2025-09-29 15:26:11 MSK; 1min 37s ago
    Trigger: Mon 2025-09-29 15:28:30 MSK; 40s left
   Triggers: ● monitor-test.service
```

`systemctl status monitor-test.service`

```bash
● monitor-test.service - Monitoring script for process "test"
     Loaded: loaded (/etc/systemd/system/monitor-test.service; static)
     Active: activating (start) since Mon 2025-09-29 15:31:30 MSK; 14ms ago
TriggeredBy: ● monitor-test.timer
   Main PID: 24324 (monitor_test.sh)
      Tasks: 2 (limit: 12275)
     Memory: 1.4M
        CPU: 9ms
     CGroup: /system.slice/monitor-test.service
             ├─24324 /bin/bash /usr/local/bin/monitor_test.sh
             └─24328 curl -sk -o /dev/null -w %{http_code} --max-time 10 https://test.com/monitoring/test/a>
```
