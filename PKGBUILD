# Maintainer: Troy Will <troydwill@gmail.com>

pkgname=perl-network
pkgver=20120607
pkgrel=1
pkgdesc="Parses and beautifies perl source"
arch=('any')
url="http://search.cpan.org/dist/Perl-Tidy"
license=('GPL' 'PerlArtistic')
depends=('perl>=5.10.0')
options=('!emptydirs')
source=(http://packages.shilohsystem.com/Perl-Network-$pkgver.tar.gz)
md5sums=('e4a568f13264b497221b1f1a7f42bee8')

build() {
  cd  $srcdir/Perl-Network-$pkgver
}

package() {
  cd  $srcdir/Perl-Network-$pkgver
  install -Dm755 usr/local/bin/perl-net-connect-open $pkgdir/usr/local/bin/perl-net-connect-open
  install -Dm755 usr/local/bin/perl-net-status $pkgdir/usr/local/bin/perl-net-status
  install -Dm755 usr/local/bin/wireless-connect.pl $pkgdir/usr/local/bin/wireless-connect.pl
  install -Dm755 usr/local/bin/perl-net-scan-wireless $pkgdir/usr/local/bin/perl-net-scan-wireless
  install -Dm755 usr/local/bin/print-hash $pkgdir/usr/local/bin/print-hash
  install -Dm755 usr/local/bin/perl-wireless-daemon $pkgdir/usr/local/bin/perl-wireless-daemon

#  install --directory /usr/local/etc
  install --directory $pkgdir/usr/local/etc/wireless
  install -Dm755 usr/local/etc/wireless/perl-network $pkgdir/usr/local/etc/wireless/perl-network
  install -Dm755 usr/local/etc/wireless/00 $pkgdir/usr/local/etc/wireless/00

  install --directory $pkgdir/usr/local/lib/perl5/site_perl
  install -Dm755 usr/local/lib/perl5/site_perl/perl-net-common.pm $pkgdir/usr/local/lib/perl5/site_perl/perl-net-common.pm
  install -Dm755 usr/local/lib/perl5/site_perl/perl-net-scan.pm $pkgdir/usr/local/lib/perl5/site_perl/perl-net-scan.pm
  find $pkgdir -name '.packlist' -delete
  find $pkgdir -name '*.pod' -delete
}

