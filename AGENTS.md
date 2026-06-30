# Tokyo Night (tokyonight.nvim) — 项目知识文档

## 项目概述

东京夜间 Neovim 主题（Tokyo Night），由 Folke Lemaitre 维护，是 VS Code TokyoNight 主题的 Neovim 移植版。支持五种风格（Storm、Moon、Night、Day、Monokai），为 70+ Neovim 插件提供高亮，并为 48+ 外部应用生成主题文件。许可证：**Apache 2.0**（`hsluv.lua` 额外带有 MIT 许可）。

---

## 五种色彩风格

| 风格 | 背景色 | 说明 |
|------|--------|------|
| **Storm** | `#24283b` | 原始暗色变体 |
| **Moon** | `#222436` | **默认风格**，偏蓝暗色 |
| **Night** | `#1a1b26` | 最深暗色（深拷贝 storm，覆盖 bg） |
| **Day** | 浅色 | 亮色变体，通过反转暗色调色板生成 |
| **Monokai** | `#272822` | 模仿 VS Code 内置 Monokai 的暗色变体 |

- `day.lua` 是一个**函数**而非表，调用 `Util.invert()` 后应用 `day_brightness` 调节。
- 默认风格通过 `vim.o.background` 自动选择：dark → moon，light → day。

---

## 目录结构

```
tokyonight.nvim/
├── colors/                          # Neovim colorscheme 入口
│   ├── tokyonight.lua               # 默认入口，自动选择风格
│   ├── tokyonight-day.lua
│   ├── tokyonight-moon.lua
│   ├── tokyonight-night.lua
│   └── tokyonight-storm.lua
├── lua/
│   ├── tokyonight/                  # 核心库
│   │   ├── init.lua                 # 主入口：require("tokyonight").load()
│   │   ├── config.lua               # 默认配置 & setup()
│   │   ├── theme.lua                # 应用高亮组 & 终端颜色
│   │   ├── util.lua                 # 颜色工具（blend, darken, lighten, invert, brighten, template, cache）
│   │   ├── hsluv.lua                # HSLuv 色彩空间转换（MIT）
│   │   ├── types.lua                # LuaLS 类型注解
│   │   ├── docs.lua                 # 自动生成 README 表格
│   │   ├── colors/                  # 各风格调色板定义
│   │   │   ├── init.lua             # 调色板编排器
│   │   │   ├── storm.lua
│   │   │   ├── moon.lua
│   │   │   ├── night.lua
│   │   │   └── day.lua
│   │   ├── groups/                  # 高亮组定义（每插件一文件）
│   │   │   ├── init.lua             # 插件注册表、加载编排、缓存
│   │   │   ├── base.lua             # 核心 Neovim 高亮组
│   │   │   ├── treesitter.lua       # Treesitter @-capture 高亮
│   │   │   ├── semantic_tokens.lua  # LSP 语义令牌高亮
│   │   │   ├── kinds.lua            # LSP 补全种类高亮
│   │   │   └── {plugin}.lua         # 各插件高亮（70+ 文件）
│   │   └── extra/                   # 外部应用主题模板生成器
│   │       ├── init.lua             # 编排器：遍历所有 extra × 4 风格
│   │       └── {app}.lua            # 单个应用模板（48+ 文件）
│   ├── lualine/
│   │   └── themes/
│   │       ├── tokyonight.lua
│   │       └── _tokyonight.lua      # Lualine 主题生成器
│   ├── lightline/
│   │   └── colorscheme/
│   │       └── tokyonight.lua
│   └── barbecue/
│       └── theme/
│           └── tokyonight.lua
├── extras/                          # 生成的外部应用主题文件（48+ 目录）
├── autoload/lightline/colorscheme/  # Lightline Vimscript 桥接
├── doc/
│   └── tokyonight.nvim.txt          # Vim 帮助文档（自动生成）
├── tests/
│   ├── minit.lua                    # 测试引导（lazy.nvim/minit）
│   ├── colorscheme_spec.lua         # 测试 colorscheme 加载
│   └── groups_spec.lua              # 测试插件组有效性
└── scripts/
    ├── build                        # 生成 extras：nvim -l lua/tokyonight/extra/init.lua
    ├── test                         # 运行测试：nvim -l tests/minit.lua --minitest
    └── docs                         # 更新文档：nvim -l lua/tokyonight/docs.lua
```

---

## 核心执行流程

```
init.lua → config.lua → colors/init.lua（加载调色板）→ groups/init.lua（加载高亮组）→ theme.lua（应用）
```

1. **入口**：`colors/tokyonight.lua` 调用 `require("tokyonight").load()`
2. **配置**：`config.lua` 提供默认配置和 `setup()`，版本当前 **4.14.1**
3. **调色板**：`colors/init.lua` 加载对应风格调色板，计算派生颜色（diff、terminal、rainbow、sidebar/float 背景等），触发 `on_colors()` 钩子
4. **高亮组**：`groups/init.lua` 按需加载各插件高亮文件，支持缓存
5. **应用**：`theme.lua` 通过 `nvim_set_hl()` 设置高亮，配置终端颜色

---

## 插件组系统

### 文件规范

- 每个插件独立文件：`groups/{插件名}.lua`（连字符命名，匹配插件仓库名）
- 标准导出接口：
  ```lua
  M.url = "https://github.com/..."  -- 插件 GitHub URL
  M.get = function(colors, opts)    -- 返回高亮组表
  end
  ```
- 插件自动检测：已安装的 lazy 插件自动启用对应高亮组

### 高亮组约定

- 使用 `-- stylua: ignore` 注释对齐高亮表
- 新文件引入顺序：`.lazy.lua` 中需要时引入测试

### 支持的插件

base（核心）、treesitter、semantic_tokens、kinds、aerial、ale、alpha、barbar、blink（blink.cmp）、bufferline、cmp（nvim-cmp）、codeium、copilot、dap、dashboard、flash、fzf（fzf-lua）、gitgutter、gitsigns、glyph-palette、grug-far、headlines、hop、illuminate、indent-blankline、indentmini、lazy、leap、lspsaga、mini.*（21 个模块）、navic、neo-tree、neogit、neotest、noice、notify、nvim-tree、octo、rainbow、render-markdown、scrollbar、sidekick、snacks、sneak、supermaven、telescope、treesitter-context、trouble、vimwiki、which-key、yanky

---

## 配置选项

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `style` | `"moon"` | 色彩风格：storm / moon / night / day |
| `light_style` | `"day"` | 浅色背景时使用 |
| `transparent` | `false` | 禁用背景色 |
| `terminal_colors` | `true` | 配置终端颜色 |
| `styles.comments` | `{ italic = true }` | 注释样式 |
| `styles.keywords` | `{ italic = true }` | 关键字样式 |
| `styles.sidebars` | `"dark"` | 侧边栏样式：dark / transparent / normal |
| `styles.floats` | `"dark"` | 浮动窗口样式：dark / transparent / normal |
| `day_brightness` | `0.3` | Day 风格亮度（0-1） |
| `dim_inactive` | `false` | 暗淡非活动窗口 |
| `lualine_bold` | `false` | Lualine 粗体 |
| `on_colors` | `function` | 颜色覆盖钩子 |
| `on_highlights` | `function` | 高亮覆盖钩子 |
| `cache` | `true` | 缓存计算后的高亮 |
| `plugins.all` | `true` | 启用所有插件 |
| `plugins.auto` | `true` | 根据已安装 lazy 插件自动启用 |

---

## Extras 外部应用主题系统

### 模板文件位置

- 模板生成器：`lua/tokyonight/extra/{应用名}.lua`
- 导出函数：`M.generate(colors)` → 返回字符串
- 使用 `util.template()` 进行 `${color_variable}` 替换

### 生成产物

- 目录：`extras/{应用名}/tokyonight_{风格}.{扩展名}`
- 运行时：`scripts/build` 调用 `nvim -l lua/tokyonight/extra/init.lua`，遍历所有 extra × 4 风格生成文件

### 模板中可用变量

- `${_style_name}` — 如 "Tokyo Night Storm"
- `${_name}` — 如 "tokyonight_storm"
- `${_upstream_url}` — GitHub raw URL
- `${_style}` — 如 "storm"
- 所有调色板键值（如 `${bg}`, `${fg}`, `${blue}`, `${terminal.black}` 等）

### 当前支持的应用（48+）

aerc、aider、alacritty、btop、delta、discord、dunst、eza、fish、fish_themes、foot、fuzzel、fzf、gemini_cli、ghostty、gitui、gnome_terminal、helix、ish、iterm、kitty、konsole、lazygit、lua（测试用）、opencode、pi、prism、process_compose、qterminal、slack、spotify_player、sublime、tailwindv4、terminator、termux、tilix、tmux、vim、vimium、vivaldi、wezterm、windows_terminal、xfceterm、xresources、yazi、zathura、zellij

---

## 工具函数（util.lua）

- `blend(fg, bg, alpha)` — 前景与背景混合
- `darken(hex, amount, bg)` — 颜色加深
- `lighten(hex, amount, fg)` — 颜色减淡
- `invert(hex)` — 反转颜色（使用 HSLuv）
- `brighten(hex, amount)` — 亮度调节（使用 HSLuv）
- `template(str, data)` — `Hello ${name}` 模板替换
- 缓存系统：`cache_file()` / `load_cache()` / `write_cache()`，存储于 `stdpath("cache")/tokyonight`

---

## Day 调色板特殊行为

`colors/day.lua` 是**函数**而非表，内部工作原理：
1. 从其他暗色风格获取调色板（通过 `colors/init.lua` 传入）
2. 调用 `Util.invert()` 反转所有颜色
3. 应用 `config.day_brightness` 调节亮度
4. 硬编码覆盖部分核心颜色（bg、fg 等）确保可读性

---

## 测试

- 框架：lazy.nvim/minit（非 busted）
- 运行：`scripts/test` 即 `nvim -l tests/minit.lua --minitest`
- 测试文件：
  - `colorscheme_spec.lua` — 验证 `:colorscheme tokyonight` 正确响应 `vim.o.background`
  - `groups_spec.lua` — 验证所有插件组有 URL、有正确的插件映射、配置系统正常工作

---

## 代码风格

| 规则 | 值 |
|------|-----|
| 缩进 | 2 空格 |
| 行宽 | StyLua 120 列 / LuaFormatter 100 列 |
| 格式化工具 | StyLua（主）/ LuaFormatter（旧） |
| Linter | Selene（vim 标准库，允许混合表） |
| Markdown | 禁用 MD013（行长度）和 MD033（内联 HTML） |

---

## CI / 自动化

- **release-please**：语义化版本自动发布
- **ci.yml**：push/PR 触发，复用 folke/github 共享 action
- **labeler.yml**：自动为 PR 打标签（core / extras / groups / colors / base）
- **pr.yml**：验证 PR 标题格式
- **stale.yml**：自动关闭陈旧 issue/PR
- **update.yml**：每小时自动更新仓库

---

## Monokai 自定义主题

新增于 **自定义扩展**（非上游原始主题），位于 `lua/tokyonight/colors/monokai.lua`。

### 配色原则

- 背景色 `#272822`（VS Code Monokai 标志性暗橄榄黑）
- 前景色 `#F8F8F2`（亮白）
- 注释 `#75715E`（橄榄灰）
- 关键字/语句 `#F92672`（标志性品红/粉红）
- 字符串 `#A6E22E`（绿色）
- 函数名 `#66D9EF`（青色）
- 常亮/调试 `#FD971F`（橙色）
- 数字/类型（treesitter @keyword）`#AE81FF`（紫色）
- 参数/待办 `#E6DB74`（黄色）

### 设计取舍（与 VS Code 原生 Monokai 的差异）

由于 tokyonight 调色板键名固定，部分 Monokai 语义无法完美映射：

| tokyonight 键 | 实际使用 | 与原生 Monokai 的差异 |
|---------------|----------|----------------------|
| `cyan` | 终端青色、Keyword/PreProc 基组 | 原生 Monokai 中 keywords 为粉红，此处青色是妥协 |
| `magenta` | Identifier、Statement | 原生 Monokai 中 identifiers 为白色，此处粉红 |
| `purple` | treesitter @keyword | 与 magenta 同色（粉红），无独立紫色 |
| `blue1` | Type 基组 | 原生 Monokai 中 type 为紫色，此处青色 |

### 使用方式

`:colorscheme tokyonight-monokai`

或通过 `require("tokyonight").load({ style = "monokai" })`

配置文件支持 `style = "monokai"`

---

## 重要设计决策

1. **不依赖外部依赖**：核心库纯 Lua，零外部运行时依赖
2. **缓存优先**：高亮组计算结果缓存到磁盘，加速后续加载
3. **插件自动检测**：基于 lazy.nvim 的插件列表自动启用对应高亮组
4. **`lazy.nvim` 开发环境**：`.lazy.lua` 配置提供 mini.hipatterns 颜色预览
5. **不产生运行时文件**：extras 和 README 均为构建时生成
