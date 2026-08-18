# omarchy-auto-theme

按日出日落自动切换 Omarchy 明暗主题。

白天使用浅色主题, 夜晚使用深色主题。基于 NOAA 太阳算法计算每天的真实日出日落时间,
由 systemd 用户定时器每 10 分钟检查一次(仅在明暗变化时切换, 每天最多 2 次)。

## 特性

- 🌅 按真实日出/日落时间切换(每天不同, 自动计算)
- 🎨 白天/夜晚主题可配置(默认 Catppuccin Latte / Tokyo Night)
- 📍 多种定位方式: 手动坐标 > geoclue 系统定位 > IP 回退
- 🔁 幂等切换(状态文件防抖, 不重复触发)
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
  "fallback_lat": 22.3185,    // geoclue 不可用时的回退坐标
  "fallback_lon": 114.1755,
  "light_theme": "Catppuccin Latte",
  "dark_theme": "Tokyo Night"
}
```

### 定位方式

| 优先级 | 方式 | 说明 |
|--------|------|------|
| 1 | 配置文件 `lat`/`lon` | 最准确, 推荐手动设置 |
| 2 | 缓存坐标 | 首次定位后自动缓存 |
| 3 | geoclue | 系统定位服务(需安装 geoclue, 首次请求弹窗点 Allow) |
| 4 | 内置回退坐标 | 兜底 |

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

日志与状态: `~/.local/state/omarchy-auto-theme.*`

## License

MIT
