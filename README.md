# omarchy-auto-theme

按日出日落自动切换 Omarchy 明暗主题。

白天使用浅色主题, 夜晚使用深色主题。基于 NOAA 太阳算法计算每天的真实日出日落时间,
由 systemd 用户定时器、hypridle 钩子与日出日落边界定时触发, 仅在明暗不一致时切换主题。

## 安装

### 方式一：Omarchy 插件（推荐，无需 root）

```bash
omarchy plugin add https://github.com/jfdnet/omarchy-auto-theme.git --enable
```

插件会接管 systemd 用户单元（`~/.config/systemd/user/omarchy-auto-theme.{service,timer}`），
启用即生效，禁用插件时自动停用并移除单元文件。若此前装过独立包（`/usr/local/bin`），
可以保留它继续给 hypridle 钩子用，也可以卸载（钩子找不到二进制时会无害跳过，边界切换由定时器负责）。

### 方式二：独立包（AUR 风格打包）

```bash
makepkg -si        # 装到 /usr/local/bin + systemd 用户单元
```

## 触发时机

| 时机 | 机制 |
|------|------|
| 登录进入桌面 | systemd 用户定时器 (`OnBootSec=1min`) |
| 屏幕解锁 | hypridle `on_unlock_cmd` |
| 唤醒(休眠恢复) | hypridle `after_sleep_cmd` |
| 日出/日落边界 | 脚本自安排的 systemd 临时定时器 (`systemd-run --on-calendar`) |

脚本每次运行都会在下一个日出/日落边界安排一次强制切换, 即使长时间不锁屏、不休眠, 主题也会在日出日落时准时刷新。

解锁与唤醒依赖 hypridle 钩子, 在 `~/.config/hypr/hypridle.conf` 的 `general` 段加入:

```ini
general {
    on_unlock_cmd = /usr/local/bin/omarchy-auto-theme
    after_sleep_cmd = hyprctl dispatch 'hl.dsp.dpms("on")'; /usr/local/bin/omarchy-auto-theme
}
```

## 特性

- 🌅 按真实日出/日落时间切换(每天不同, 自动计算)
- 🎨 白天/夜晚主题可配置(默认 Milkmatcha Light / City 783)
- ✍️ 手动更改主题会被采纳为新默认 (light/dark 分别记忆)
- 📍 多种定位方式: 配置坐标 > 缓存 > geoclue > 固定时间回退
- 🔁 幂等切换(仅明暗不一致时切换)
- 🖱️ 光标主题可跟随明暗切换(可选, 默认关闭)
- 📝 完整日志(`~/.local/state/omarchy-auto-theme.log`)

## 安装

### Arch (AUR)

```bash
yay -S omarchy-auto-theme
systemctl --user enable --now omarchy-auto-theme.timer
```

### 手动安装

```bash
make install          # 安装到 /usr/local
systemctl --user daemon-reload
systemctl --user enable --now omarchy-auto-theme.timer
```

## 配置

配置文件: `~/.config/omarchy-auto-theme.json`(可选, 示例见 `omarchy-auto-theme.json.example`):

```json
{
  "lat": 39.9042,             // 手动指定纬度 (可选, 推荐)
  "lon": 116.4074,            // 手动指定经度 (可选, 推荐)
  "light_theme": "Milkmatcha Light",
  "dark_theme": "City 783",
  "light_cursor": "",            // 可选: 白天光标主题(需已安装; 留空不启用)
  "dark_cursor": "",             // 可选: 夜晚光标主题
  "cursor_size": 24              // 可选: 光标尺寸
```

手动更改主题时, 脚本会自动把你选择的主题写入该配置文件, 作为新的 `light_theme` 或 `dark_theme` 默认。

### 定位方式

| 优先级 | 方式 | 说明 |
|--------|------|------|
| 1 | 配置文件 `lat`/`lon` | 最准确, 推荐手动设置 |
| 2 | 缓存坐标 | 首次定位后自动缓存 |
| 3 | geoclue | 系统定位服务(需安装 geoclue, 首次请求弹窗点 Allow) |
| 4 | 固定时间 08:00/20:00 | 定位失败时兜底 |

强制重新定位:

```bash
omarchy-auto-theme --locate
```

### geoclue 授权 (可选)

若使用 geoclue 自动定位, 需要授权 agent。最简单的方式是启用 geoclue 自带的 demo agent
(首次定位会弹一次"允许访问位置"窗口, 点 Allow 即可):

```bash
# 在 ~/.config/hypr/autostart.lua 中加入 (Omarchy):
#   o.launch_on_start("geoclue-demo-agent")
```

## 依赖

- `python` (>=3.10)
- `python-dbus`、`python-gobject`(geoclue 定位需要; 手动坐标不需要)
- `omarchy`(主题切换命令)
- `geoclue`(可选, 自动定位需要)

## 文件

```
/usr/local/bin/omarchy-auto-theme          # 主脚本
/usr/local/lib/systemd/user/omarchy-auto-theme.{service,timer}
/etc/omarchy-auto-theme.json.example       # 配置示例
```

日志与坐标缓存: `~/.local/state/omarchy-auto-theme.log` / `-location.json`

## License

MIT
