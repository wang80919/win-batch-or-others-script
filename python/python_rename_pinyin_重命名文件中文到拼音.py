import os
import re
from pypinyin import pinyin, Style

def convert_name(filename):
    """
    将文件名中的中文转换为拼音，保留英文和数字，并处理空格格式。
    规则：
    1. 中文 -> 拼音 (首字母大写，如 Ni Hao)
    2. 每个汉字拼音之间用空格隔开
    3. 英文/数字保持不变
    4. 中文与英文/数字之间自动添加空格
    """
    # 分离文件名和扩展名
    name, ext = os.path.splitext(filename)
    
    if not name:
        return filename

    # 使用正则表达式将字符串分割为：连续中文块 和 连续非中文块
    # [\u4e00-\u9fff]+ 匹配连续中文
    # [^\u4e00-\u9fff]+ 匹配连续非中文（英文、数字、符号等）
    segments = re.findall(r'[\u4e00-\u9fff]+|[^\u4e00-\u9fff]+', name)
    
    processed_parts = []
    
    for segment in segments:
        if re.match(r'^[\u4e00-\u9fff]+$', segment):
            # --- 处理中文段 ---
            # 使用 pypinyin 转换
            # style=Style.NORMAL: 不带声调
            # heteronym=False: 默认根据语境选择最可能的读音（多音字处理）
            py_list = pinyin(segment, style=Style.NORMAL, heteronym=False)
            
            # 将每个字的拼音首字母大写，其余小写
            capitalized_pys = [py[0].capitalize() for py in py_list]
            
            # 汉字之间用空格连接
            processed_parts.append(" ".join(capitalized_pys))
        else:
            # --- 处理非中文段（英文、数字、符号） ---
            # 去除首尾空白，防止后续拼接出现多余空格
            # 注意：这里保留段内部的空格（如果有的话），但通常文件名不含空格
            cleaned_segment = segment.strip()
            if cleaned_segment:
                processed_parts.append(cleaned_segment)
                
    # 将所有部分用单个空格连接
    # 这样保证了：
    # 1. 中文内部有空格 ("Ni Hao")
    # 2. 中文与英文/数字之间有空格 ("Ni Hao 1943")
    # 3. 英文/数字内部保持原样
    new_name = " ".join(processed_parts)
    
    # 清理可能出现的多个连续空格（虽然上述逻辑通常不会产生，但作为保险）
    new_name = re.sub(r'\s+', ' ', new_name).strip()
    
    return new_name + ext

def batch_rename():
    # 获取当前脚本所在目录
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    print(f"正在处理目录: {current_dir}")
    count = 0
    
    for filename in os.listdir(current_dir):
        old_path = os.path.join(current_dir, filename)
        
        # 只处理文件，跳过文件夹
        if not os.path.isfile(old_path):
            continue
            
        # 可选：只处理 .nes 文件，如果需要处理所有文件，注释掉下一行
        if not filename.lower().endswith('.nes'):
            continue

        new_filename = convert_name(filename)
        
        # 如果文件名没有变化，跳过
        if new_filename == filename:
            continue
            
        new_path = os.path.join(current_dir, new_filename)
        
        try:
            os.rename(old_path, new_path)
            print(f"✅ 成功: {filename} -> {new_filename}")
            count += 1
        except Exception as e:
            print(f"❌ 失败: {filename} | 错误: {e}")
            
    print(f"\n处理完成！共修改 {count} 个文件。")
    input("按回车键退出...")

if __name__ == "__main__":
    batch_rename()
