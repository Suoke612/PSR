#!/bin/bash
# PSR Workflow 一键安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/Suoke612/PSR/main/install.sh | bash

set -e

REPO_URL="https://github.com/Suoke612/PSR.git"
TEMP_DIR=$(mktemp -d)
LANG="${PSR_LANG:-en}"  # 默认英文，设置 PSR_LANG=zh 使用中文版

echo "🚀 正在安装 PSR Workflow..."

# 克隆仓库到临时目录
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo "❌ Git 克隆失败，请检查网络连接"
    exit 1
}

# 复制 .planning/ 到当前目录
if [ "$LANG" = "zh" ] || [ "$LANG" = "ZH" ]; then
    SOURCE_DIR="$TEMP_DIR/ZH/.planning"
    echo "📦 使用中文版工作流"
else
    SOURCE_DIR="$TEMP_DIR/.planning"
    echo "📦 使用英文版工作流"
fi

if [ -d ".planning" ]; then
    echo "⚠️  检测到当前目录已有 .planning/，是否覆盖？(y/N)"
    read -r confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "✋ 已取消安装"
        rm -rf "$TEMP_DIR"
        exit 0
    fi
    rm -rf .planning
fi

cp -r "$SOURCE_DIR" .
rm -rf "$TEMP_DIR"

echo ""
echo "✅ PSR Workflow 安装完成！"
echo ""
echo "📁 工作流文件已复制到: $(pwd)/.planning/"
echo ""

if [ "$LANG" = "zh" ] || [ "$LANG" = "ZH" ]; then
    echo "💡 下一步：对 AI 说："
    echo "   读取 .planning/WORKFLOW.md，帮我初始化 PSR 工作流"
else
    echo "💡 Next step: Tell your AI agent:"
    echo "   Read .planning/WORKFLOW.md and help me initialize the PSR workflow"
fi

echo ""
