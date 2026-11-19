


# 与我共享
# ee_system_patch.sh

#!/usr/bin/env bash
# =============================================================================
# ee_system_patch.sh
#   EmuELEC / NEXTOS 等 LibreELEC 系发行版的 SYSTEM (squashfs) 打补丁 + 重新封包
#
# 用途：把补丁文件（内核模块 .ko / 固件 / 配置文件）合并进 SYSTEM 并重新打包。
#       dtb.img 和 /storage/.config 下的文件不需要动 SYSTEM，别往这里塞。
#
# 用法：
#   sudo ./ee_system_patch.sh <SYSTEM文件> <补丁目录> [输出文件名]
#
# 例子：
#   sudo ./ee_system_patch.sh /mnt/usb/EMUELEC/SYSTEM ./patches SYSTEM.new
#
# 补丁目录结构 = SYSTEM 内的绝对路径结构，例如：
#   patches/usr/lib/kernel-overlays/base/lib/modules/4.9.269/uwe5631-aml/uwe5621_bsp_sdio.ko
#   patches/usr/lib/kernel-overlays/base/lib/modules/4.9.269/uwe5631-aml/sprdwl_ng.ko
#   patches/usr/lib/kernel-overlays/base/lib/modules/4.9.269/uwe5631-aml/sprdtty.ko
#   patches/usr/lib/firmware/wcnmodem.bin
#   patches/usr/bin/xxx.sh
#
# 关键约束（踩过坑的都懂）：
#   1) 必须在 Linux 原生文件系统（ext4/xfs/btrfs）上解包；NTFS / exFAT / FAT32
#      会丢权限位和符号链接，打出来的 SYSTEM 会让 sshd 拒绝登录（密码错误）。
#      Windows 请用 WSL2（其 vhdx 内部就是 ext4），或干脆在 Ubuntu 里做。
#   2) 压缩算法和 block size 必须和原镜像一致，否则内核可能挂不上 SYSTEM。
#      本脚本会先用 unsquashfs -s 读超级块，再原样传给 mksquashfs。
#   3) 全程 root 运行；打包加 -all-root，保证属主都是 0:0。
# =============================================================================
set -euo pipefail

SYS=${1:-}
PATCHDIR=${2:-}
OUT=${3:-SYSTEM.new}
WORK=${WORK:-/var/tmp/ee-patch}

die() { echo "错误：$*" >&2; exit 1; }

# mount -o remount,ro /flash
# mount -o remount,rw /flash
mount -o remount,ro /flash

PATCHDIR=/storage/nospatch

# [[ -n "$SYS" && -n "$PATCHDIR" ]] || die "用法: $0 <SYSTEM文件> <补丁目录> [输出文件名]"
[[ -n "$PATCHDIR" ]] || die "用法: $0 <补丁目录> [输出文件名]"
SYS=/flash
[[ -f "$SYS" ]] || die "找不到 SYSTEM 文件: $SYS"
[[ -d "$PATCHDIR" ]] || die "找不到补丁目录: $PATCHDIR"
[[ $(id -u) -eq 0 ]] || die "请用 root 运行（sudo $0 ...）"
command -v unsquashfs >/dev/null || die "缺少 unsquashfs，请安装 squashfs-tools"
command -v mksquashfs >/dev/null || die "缺少 mksquashfs，请安装 squashfs-tools"

# --- 0. 工作目录必须在原生 Linux 文件系统上 --------------------------------
mkdir -p "$WORK"
FSTYPE=$(stat -f -c %T "$WORK" 2>/dev/null || echo unknown)
case "$FSTYPE" in
  ext2/ext3|ext4|xfs|btrfs|overlayfs) : ;;
  *) die "工作目录 $WORK 位于 $FSTYPE，会丢失权限位。请改用 ext4 路径，例如 WORK=/var/tmp/ee-patch" ;;
esac
echo "== 工作目录: $WORK ($FSTYPE)"

# --- 1. 读原始 superblock，拿到压缩算法和 block size ------------------------
INFO=$(unsquashfs -s "$SYS")
COMP=$(awk '/^Compression[ ]/{print $2}' <<<"$INFO" | head -1)
BLOCK=$(awk '/^Block size[ ]/{print $3}' <<<"$INFO" | head -1)
[[ -n "$COMP" ]] || COMP=gzip
[[ -n "$BLOCK" ]] || BLOCK=262144
echo "== 原镜像: compression=$COMP block=$BLOCK"
echo "$INFO" | sed 's/^/   /'

case "$COMP" in
  gzip) COPTS=(-Xcompression-level 9) ;;
  lzo)  COPTS=(-Xcompression-level 9) ;;
  xz)   COPTS=(-Xdict-size 100%) ;;
  zstd) COPTS=(-Xcompression-level 19) ;;
  lz4)  COPTS=() ;;
  *)    COPTS=() ;;
esac

# --- 2. 解包 ---------------------------------------------------------------
ROOT="$WORK/squashfs-root"
rm -rf "$ROOT"
echo "== 解包 -> $ROOT"
unsquashfs -n -d "$ROOT" "$SYS"

# --- 3. 打补丁 -------------------------------------------------------------
echo "== 合并补丁: $PATCHDIR"
cp -a "$PATCHDIR"/. "$ROOT"/

# 权限兜底：模块 644、脚本 755、属主 root
find "$ROOT" -type f -name '*.ko' -exec chmod 0644 {} +
find "$ROOT" -type f -name '*.sh' -exec chmod 0755 {} +
chown -R 0:0 "$ROOT"

# --- 4. 重新封包 -----------------------------------------------------------
echo "== 封包 -> $OUT (comp=$COMP block=$BLOCK)"
rm -f "$OUT"
mksquashfs "$ROOT" "$OUT" \
  -noappend \
  -comp "$COMP" "${COPTS[@]}" \
  -b "$BLOCK" \
  -all-root \
  -no-progress

# --- 5. 校验 ---------------------------------------------------------------
echo "== 校验新镜像"
unsquashfs -s "$OUT" | sed 's/^/   /'
echo "   文件数: $(unsquashfs -l "$OUT" | wc -l)"
echo "   原大小: $(du -h "$SYS" | cut -f1)   新大小: $(du -h "$OUT" | cut -f1)"
md5sum "$OUT" | awk '{print "   md5: "$1}'

cat <<EOF

== 完成
下一步（在挂载了 EMUELEC 分区的机器上）：
  1) 备份原文件:  cp /media/\$USER/EMUELEC/SYSTEM{,.bak}
  2) 覆盖:        cp "$OUT" /media/\$USER/EMUELEC/SYSTEM
  3) 更新校验:    cd /media/\$USER/EMUELEC && md5sum SYSTEM > SYSTEM.md5
  4) 首次启动建议先跑一遍，确认能进 ES；不行就用 .bak 还原

注意：
  - EMUELEC 分区是 FAT32，SYSTEM 变大后要确认分区还有剩余空间。
  - 只想加 dtb 或遥控器配置的话，根本不用动 SYSTEM（见 README）。
EOF
