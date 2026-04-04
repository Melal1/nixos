
#define BLOCKS(X)                                                                                                      \
  X("", "date", 1, 1)                                                                                                  \
  X("",                                                                                                                \
    "awk '/MemTotal/ {t=$2} /MemFree|Buffers|Cached|SReclaimable/ {f+=$2} /Shmem/ {f-=$2} END {printf \"   "        \
    "%.2fG\ \", (t-f)/1048576}' /proc/meminfo",                                                                        \
    1,                                                                                                                 \
    2)
