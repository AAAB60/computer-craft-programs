<a href=#en>English</a> <a href=#zh>中文</a>

<div id="en"></div>

## Introduction

A pixel-based UTF-8 printing program  
![image1](https://github.com/user-attachments/assets/82b2e002-77cf-4805-a326-62ae01ecabc2)


> $\color{red} \bf Note:$  
> The CC compiler reads UTF-8 characters as '?',  
> `print("Hello World")` has the same effect as `print("????")`.  
> To fix this, read files in `"rb"` mode for proper input handling.

## How to Create Fonts
- Font files should return a table where keys are UTF-8 code points, and values are corresponding character bitmaps.
- Each bitmap is a table of equal-length strings representing a 2x3 pixel grid defined by Computer Craft. To use the bottom-right pixel, subtract 128 from the char code to invert `backgroundColor` and `textColor`.
- A single font file may contain bitmaps of different sizes, but it **must** include a bitmap for 'H' (ASCII:72) to indicate the maximum height of the font.
- The final output uses the maximum bitmap height in the FontFamily as the baseline for bottom-aligned text.
- The FontFamily **must** include a '-' (ASCII:45) bitmap for potential word splitting during auto-wrapping.

## Technical Details

- `require` a fusion-pixel-12px font consumes approximately **10.5MB** of memory.
- `require` a fusion-pixel-8px font consumes approximately **6MB** of memory.
- 8px characters occupy 3 rows vertically, while 12px characters occupy 4 rows.
- Fonts are sourced from <a href="https://github.com/TakWolf/fusion-pixel-font/releases">fusion-pixel-font</a>.

<div id="zh"></div>

## 介绍

一个基于像素打印的utf8打印程序
![image1](https://github.com/user-attachments/assets/82b2e002-77cf-4805-a326-62ae01ecabc2)

> $\color{red} \bf 注意:$ 
> CC 编译器会把utf8字符读作 '?', 
> `print("你好世界")` 与 `print("????")` 的效果相同, 可以`"rb"`模式读取文件以设置输入


## 如何制作Font
- 字体文件返回一个table，键值为utf8编码，值为和对应字体的bitmap。
- bitmap为一个包含等长string的table，string中的char属于computer craft定义的2*3像素点阵（如需使用右下角像素，将char的码值减128表示反转backgroundColor 和 textColor）
- 单个字体文件中可以有不同尺寸的bitmap，且**需要**有'H'(ascII:72)的bitmap表示该文件中最大bitmap高度
- 会以FontFamily出现的最大bitmap高度为基准，最终输出下对齐的文本
- FontFamily中**需要**'-'(ascII:45)的bitmap以供自动换行时可能的切断单词使用

## 技术细节

- `require`一个fusion-pixel-12px字体，大约消耗**10.5MB**内存 
- `require`一个fusion-pixel-8px字体，大约消耗**6MB**内存
- 8px字符实际占用3格高的字符数, 12px字符实际占用4格高
- 字体来自 <a href="https://github.com/TakWolf/fusion-pixel-font/releases"> fusion-pixel-font </a>
