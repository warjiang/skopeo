set -o errexit
set -o nounset
set -o pipefail
set -x


apk update
apk add gpgme btrfs-progs-dev llvm15-dev gcc musl-dev


LD_FLAGS='-extldflags -static'
GC_FLAGS=''
TAGS='exclude_graphdriver_devicemapper exclude_graphdriver_btrfs containers_image_openpgp'

os_archs="linux/amd64 linux/arm64 linux/ppc64le darwin/amd64 darwin/arm64"
for os_arch in ${os_archs}; do
  echo "Build binary for $os_arch"
  os=$(echo "$os_arch" | awk -F'/' '{print $1}')
  arch=$(echo "$os_arch" | awk -F'/' '{print $2}')
  CGO_ENABLE=0 GO111MODULE=on GOOS=${os} GOARCH=${arch} \
    go build -mod=vendor '-buildmode=pie' -ldflags "${LD_FLAGS}" -gcflags "${GC_FLAGS}" -tags "${TAGS}" \
    -o ./bin/skopeo-${os}-${arch} ./cmd/skopeo
  md5sum ./bin/skopeo-${os}-${arch} > ./bin/skopeo-${os}-${arch}.md5
  sha256sum ./bin/skopeo-${os}-${arch} > ./bin/skopeo-${os}-${arch}.sha256
  echo "Build binary for $os_arch finished"
done