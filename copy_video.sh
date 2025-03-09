#!/bin/bash
# 目标目录（请确保该目录已存在，否则请先 mkdir -p "$dest"）
dest="/Users/jingwang/WORKSPACE/ardiffusion.github.io/static/videos/"

# 视频文件所在根目录
src="/Users/jingwang/Documents/Memory Diffusion/video_demo/"

# 函数：归一化文件名（小写、将非字母数字替换为下划线，去掉首尾下划线）
normalize() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/_/g' -e 's/_\+/_/g' -e 's/^_//' -e 's/_$//'
}

# 遍历所有 .mp4 文件（注意目录中可能包含空格，因此使用双引号）
find "$src" -type f -name "*.mp4" | while IFS= read -r filepath; do
    newname=""
    
    # 根据不同目录作分类处理
    if [[ "$filepath" == *"error_accum_fifo"* ]]; then
        # fifo 文件：提示文本在 fifo.mp4 文件的祖先目录中（如 …/error_accum_fifo/<提示文本>/200frames/fifo.mp4）
        prefix="fifo"
        # 取出提示文本所在目录名称
        prompt=$(basename "$(dirname "$(dirname "$filepath")")")
        # 如果目录名中包含双引号，则去除它
        prompt="${prompt//\"/}"
        prompt_norm=$(normalize "$prompt")
        newname="${prefix}_${prompt_norm}.mp4"
        
    elif [[ "$filepath" == *"error_accum_outpaint"* ]]; then
        # outpaint 文件：同 fifo 类似，不过下一级目录中可能有 “origin” 与 “outpainting”
        prefix="outpaint"
        prompt=$(basename "$(dirname "$(dirname "$filepath")")")
        prompt="${prompt//\"/}"
        prompt_norm=$(normalize "$prompt")
        if [[ "$filepath" == *"outpainting.mp4" ]]; then
            newname="${prefix}_${prompt_norm}.mp4"
        else
            newname="${prefix}_origin_${prompt_norm}.mp4"
        fi
        
    elif [[ "$filepath" == *"error_accum_streamt2v"* ]]; then
        # streamt2v 文件：这里直接取文件原名再归一化
        prefix="streamt2v"
        base=$(basename "$filepath")
        base_noext="${base%.*}"
        norm_base=$(normalize "$base_noext")
        newname="${prefix}_${norm_base}.mp4"
        
    elif [[ "$filepath" == *"dmlab_recall"* ]]; then
        # dmlab_recall 下可能有 fail 与 success 子目录
        if [[ "$filepath" == *"/fail/"* ]]; then
            prefix="dmlab_fail"
        else
            prefix="dmlab_success"
        fi
        base=$(basename "$filepath")
        base_noext="${base%.*}"
        norm_base=$(normalize "$base_noext")
        newname="${prefix}_${norm_base}.mp4"
        
    elif [[ "$filepath" == *"minecraft_recall"* ]]; then
        if [[ "$filepath" == *"/fail/"* ]]; then
            prefix="minecraft_fail"
        else
            prefix="minecraft_success"
        fi
        base=$(basename "$filepath")
        base_noext="${base%.*}"
        norm_base=$(normalize "$base_noext")
        newname="${prefix}_${norm_base}.mp4"
        
    elif [[ "$filepath" == *"oasis_forget"* ]]; then
        prefix="oasis"
        base=$(basename "$filepath")
        base_noext="${base%.*}"
        norm_base=$(normalize "$base_noext")
        newname="${prefix}_${norm_base}.mp4"
        
    else
        # 其他情况：直接使用原文件名归一化后作为新名
        base=$(basename "$filepath")
        base_noext="${base%.*}"
        norm_base=$(normalize "$base_noext")
        newname="${norm_base}.mp4"
    fi

    echo "移动 '$filepath' 到 '$dest$newname'"
    cp -rv "$filepath" "$dest$newname"
done