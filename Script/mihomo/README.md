# Linux 系统安装 mihomo 教程

> 温馨提示：
>
> 1.认真看教程，认真看教程，认真看教程，重要事情说三次！
>
> 2.支持 tun 和 tproxy 两种模式，看你心情选择。理论上 TUN 占用高那么一丢丢！
>
> 3.本脚本支持 Debian 和 Ubuntu 系统

## TUN 模式教程 {注意：好像需要直通（PVE 虚拟机下操作）}

### 1.PVE 8.X 开启 tun

### 1.1.在 PVE 虚拟机创建 LXC 容器，创建完成以后不要 启动虚拟机

### 1.2.选择刚刚创建的 LXC 容器，鼠标依次点击，资源 - 添加 - 直通设备（Device Passthrough） 如下图

![image](https://github.com/user-attachments/assets/f185b446-cc76-4337-817b-0139f688445f)

### 1.3.在里面填入下面代码 效果如下

```bash
/dev/net/tun
```

![image](https://github.com/user-attachments/assets/7ad8bb51-d593-439a-9fdf-2649d3f44e82)

### 1.3.如果你是 PVE 7.X 开启 TUN ，如下操作

#### 1.3.1.在 PVE 里面，依次 节点 - Shell 里面执行，如下图位置

![image](https://github.com/user-attachments/assets/ba043dca-b12b-4b92-963c-4f809305ec11)

#### 1.3.2.下面的 LXCID 修改成你的实际 ID (比如，我是 100 就改成 nano /etc/pve/lxc/100.conf)

```bash
nano /etc/pve/lxc/LXCID.conf
```

#### 1.3.3.粘贴下面代码，然后用 Ctrl+X 保存，输入 Y 确认

```bash
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

## TProxy 模式 不需要其他额外操作，下面步骤都一样

### 2.启动容器，使用下面命令，一键换源

```bash
cat << EOF > /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
```

### 3.因为 PVE 虚拟机容器，默认是没有开启远程 root 登录，如需开启使用下面命令

```bash
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && systemctl restart sshd
```

### 4.更新系统

```bash
apt update && apt full-upgrade -y
```

### 5.安装必须插件

```bash
apt-get install -y curl git wget nano
```

### 前期工作准备完毕，下面使用一键脚本安装 mihomo

#### 已经加入自动识别网络环境功能，确保你的设备能正常联网就行

```bash
wget -O install.sh --no-check-certificate https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/mihomo/install.sh && chmod +x install.sh && ./install.sh
```

#### CND 加速版，主要是下载脚本用的，脚本里面的功能和上面一样（有时候 CND 会失效，等待修复就好）

```bash
wget -O install.sh --no-check-certificate https://github.boki.moe/https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/mihomo/install.sh && chmod +x install.sh && ./install.sh
```

## 手动检查、排错

### 使用以下命令，检查 mihomo 的运行状况

```bash
systemctl status mihomo
```

### 使用以下命令，检查 mihomo 的运行日志

```bash
journalctl -u mihomo -o cat -e
```

### Beta 版本（我自己测试用的，不建议安装此版本）

```bash
wget -O install.sh --no-check-certificate https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/Beta/mihomo/install.sh && chmod +x install.sh && ./install.sh
```

## Linux 系统设置上海时区

### 支持 Debian Ubuntu alpine 系统

```bash
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" | tee /etc/timezone > /dev/null
```
