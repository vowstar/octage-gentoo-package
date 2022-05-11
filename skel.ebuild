# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="<{DESCRIPTION}>"
HOMEPAGE="https://octave.sourceforge.io/<{PN}>"
SRC_URI="https://downloads.sourceforge.net/octave/${P/octave-/}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~x86"
RESTRICT="test"

<% set RDEPEND_LIST = ["sci-mathematics/octave"] %>
<% if "database" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["dev-db/postgresql"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-mathematics/octave-struct"] %>
<% endif %>
<% if "audio" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["media-libs/rtmidi"] %>
<% endif %>
<% if "dicom" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-libs/gdcm"] %>
<% endif %>
<% if "fem-fenics" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-libs/dolfin"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["dev-python/ffcx"] %>
<% endif %>
<% if "fits" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-libs/cfitsio"] %>
<% endif %>
<% if "geometry" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-mathematics/octave-matgeom"] %>
<% endif %>
<% if "image-acquisition" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["x11-libs/fltk"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["media-libs/libv4l"] %>
<% endif %>
<% if "ltfat" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-libs/fftw"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["virtual/lapack"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["virtual/blas"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["media-libs/portaudio"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["virtual/jre"] %>
<% endif %>
<% if "miscellaneous" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-calculators/units"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sys-libs/libtermcap-compat"] %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sys-libs/ncurses"] %>
<% endif %>
<% if "sparsersb" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sys-libs/librsb"] %>
<% endif %>
<% if "strings" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["dev-libs/libpcre"] %>
<% endif %>
<% if "tisean" == PN %>
<% set RDEPEND_LIST = RDEPEND_LIST + ["sci-mathematics/octave-signal"] %>
<% endif %>
RDEPEND="
<% for PKG in RDEPEND_LIST | sort %>
	<{ PKG }>
<% endfor %>
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

<% if PN in ["bim", "cgi", "data-smoothing", "divand", "fem-fenics", "fpl", "fuzzy-logic-toolkit", "level-set", "ltfat", "msh", "mvn", "ncarray", "ocs", "quaternion", "queueing", "stk", "vrml"] %>
S="${WORKDIR}/${PN/octave-/}"
<% else %>
S="${WORKDIR}/${P/octave-/}"
<% endif %>

src_install() {
	local INST_PREFIX="${D}/usr/share/octave/packages"
	local ARCH_PREFIX="${D}/usr/$(get_libdir)/octave/packages"
	local OCTAVE_VER="$(best_version sci-mathematics/octave)"
	OCTAVE_VER_FULL=${OCTAVE_VER#sci-mathematics/octave-}
	OCTAVE_VER=${OCTAVE_VER_FULL%-*}
	export LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/$(get_libdir)/octave/${OCTAVE_VER}:/usr/$(get_libdir)/octave/${OCTAVE_VER_FULL}"

	octave --no-history --no-init-file --no-site-file --no-window-system -q -f \
		--eval "warning off all;\
		pkg prefix ${INST_PREFIX} ${ARCH_PREFIX};\
		pkg local_list octave_packages;\
		pkg global_list octave_packages;\
		pkg install -verbose -nodeps ${DISTDIR}/${P}.tar.gz;" || die
}

pkg_postinst() {
	einfo "Updating Octave internal packages cache..."
	octave --no-history --no-init-file --no-site-file --no-window-system -q -f \
		--eval "pkg rebuild;" || die
	elog "Please append 'pkg load ${PN/octave-/}' to ~/.octaverc"
}

pkg_postrm() {
	einfo "Updating Octave internal packages cache..."
	octave --no-history --no-init-file --no-site-file --no-window-system -q -f \
		--eval "pkg rebuild;" || die
	elog "Please remove 'pkg load ${PN/octave-/}' from ~/.octaverc"
}
