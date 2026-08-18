# Maintainer: Jackey <jfdnet@users.noreply.github.com>
# Contributor: Jackey

pkgname=omarchy-auto-theme
pkgver=1.0.0
pkgrel=1
pkgdesc="Auto-switch Omarchy light/dark theme by sunrise/sunset"
arch=('any')
url="https://github.com/jfdnet/omarchy-auto-theme"
license=('MIT')
depends=('python' 'omarchy')
optdepends=(
    'python-dbus: geoclue automatic location'
    'python-gobject: geoclue automatic location'
    'geoclue: geoclue automatic location'
)
source=("$pkgname-$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
    cd "$srcdir/$pkgname-$pkgver"
    make DESTDIR="$pkgdir" PREFIX=/usr install
}
