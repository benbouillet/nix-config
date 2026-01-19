```sh
sudo zfs create \
  -o mountpoint=/srv/media \
  -o quota=500G \
  -o acltype=posixacl \
  -o aclinherit=passthrough \
  -o aclmode=restricted \
  -o xattr=sa \
  hdd/media
```

```sh
sudo zfs create \
  -o mountpoint=/srv/containers  \
  -o quota=100G \
  -o canmount=on \
  -o atime=offi \
  -o compression=zstd \
  -o xattr=sa \
  -o acltype=posixacl \
  -o aclinherit=restricted \
  -o aclmode=discard \
  -o dnodesize=auto \
  -o recordsize=16K \
  ssd/containers
```

```sh
sudo zfs create \
  -o mountpoint=/srv/postgres \
  -o quota=20G \
  -o canmount=on \
  -o atime=off \
  -o compression=zstd \
  -o xattr=sa \
  -o acltype=posixacl \
  -o aclinherit=restricted \
  -o aclmode=discard \
  -o dnodesize=auto \
  -o recordsize=8K \
  -o primarycache=all \
  -o logbias=latency \
  ssd/postgres
```
