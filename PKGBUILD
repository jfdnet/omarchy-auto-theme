# Maintainer: Jackey <jfdnet@users.noreply.github.com>

pkgname=omarchy-auto-theme
pkgver=1.4.0
pkgrel=1
pkgdesc="Auto-switch Omarchy light/dark theme by sunrise/sunset (NOAA solar algorithm)"
arch=('any')
url="https://github.com/jfdnet/omarchy-auto-theme"
license=('MIT')
depends=('python' 'omarchy')
optdepends=(
    'python-dbus: geoclue automatic location'
    'python-gobject: geoclue automatic location'
    'geoclue: geoclue automatic location'
)
source=("https://github.com/jfdnet/omarchy-auto-theme/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('660edea826f1fa28f4a5e7596141232d1e1f3bbb62a74900082f84ff576c1039')

package() {
    cd "$srcdir/omarchy-auto-theme-$pkgver"
    make DESTDIR="$pkgdir" PREFIX=/usr install
}
