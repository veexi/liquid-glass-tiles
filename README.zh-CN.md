# 液态玻璃方格 · Liquid Glass Tiles

一个 **KDE Plasma 6 原生壁纸插件**：圆角玻璃方格铺满壁纸，鼠标附近渐变显现，带有磨砂模糊、曲面折射和可调透明度。默认立即跟随鼠标，不额外加移动延迟。

**原始视觉创意：[Gábor Molnár / DesignGabor](https://avely.me/designgabor)。**
经原设计师同意分享。[X 主页](https://x.com/DesignGabor) · [原始交互作品](https://my.spline.design/glassmorphcursortracking-2ef6d3790000fd1a4f81c92fb3ff5bf5/) · [完整致谢](CREDITS.md)

![效果预览](docs/preview.png)

## 安装

下载安装包 `liquid-glass-tiles-0.2.0.zip`，然后运行：

```sh
kpackagetool6 --type Plasma/Wallpaper --install liquid-glass-tiles-0.2.0.zip
```

桌面右键 → **配置桌面和壁纸** → 壁纸类型选择 **液态玻璃方格** → 应用。
内置原创演示背景，也可以直接选择自己的本地图片。
若壁纸设置提供“获取新插件 → 从文件安装”，也可在那里选择同一个 ZIP。

它是壁纸插件，不是桌面小部件，也不是全局主题。运行只需要已有的 Plasma 6、Qt Quick / Kirigami 和支持着色器的图形后端，不需要 Python、浏览器、Spline 账号、联网或后台服务。

## 调整效果

- **玻璃显现强度**：0 为原壁纸，100 为鼠标附近完整的玻璃效果。
- **方块大小、鼠标范围**：决定网格大小和显现区域。
- **折射、磨砂**：分别控制图片扭曲和真正的两步高斯模糊。
- **远处方块显现强度**：设为 0，远离鼠标后完全恢复原图。
- **跟随延迟**：建议保持 0；更大的值会主动加入缓动。

设置页提供中英文界面，并保留原设计师署名和链接。

## 更新与卸载

```sh
kpackagetool6 --type Plasma/Wallpaper --upgrade liquid-glass-tiles-0.2.0.zip
```

Plasma 可能缓存已加载的代码。更新后若仍表现为旧版，可保存工作后注销、重新登录。

卸载前先选择其他壁纸类型，然后运行：

```sh
kpackagetool6 --type Plasma/Wallpaper --remove io.github.veexiwang.liquidglasstiles
```

社区版与早期开发版本 `local.liquidglass` 使用不同的 ID，可并存；不会覆盖旧版或自动迁移旧版配置。

## 验证与限制

桌面鼠标接入在 Plasma 6.7.3、Qt 6.11.1、Wayland、Intel Arc B390 / Mesa 26.1.6 上验证。最终材质在 Qt 6.10.2 独立预览中获得使用者确认。
目标为 Plasma 6，着色器使用较旧的 Qt 6.4 兼容容器格式；其他版本和显卡仍欢迎反馈。

效果只响应桌面窗口中的鼠标，不穿过应用窗口追踪，也不会改变应用内容。
多屏、混合缩放、X11 和长期耗电尚未完成专门验证。
静止测试一秒内没有额外重绘，这不等于已经测过电池续航。

构建、测试与源码说明见 [English README](README.md)。

实现和原创演示背景采用 [MIT 许可证](LICENSE)。原作的 Spline 场景、模型、运行库及素材未包含在本项目中。
