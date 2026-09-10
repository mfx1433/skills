# =============================================================================
# Agent Skill 安全速查 (skill-scan)
# -----------------------------------------------------------------------------
# 用途    : 安装第三方 agent skill 之前跑一遍，把「你该亲自读的那几行」挑出来。
# 作者    : mfx1433 (AI 辅助生成)
# 平台    : Windows / PowerShell 5.1+（逻辑简单，改成 bash/python 很容易）
#
# 为什么不用现成的扫描器（如 NVIDIA SkillSpector）:
#   实测下来它们的「风险分数」不可信 —— 会把 OOXML 的 .xsd schema 报成
#   「隐藏指令」、把文档正文里的 `npx skills` 报成「未固定版本的 MCP server」、
#   把复制 os.environ 给子进程这种标准写法报成「环境变量采集」。
#   更糟的是分析失败时分数反而升高，所以分数无法横向比较。
#
#   本脚本不做评分、不下结论，只做两件事：
#     1. 盘点：这个 skill 里有没有可执行文件（危险只在可执行文件里）
#     2. 定位：把涉及网络/子进程/凭据/敏感路径/注入话术的行号挑出来
#   然后由你来读、你来判断。
#
# 核心认知:
#   提示注入是「自然语言问题」，模式匹配结构上抓不到刻意包装的注入。
#   真正有效的是「人读一遍那几百行」。本脚本的作用是让这件事花 5 分钟
#   而不是 30 分钟 —— 它缩小阅读范围，不是替代阅读。
#
# 用法:
#   .\skill-scan.ps1 <skill目录>
#   .\skill-scan.ps1 C:\Users\me\.agents\skills\some-skill
#   .\skill-scan.ps1 <skill目录> -MaxPerCategory 3    # 每类最多列几条
#
# 退出码: 恒为 0（这是审查辅助工具，不是门禁；不要把它的输出当判决）
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    # 每类风险最多显示几条命中，避免刷屏（0 = 全部显示）
    [int]$MaxPerCategory = 5
)

$ErrorActionPreference = 'Stop'

# ---- 颜色小工具（不支持彩色时自动降级）--------------------------------------
# Write-Head 自动给小节编号（① ② ③ …），这样中间跳过某节时不会缺号。
$script:SectionNo = 0
function Write-Head  {
    param($t)
    $script:SectionNo++
    $circled = [char](0x245F + $script:SectionNo)
    $title = "$circled $t"
    Write-Host ""
    Write-Host ("── " + $title + " " + ('─' * [Math]::Max(0, 68 - $title.Length))) -ForegroundColor Cyan
}
function Write-Hit   { param($t) Write-Host ("   " + $t) }
function Write-Warn2 { param($t) Write-Host ("   " + $t) -ForegroundColor Yellow }
function Write-Good  { param($t) Write-Host ("   " + $t) -ForegroundColor Green }
function Write-Dim   { param($t) Write-Host ("   " + $t) -ForegroundColor DarkGray }

# ---- 0. 校验路径 -----------------------------------------------------------
if (-not (Test-Path $Path)) { Write-Host "路径不存在: $Path" -ForegroundColor Red; exit 1 }
$skillDir = (Get-Item $Path).FullName
if (-not (Test-Path (Join-Path $skillDir 'SKILL.md'))) {
    Write-Host "警告: 这个目录里没有 SKILL.md —— 可能不是一个 skill 目录。继续扫。" -ForegroundColor Yellow
}

# ---- 文件分类规则 ----------------------------------------------------------
# 危险只可能藏在「会被执行/被解释」的文件里。纯 markdown 基本无风险
# （唯一的例外是写在 markdown 里的注入话术，所以后面单独扫文本）。
$ExecExt  = @('.py','.pyw','.sh','.bash','.zsh','.fish','.js','.mjs','.cjs','.ts',
              '.ps1','.psm1','.bat','.cmd','.vbs','.rb','.pl','.php','.lua',
              '.go','.rs','.java','.kt','.exe','.dll','.so','.dylib','.jar','.bin')
$TextExt  = @('.md','.mdx','.txt','.yaml','.yml','.json','.toml','.ini','.cfg','.xml','.csv')

$allFiles = @(Get-ChildItem $skillDir -Recurse -File -ErrorAction SilentlyContinue |
              Where-Object { $_.FullName -notmatch '\\\.git\\' })
# 许可证/声明类文件不参与指纹扫描 —— 它们天然含 URL（如 apache.org），是纯噪声。
$scanTargets = @($allFiles |
    Where-Object { $_.Name -notmatch '^(LICENSE|LICENCE|COPYING|NOTICE|AUTHORS|THIRD[-_]?PARTY)' } |
    Where-Object { ($ExecExt -contains $_.Extension.ToLower()) -or ($TextExt -contains $_.Extension.ToLower()) })
$execFiles = @($allFiles | Where-Object { $ExecExt  -contains $_.Extension.ToLower() })
$textFiles = @($allFiles | Where-Object { $TextExt  -contains $_.Extension.ToLower() })
$otherCount = $allFiles.Count - $execFiles.Count - $textFiles.Count

# =============================================================================
Write-Host ""
Write-Host ("╔══ Skill 安全速查 ══════════════════════════════════════════════") -ForegroundColor White
Write-Host ("  目录: " + $skillDir) -ForegroundColor White
Write-Host ("  时间: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor White
Write-Host ("╚════════════════════════════════════════════════════════════════") -ForegroundColor White

# ---- 1. 概览：先看有没有代码，没代码基本不用慌 -----------------------------
Write-Head "概览"
Write-Hit ("文件总数 : " + $allFiles.Count)
if ($execFiles.Count -eq 0) {
    Write-Good ("可执行文件: 0   ← 全是文本/数据，风险面很小")
} else {
    Write-Warn2 ("可执行文件: " + $execFiles.Count + "   ← 危险只可能在这里，重点看这些")
}
Write-Hit ("文本文件 : " + $textFiles.Count)
if ($otherCount -gt 0) { Write-Dim ("其他文件 : " + $otherCount) }

if ($execFiles.Count -gt 0) {
    Write-Head "可执行文件清单（按大小排序，大的先看）"
    $execFiles | Sort-Object Length -Descending | ForEach-Object {
        $lines = (Get-Content $_.FullName -ErrorAction SilentlyContinue | Measure-Object).Count
        $rel = $_.FullName.Substring($skillDir.Length).TrimStart('\')
        Write-Hit ("{0,-52} {1,6} 行  {2,8:N1} KB" -f $rel, $lines, ($_.Length/1KB))
    }
}

# ---- 3. frontmatter：看它声明了什么权限 ------------------------------------
Write-Head "SKILL.md frontmatter（它自己声明了什么）"
$skillMd = Join-Path $skillDir 'SKILL.md'
if (Test-Path $skillMd) {
    $head = Get-Content $skillMd -TotalCount 40 -Encoding UTF8
    $inFm = $false; $fmLines = @()
    foreach ($l in $head) {
        if ($l -eq '---') { if ($inFm) { break } else { $inFm = $true; continue } }
        if ($inFm) { $fmLines += $l }
    }
    $nameLine = $fmLines | Where-Object { $_ -match '^name:' } | Select-Object -First 1
    $toolLine = $fmLines | Where-Object { $_ -match 'allowed-tools|permissions' } | Select-Object -First 1
    if ($nameLine) { Write-Hit ($nameLine.Trim()) }
    if ($toolLine) {
        Write-Hit ($toolLine.Trim())
    } else {
        Write-Warn2 "未声明 allowed-tools / permissions  ← 意味着它可以调用任何工具"
    }
}

# ---- 4. 风险指纹：把该读的行号挑出来 ---------------------------------------
# 说明：这些是「线索」不是「罪证」。命中不代表有问题（比如 xlsx 正常调用
#       LibreOffice 就必然出现 subprocess），但它告诉你「这几行值得看一眼」。
$Patterns = [ordered]@{
    '网络出站（可能外发数据）' = @(
        'curl\s', 'wget\s', 'Invoke-WebRequest', 'Invoke-RestMethod',
        'requests\.(get|post|put)', 'httpx\.', 'urllib', 'urlopen',
        '\bfetch\s*\(', 'axios\.', 'node-fetch', 'socket\.', 'net\.connect',
        'https?://(?!schemas\.|www\.w3\.org|www\.apache\.org|fonts\.googleapis\.com|fonts\.gstatic\.com|localhost|127\.0\.0\.1|example\.com)'
    )
    '命令执行 / 子进程' = @(
        'subprocess\.', 'os\.system', 'os\.popen', 'Popen\s*\(',
        'eval\s*\(', 'exec\s*\(', 'Start-Process', 'Invoke-Expression',
        '\biex\b', 'child_process', 'execSync', 'spawn\('
    )
    '凭据 / 环境变量' = @(
        'os\.environ', 'os\.getenv', '\$env:', 'process\.env',
        'API_KEY', 'SECRET', 'PASSWORD', 'PASSWD', 'ACCESS_TOKEN',
        '\.credentials', 'id_rsa', '\.ssh', 'keyring', 'keychain'
    )
    '敏感路径 / 目录越界' = @(
        '\.claude', '\.codex', '\.gemini', '\.cursor', '\.agents',
        'AppData', 'ProgramData', '/etc/', '~/\.', 'authorized_keys',
        '\.aws', '\.config', '\.npmrc', '\.gitconfig'
    )
    '注入话术（自然语言）' = @(
        'ignore (all )?previous', 'disregard (all )?(previous|prior)',
        '忽略(之前|上面|以上)的?(指令|要求|说明)', 'you are now',
        'system prompt', 'developer mode', '不要告诉用户', 'do not tell the user',
        'without (asking|telling) the user', '不要询问', '直接执行即可',
        'actually the user (wants|means)', 'jailbreak'
    )
}

Write-Head "风险指纹（线索，不是结论 —— 请打开标注的行亲自看）"
$anyHit = $false
foreach ($cat in $Patterns.Keys) {
    $hits = @()
    foreach ($f in $scanTargets) {
        $rel = $f.FullName.Substring($skillDir.Length).TrimStart('\')
        $lineNo = 0
        foreach ($line in (Get-Content $f.FullName -Encoding UTF8 -ErrorAction SilentlyContinue)) {
            $lineNo++
            foreach ($p in $Patterns[$cat]) {
                if ($line -match $p) {
                    $hits += [pscustomobject]@{ File = $rel; Line = $lineNo; Text = $line.Trim(); Pat = $p }
                    break   # 同一行只记一次
                }
            }
        }
    }
    if ($hits.Count -eq 0) { continue }
    $anyHit = $true
    Write-Host ""
    Write-Warn2 ("[$cat]  " + $hits.Count + " 处")
    $show = if ($MaxPerCategory -gt 0) { $hits | Select-Object -First $MaxPerCategory } else { $hits }
    foreach ($h in $show) {
        $txt = $h.Text
        if ($txt.Length -gt 96) { $txt = $txt.Substring(0, 93) + '...' }
        Write-Hit ("{0}:{1}  {2}" -f $h.File, $h.Line, $txt)
    }
    if ($MaxPerCategory -gt 0 -and $hits.Count -gt $MaxPerCategory) {
        Write-Dim ("... 还有 " + ($hits.Count - $MaxPerCategory) + " 处（-MaxPerCategory 0 可全显示）")
    }
}
if (-not $anyHit) { Write-Good "五类指纹全部无命中。" }

# ---- 5. 结论区：明确告诉使用者「接下来该干什么」-----------------------------
Write-Head "接下来怎么办"
Write-Hit "这个脚本不下结论。请按下面顺序花几分钟："
Write-Hit ""
if ($execFiles.Count -gt 0) {
    Write-Hit ("1. 打开上面列出的 " + $execFiles.Count + " 个可执行文件，重点看标出来的行")
} else {
    Write-Hit "1. 没有可执行文件 —— 只需读 SKILL.md 的指令部分"
}
Write-Hit "2. 只问两个问题："
Write-Hit "     · 它会不会把数据/凭据发到外面去？"
Write-Hit "     · 它会不会做用户没要求的事（改配置、装东西、删文件）？"
Write-Hit "3. 看 frontmatter 有没有声明 allowed-tools；没有就意味着权限不受限"
Write-Hit ""
Write-Dim "提醒：模式匹配抓不到刻意包装的注入。真正可靠的是你读一遍。"
Write-Host ""
