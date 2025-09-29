ssh_pub_path = File.expand_path("~/.ssh/id_rsa.pub")

Vagrant.configure("2") do |config|
  config.vm.box = "bento/rockylinux-9"
  # Указываем версию и отключаем проверку обновлений
  config.vm.box_version = ">= 1.0.0"
  config.vm.box_check_update = false
  # отключаем shared folders
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # Настройки машины
  config.vm.hostname = "rl9-test"
  config.vm.network "private_network", ip: "10.10.10.10"
  config.vm.provider "parallels" do |prl|
    prl.memory = 2048
    prl.cpus = 2
  end
  # Устанавливаем пакеты и обновляем 
  config.vm.provision "shell", inline: <<-SHELL
    sudo dnf -y update
    sudo dnf -y install gcc make curl policycoreutils
  SHELL
  # Устанавливаем часовой пояс
  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    timedatectl set-timezone Europe/Moscow
  SHELL
  # Передаём файл публичного ключа внутрь VM
  config.vm.provision "file", source: ssh_pub_path, destination: "/tmp/id_rsa.pub"
  # Добавляем SSH ключ через provisioning
  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /root/.ssh
    cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
  SHELL

  # Копируем скрипт мониторинга и systemd unit/timer внутрь VM
  config.vm.provision "file", source: "monitor_test.sh", destination: "/tmp/monitor_test.sh"
  config.vm.provision "file", source: "monitor-test.service", destination: "/tmp/monitor-test.service"
  config.vm.provision "file", source: "monitor-test.timer", destination: "/tmp/monitor-test.timer"

  # Устанавливаем скрипт и активируем таймер, обновляем контекст selinux
  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    cp /tmp/monitor_test.sh /usr/local/bin/monitor_test.sh
    chmod +x /usr/local/bin/monitor_test.sh
    sudo restorecon -v /usr/local/bin/monitor_test.sh

    cp /tmp/monitor-test.service /etc/systemd/system/monitor-test.service
    cp /tmp/monitor-test.timer /etc/systemd/system/monitor-test.timer

    chown root:root /etc/systemd/system/monitor-test.*
    chmod 644 /etc/systemd/system/monitor-test.*

    # создаём лог-файл с правами
    touch /var/log/monitoring.log
    chmod 644 /var/log/monitoring.log

    systemctl daemon-reload
    systemctl enable --now monitor-test.timer
  SHELL
end