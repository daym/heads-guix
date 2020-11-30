;;; Copyright © 2020 Danny Milosavljevic <dannym@scratchpost.org>
;;;
;;; Heads is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2 of the License, or (at
;;; your option) any later version.
;;;
;;; Heads is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with Heads.  If not, see <http://www.gnu.org/licenses/>.

(define-module (osresearch packages heads)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  ;; FIXME: Use specification->package instead.
  #:use-module (gnu packages admin)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages busybox)
  #:use-module (gnu packages cryptsetup)
  #:use-module (gnu packages flashing-tools)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages hardware)
  #:use-module (gnu packages heads)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages popt)
  #:use-module (gnu packages python)
  #:use-module (gnu packages slang)
  #:use-module (gnu packages cpio)
  #:use-module (gnu packages file)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages aidc)
  #:use-module (gnu packages security-token)
  #:use-module (gnu packages mcrypt)
  #:use-module (gnu packages musl))

(define (package-with-musl base)
  (package
    (inherit base)
    (arguments
     (substitute-keyword-arguments (package-arguments base)
      ((#:implicit-inputs? #f #f)
       #f)
      ((#:disallowed-references disallowed-references '())
       (cons glibc disallowed-references))
      ((#:phases phases)
       `(modify-phases ,phases
          (add-after 'unpack 'setenv-musl
            (lambda _
              #t))))))
    (native-inputs
     `(("musl" ,musl)
       ("tar" ,tar)
       ("xz" ,xz)
       ,@(package-native-inputs base)))))

;(gnu packages commencement))))
;    (module-ref distro '%final-inputs)))
;cross-base

;; TODO: Auto-target musl.
(define-public gcc-8.3
  (package
    (inherit gcc-7)
    (version "8.3.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnu/gcc/gcc-"
                                  version "/gcc-" version ".tar.xz"))
              (sha256
               (base32
                "2m1d3gfix56w4aq8myazzfffkl8bqcrx4jhhapnjf7qfs596w2p3"))
              (patches (search-patches "gcc-8-strmov-store-file-names.patch"
                                       "gcc-5.0-libvtv-runpath.patch"))))))

; musl-cross-make: gcc-8.3.0 is the default.
; Newest they support is gcc-9.2.0.

;; FIXME musl-build-system
(define-public heads-busybox
  (package-with-musl (package
    (inherit busybox)
    (name "heads-busybox")
    (version "1.31.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://busybox.net/downloads/busybox-"
                                  version ".tar.bz2"))
              (sha256
               (base32
                "1659aabzp8w4hayr4z8kcpbk2z1q2wqhw7i1yb0l72b45ykl1yfh"))
              (patches
               (search-patches
                "busybox-1.31.1-fix-build-with-glibc-2.31.patch"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("inetutils" ,inetutils) ; for the tests
       ("which" ,which) ; for the tests
       ("zip" ,zip))) ; for the tests
    (inputs
     `()))))

;; FIXME musl-build-system
(define-public heads-libpng
  (package
    (inherit libpng)
    (name "heads-libpng")
    (version "1.6.34")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://download.sourceforge.net/libpng/libpng-"
                              version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "19v454hlpj98bqimrz8d2n3qlv026yadz8ml1846k68sj2j26ijp"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `(("heads-zlib" ,heads-zlib)))
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-pixman
  (package
    (inherit pixman)
    (name "heads-pixman")
    (version "0.34.0")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.cairographics.org/releases/pixman-"
                              version ".tar.gz"))
              (sha256
               (base32
                "13m842m9ffac3m9r0b4lvwjhwzg3w4353djkjpf00s0wnm4v5di1"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags
       '("--disable-gtk")))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-cairo
  (package
    (inherit cairo)
    (name "heads-cairo")
    (version "1.14.12")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.cairographics.org/releases/cairo-"
                              version ".tar.xz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "05mzyxkvsfc1annjw2dja8vka01ampp9pp93lg09j8hba06g144c"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `(("heads-libpng" ,heads-libpng)
       ("heads-pixman" ,heads-pixman)))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-coreboot
  (package
    (name "heads-coreboot")
    (version "4.8.1")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.coreboot.org/releases/coreboot-"
                              version ".tar.xz"))
              (file-name (string-append name "-" version ".tar.xz"))
              (sha256
               (base32
                "08xdd5drk8yd37a3z5hc81qmgsybv6201i28hcggxh980vdz9pgh"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())
    (synopsis "coreboot")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-util-linux
  (package
    (inherit util-linux)
    (name "heads-util-linux")
    (version "2.29.2")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.kernel.org/pub/linux/utils/util-linux/v2.29/util-linux-"
                              version ".tar.xz"))
              (sha256
               (base32
                "1qz81w8vzrmy8xn9yx7ls4amkbgwx6vr62pl6kv9g7r0g3ba9kmc"))))
    (build-system gnu-build-system)
    (arguments
     (substitute-keyword-arguments (package-arguments util-linux)
       ((#:configure-flags _)
        '(list "--disable-bash-completion"
               "--disable-all-programs"
               "--enable-libuuid"
               "--enable-libblkid"))
       ((#:phases phases)
        `(modify-phases ,phases
           (replace 'pre-check
             (lambda* (#:key inputs outputs #:allow-other-keys)
               (with-fluids ((%default-port-encoding #f))
                      (let ((out (assoc-ref outputs "out"))
                            (net (assoc-ref inputs "net-base")))
                        ;; Change the test to refer to the right file.
                        (substitute* "tests/ts/misc/mcookie"
                          (("/etc/services")
                           (string-append net "/etc/services")))

                        ;; The C.UTF-8 locale does not exist in our libc.
                        (substitute* "tests/ts/column/invalid-multibyte"
                          (("C\\.UTF-8") "en_US.utf8"))

                        (substitute* "tests/expected/libmount/optstr-fix"
                          (("fixed:.*uid=0,gid=0")
                           "fixed:  uid=root,gid=root"))
                        #t))))))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("net-base" ,net-base)))))

;; FIXME musl-build-system
(define-public heads-cryptsetup
  (package
    (inherit cryptsetup)
    (name "heads-cryptsetup")
    (version "1.7.3")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.kernel.org/pub/linux/utils/cryptsetup/v1.7/cryptsetup-"
                              version ".tar.xz"))
              (sha256
               (base32
                "00nwd96m9yq4k3cayc04i5y7iakkzana35zxky6hpx2w8zl08axg"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags
       '("--disable-gcrypt-pbkdf2"
         "--enable-cryptsetup-reencrypt"
         "--with-crypto_backend=kernel")))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-popt" ,heads-popt)
       ("heads-lvm2" ,heads-lvm2)
       ("libuuid" ,heads-util-linux "lib")))))

;; FIXME musl-build-system
(define-public heads-dropbear
  (package
    (inherit dropbear)
    (name "heads-dropbear")
    (version "2016.74")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://matt.ucc.asn.au/dropbear/releases/dropbear-"
                              version ".tar.bz2"))
              (sha256
               (base32
                "14c8f4gzixf0j9fkx68jgl85q7b05852kk0vf09gi6h0xmafl817"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-zlib" ,heads-zlib)))))

;; FIXME musl-build-system
(define-public heads-fbwhiptail
  (package
    (name "heads-fbwhiptail")
    (version "0.1") ; FIXME
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://source.puri.sm/coreboot/fbwhiptail.git")
                     (commit "e5001e925d5ac791d4cb8fb4cf9d3fb97cde3e51")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1wlihcjyn801j4r3n872w3qpnc0pbg8n762xv9n8shvhsgarkc6k"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f            ; No tests
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             "fbwhiptail")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
               (install-file "fbwhiptail" bin)
               #t))))))
    (propagated-inputs
     `())
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("heads-cairo" ,heads-cairo)))
    (synopsis "fbwhiptail")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-flashrom
  (package
    (inherit flashrom)
    (name "heads-flashrom")
    (version "1.2")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://download.flashrom.org/releases/flashrom-v"
                              version ".tar.bz2"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0ax4kqnh7kd3z120ypgp73qy1knz47l6qxsqzrfkd97mh5cdky71"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("heads-libusb" ,heads-libusb)
       ("heads-pciutils" ,heads-pciutils)))))

;; FIXME musl-build-system
(define-public heads-flashtools
  (package
    (name "heads-flashtools")
    (version "0.0.1") ; FIXME
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                 (url "https://github.com/osresearch/flashtools")
                 (commit "9acce09aeb635c5bef01843e495b95e75e8da135")))
              (file-name (string-append "flashtools-" version ".tar.gz"))
              (sha256
               (base32
                "0r4gj3nzr67ycd39k1vjzxfzkp90yacrdgxhc1z5jfvxfq4x91c1"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f       ; No tests
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target)))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
               (install-file "flashtool" bin)
               (install-file "peek" bin)
               (install-file "poke" bin)
               (install-file "cbfs" bin)
               (install-file "uefi" bin)
               #t))))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())
    (synopsis "flashtools")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-frotz
  (package
    (inherit frotz)
    (name "heads-frotz")
    (version "2.44")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://github.com/DavidGriffith/frotz/archive/"
                              version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "13w5pbrhp7vdx3k2q290bc41n7xwb3mbmgf4hjwxqxajr4xypdfv"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f            ; No automatic tests
       #:make-flags
       (list "dfrotz"
             (string-append "PREFIX=" (assoc-ref %outputs "out")))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key (make-flags '()) #:allow-other-keys)
             (apply invoke "make" "install_dumb" make-flags))))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-gpg
  (package
    (inherit gnupg-1)
    (name "heads-gpg")
    (version "1.4.21")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-"
                              version ".tar.bz2"))
              (sha256
               (base32
                "0xi2mshq8f6zbarb5f61c9w2qzwrdbjm4q8fqsrwlzc51h8a6ivb"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-gpg2
  (package
    (inherit gnupg)
    (name "heads-gpg2")
    (version "2.2.20")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-"
                              version ".tar.bz2"))
              (sha256
               (base32
                "0c6a4v9p6qzhsw1pfcwc459bxpc8hma0w9z8iqb9khvligack9q4"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("pkg-config" ,pkg-config))) ; TODO: Remove?
    (inputs
     `(("heads-libgpg-error" ,heads-libgpg-error)
       ("heads-libgcrypt" ,heads-libgcrypt)
       ("heads-libassuan" ,heads-libassuan)
       ("heads-libksba" ,heads-libksba)
       ("heads-npth" ,heads-npth)
       ("heads-zlib" ,heads-zlib) ; TODO: Check.
       ("pcsc-lite" ,pcsc-lite)))))

;; FIXME musl-build-system; FIXME move to librekey
(define-public heads-hidapi
  (package
    (inherit hidapi)
    (name "heads-hidapi")
    (version "0.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/Nitrokey/hidapi/archive/e5ae0d30a523c565595bdfba3d5f2e9e1faf0bd0.tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "1q48449c8hvhj5acn4vyp9hcf8as0r399giy5df0h5w9k84abhmc"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)
       ("libtool" ,libtool)
       ("pkg-config" ,pkg-config)))
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-kexec
  (package
    (inherit kexec-tools)
    (name "heads-kexec")
    (version "2.0.20")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://kernel.org/pub/linux/utils/kernel/kexec/kexec-tools-"
                              version ".tar.gz"))
              (sha256
               (base32
                "05ksnlzal3sfnix9qds6qql1sjn3fxbdwgp3ncxxxjg032cdf5nb"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-libgpg-error
  (package
    (inherit libgpg-error)
    (name "heads-libgpg-error")
    (version "1.37")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-"
                               version ".tar.bz2"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0qwpx8mbc2l421a22l0l1hpzkip9jng06bbzgxwpkkvk5bvnybdk"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-libassuan
  (package
    (inherit libassuan)
    (name "heads-libassuan")
    (version "2.5.3")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-"
                              version ".tar.bz2"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "00p7cpvzf0q3qwcgg51r9d0vbab4qga2xi8wpk2fgd36710b1g4i"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-libgpg-error" ,heads-libgpg-error)))))

;; FIXME musl-build-system
(define-public heads-libgcrypt
  (package
    (inherit libgcrypt)
    (name "heads-libgcrypt")
    (version "1.8.5")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-"
                              version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0jgwhw6j7d5lrcyp4qviy986q7a6mj2zqi1hpjg0x646awk64vig"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags
       '("--disable-static"
         "--disable-asm"
         "--disable-nls")))
    (propagated-inputs
     `())
    (native-inputs
     `(("bison" ,bison)
       ("flex" ,flex)
       ("pkg-config" ,pkg-config)))
    (inputs
     `(("libgpg-error-host" ,heads-libgpg-error) ; FIXME
       ("libmhash" ,libmhash) ; TODO: Or use libcrypt.
       ("heads-zlib" ,heads-zlib)))))

;; FIXME musl-build-system ; FIXME: Set up gpg-error error prefix
(define-public heads-libksba
  (package
    (inherit libksba)
    (name "heads-libksba")
    (version "1.3.5")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://gnupg.org/ftp/gcrypt/libksba/libksba-"
                              version ".tar.bz2"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0h53q4sns1jz1pkmhcz5wp9qrfn9f5g9i3vjv6dafwzzlvblyi21"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("libgpg-error" ,heads-libgpg-error)))))

;; FIXME musl-build-system
(define-public heads-libusb
  (package
    (inherit libusb)
    (name "heads-libusb")
    (version "1.0.21")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://downloads.sourceforge.net/project/libusb/libusb-1.0/libusb-" version "/libusb-" version ".tar.bz2"))
              (sha256
               (base32
                "0jw2n5kdnrqvp7zh792fd6mypzzfap6jp4gfcmq4n6c1kb79rkkx"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system; FIXME: Set up CONFIG_SHELL.
(define-public heads-libremkey-hotp-verification
  (package
    (name "heads-libremkey-hotp-verification")
    (version "0.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/Nitrokey/nitrokey-hotp-verification/archive/809953b9b4bef97a4cffaa20d675bd7fe9d8da53.tar.gz"))
              (file-name (string-append "nitrokey-hotp-verification-809953b9b4bef97a4cffaa20d675bd7fe9d8da53.tar.gz"))
              (sha256
               (base32
                "1fjqx6d5fc4h392v0b6k9ivxxl923vda3r29vknmxr74fkpmq7i5"))))
    (build-system cmake-build-system)
    (arguments
     `(#:tests? #f    ; No tests exist.
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-include-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "CMakeLists.txt"
              (("/usr/include/libusb-1.0")
               (string-append (assoc-ref inputs "heads-libusb")
                              "/include/libusb-1.0"))
              (("include_directories[(]hidapi/hidapi[)]")
               "include_directories(hidapi)
include_directories(hidapi/hidapi)"))
             #t))
         (add-after 'unpack 'setenv
           (lambda* (#:key inputs #:allow-other-keys)
             (invoke "tar" "xf" (assoc-ref inputs "hidapi-source"))
             (rmdir "hidapi")
             (symlink "hidapi-e5ae0d30a523c565595bdfba3d5f2e9e1faf0bd0" "hidapi")
             #t)))))
    (propagated-inputs
     `())
    (native-inputs
     `(("hidapi-source" ,(package-source heads-hidapi))
       ("pkg-config" ,pkg-config))) ; useless
    (inputs
     `(("heads-libusb" ,heads-libusb)))
    ;; TODO: Unpack hidapi
    (synopsis "libremkey-hotp-verification")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-libusb-compat
  (package
    (inherit libusb-compat)
    (name "heads-libusb-compat")
    (version "0.1.5")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://downloads.sourceforge.net/project/libusb/libusb-compat-0.1/libusb-compat-"
                              version "/libusb-compat-" version ".tar.bz2"))
              (sha256
               (base32
                "0nn5icrfm9lkhzw1xjvaks9bq3w6mjg86ggv3fn7kgi4nfvg8kj0"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("heads-libusb" ,heads-libusb)))))

;; FIXME musl-build-system
(define-public heads-linux
  (package
    (inherit linux-libre)
    (name "heads-linux")
    (version "FIXME")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://github.com/andikleen/linux-misc/archive/"
                "b87b58e1b057a2706d422fbdc76aa34309c6c90b.tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "122w48kx1fgq2xgq77hhnzhxmi8fwfwbryr4q4pamqa0896yvirh"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("perl" ,perl)
       ("bc" ,bc)
       ("openssl" ,openssl)
       ("elfutils" ,elfutils)  ; Needed to enable CONFIG_STACK_VALIDATION
       ("flex" ,flex)
       ("bison" ,bison)

       ;; These are needed to compile the GCC plugins.
       ("gmp" ,gmp)
       ("mpfr" ,mpfr)
       ("mpc" ,mpc)))
    (inputs
     `())))

(define udk2018
  (origin
    (method git-fetch)
    (uri
     (git-reference
       (url "https://github.com/linuxboot/edk2")
       (commit "UDK2018"))) ; branch
     (file-name "edk2")
     (sha256
      (base32 "0s3vljxhbsbdjy2a2ydv0835rhdakvhn8c8p4x4ch29fcrjc3ymf"))))

;; FIXME musl-build-system
(define-public heads-linuxboot
  (package
    (name "heads-linuxboot")
    (version "FIXME")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                 (url "https://github.com/osresearch/linuxboot")
                 (commit "b5376a441e8e85cbf722e943bb8294958e87c784")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1bdj4m9dvih9fhp5q5c6cp5sphzbpag5gp4bz1p8g9lqi49lb7av"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list "SHELL=bash"
             (string-append "KERNEL=" (assoc-ref %build-inputs "heads-linux") "/bzImage")
             ) ; TODO: BOARD INITRD
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'unpack-edk2
           (lambda* (#:key inputs #:allow-other-keys)
             (copy-recursively (assoc-ref inputs "edk2") "edk2")
             #t))
         (add-after 'unpack 'patch-references
           (lambda _
             (substitute* "dxe/Makefile"
              (("/usr/bin/printf") "command printf"))
             #t))
         (delete 'configure))))
    (propagated-inputs
     `())
    (native-inputs
     `(("edk2" ,udk2018)
       ("perl" ,perl)))
    (inputs
     `(("heads-linux" ,heads-linux)))
    (synopsis "linuxboot")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-lvm2
  (package
    (inherit lvm2)
    (name "heads-lvm2")
    (version "2.02.168")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://mirrors.kernel.org/sourceware/lvm2/LVM2."
                              version ".tgz"))
              (sha256
               (base32
                "03b62hcsj9z37ckd8c21wwpm07s9zblq7grfh58yzcs1vp6x38r3"))))
    (build-system gnu-build-system)
    (arguments
     (substitute-keyword-arguments (package-arguments lvm2)
      ((#:configure-flags _)
       '(list "PKG_CONFIG=false"
         "MODPROBE_CMD=false"
         "--enable-devmapper"
         "--disable-selinux"
         "--disable-udev-systemd-background-jobs"
         "--disable-realtime"
         "--disable-dmeventd"
         "--disable-lvmetad"
         "--disable-lvmpolld"
         "--disable-use-lvmlockd"
         "--disable-use-lvmetad"
         "--disable-use-lvmpolld"
         "--disable-blkid_wiping"
         "--disable-cmirrord"
         "--disable-cache_check_needs_check"
         "--disable-thin_check_needs_check"
         "--with-cluster=none"
         (string-append "LDFLAGS=-Wl,-rpath=" (assoc-ref %outputs "out") "/lib")))
      ((#:phases phases)
       `(modify-phases ,phases
          (add-after 'unpack 'setenv
            (lambda _
              (setenv "SHELL" "bash")
              ;; Disable config.
              (setenv "CONFDEST" "/tmp")
              #t))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (include (string-append out "/include"))
                     (bin (string-append out "/sbin"))
                     (lib (string-append out "/lib")))
                (install-file "include/libdevmapper-event.h" include)
                (install-file "include/libdevmapper.h" include)
                (install-file "include/lvm2cmd.h" include)
                (install-file "tools/dmsetup" bin)
                (install-file "tools/lvm" bin)
                (install-file "libdm/libdevmapper.so.1.02" lib)
                (install-file "libdm/libdevmapper.so" lib)
                #t)))))))
    (propagated-inputs
     `())
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-make
  (package
    (inherit gnu-make)
    (name "heads-make")
    (version "4.2.1")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "http://gnu.mirror.constant.com/make/make-"
                              version ".tar.bz2"))
              (sha256
               (base32
                "12f5zzyq2w56g95nni65hc0g5p7154033y2f3qmjvd016szn5qnn"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       '("CFLAGS=-D__alloca=alloca")))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-mbedtls
  (package
    (inherit mbedtls-apache)
    (name "heads-mbedtls")
    (version "2.4.2")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://tls.mbed.org/download/mbedtls-"
                              version "-gpl.tgz"))
              (sha256
               (base32
                "17r9qs585gqghcf5yavb1cnvsigl0f8r0k8rklr5a855hrajs7yh"))
              (patches
               (search-patches "mbedtls-2.4.2-fix-tests.patch"))))
    (build-system cmake-build-system)
    (arguments
     `( ;#:out-of-source? #t ; Make one of the tests find its data file
       #:configure-flags '("-DUSE_SHARED_MBEDTLS_LIBRARY=ON"
                           "-DUSE_STATIC_MBEDTLS_LIBRARY=OFF")
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             "SHARED=1"
             (string-append "LDFLAGS=-Wl,-rpath=" (assoc-ref %outputs "out") "/lib")
             (string-append "DESTDIR=" (assoc-ref %outputs "out")))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'fix-tests
           (lambda _
             (write (getcwd))
             (newline)
             (setenv "CTEST_OUTPUT_ON_FAILURE" "1")
             (call-with-output-file "fake_time.c"
               (lambda (port)
                 (format port "#include <sys/time.h>

time_t time(time_t* p)
{
        time_t result = 1550065446;
        if (p)
                *p = result;
        return result;
}
")))
             (invoke ,(cc-for-target) "-fPIC" "-shared" "-o" "fake_time.so"
                     "fake_time.c")
             (substitute* "tests/Makefile"
              (("perl scripts/run-test-suites.pl")
               (string-append "LD_PRELOAD=" (getcwd) "/fake_time.so "
                              "perl scripts/run-test-suites.pl")))
             #t)))))
    (propagated-inputs
     `())
    (native-inputs
     `(("perl" ,perl)))
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-msrtools
  (package
    (inherit msr-tools)
    (name "heads-msrtools")
    (version "0.1") ; FIXME
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://github.com/osresearch/msr-tools/archive/572ef8a2b873eda15a322daa48861140a078b92c.tar.gz"))
              (sha256
               (base32
                "1h3a1rai47r0dxiiv0i3xj0fjng15n6sxj8mw9gj0154s284fmc0"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f    ; No tests
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target)))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
               (install-file "cpuid" bin)
               (install-file "rdmsr" bin)
               (install-file "wrmsr" bin)
               #t))))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system (not really?)
(define-public heads-musl-cross
  (package
    (inherit musl-cross)
    (name "heads-musl-cross")
    (version "0.1") ; FIXME
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/richfelker/musl-cross-make/archive/38e52db8358c043ae82b346a2e6e66bc86a53bc1.tar.gz"))
              (sha256
               (base32
                "0071ml3d42w8m59dc1zvl9pk931zcxsyflqacnwg5c6s7mnmvf5l"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("config.sub" ,automake)))
    (inputs
     `())
    (synopsis "musl-cross")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-popt
  (package
    (inherit popt)
    (name "heads-popt")
    (version "1.16")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://launchpad.net/popt/head/"
                              version "/+download/popt-" version ".tar.gz"))
              (sha256
               (base32
                "1j2c61nn2n351nhj4d25mnf3vpiddcykq005w2h6kw79dwlysa77"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

(define-public heads-terminfo
  (package
    (inherit ncurses)
    (name "heads-terminfo")
    (arguments
     (substitute-keyword-arguments (package-arguments ncurses)
      ((#:tests? _ #f)
       #f)
      ((#:phases phases)
      `(modify-phases ,phases
         (delete 'post-install)
         (replace 'install
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (invoke "make" "install.data")))))))))

;; FIXME musl-build-system; FIXME i386-elf-linux.
(define-public heads-slang
  (package
    (inherit slang)
    (name "heads-slang")
    (version "2.3.1a")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://www.jedsoft.org/releases/slang/slang-" version ".tar.bz2"))
              (sha256
               (base32
                "0dlcy0hn0j6cj9qj5x6hpb0axifnvzzmv5jqq0wq14fygw0c7w2l"))))
    (build-system gnu-build-system)
    (arguments
     `(#:parallel-tests? #f
       #:parallel-build? #f  ; there's at least one race
       #:configure-flags
       '("--with-z=no"
         "--with-png=no"
         "--with-pcre=no"
         "--with-onig=no")
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'substitute-before-config
           (lambda* (#:key inputs #:allow-other-keys)
             (let ((ncurses (assoc-ref inputs "ncurses")))
               (substitute* "configure"
                 (("MISC_TERMINFO_DIRS=\"\"")
                  (string-append "MISC_TERMINFO_DIRS="
                                 "\"" ncurses "/share/terminfo" "\"")))
               #t)))
         (add-after 'unpack 'fix-references
           (lambda _
             (substitute* "src/Makefile.in"
              (("/bin/ln") "ln"))
             #t)))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("ncurses" ,heads-terminfo)))))

;; FIXME musl-build-system
(define-public heads-newt
  (package
    (name "heads-newt")
    (version "0.52.20")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://releases.pagure.org/newt/newt-" version ".tar.gz"))
              (sha256
               (base32
                "1g3dpfnvaw7vljbr7nzq1rl88d6r8cmrvvng9inphgzwxxmvlrld"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f               ; No tests
       #:make-flags
       `("INSTALL=install"
         ,(string-append "LDFLAGS=-Wl,-rpath=" (assoc-ref %outputs "out") "/lib"))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-slang" ,heads-slang)
       ("heads-popt" ,heads-popt)))
    (synopsis "newt")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-npth
  (package
    (inherit npth)
    (name "heads-npth")
    (version "1.6")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://gnupg.org/ftp/gcrypt/npth/npth-"
                              version ".tar.bz2"))
              (sha256
               (base32
                "1lg2lkdd3z1s3rpyf88786l243adrzyk9p4q8z9n41ygmpcsp4qk"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))

;; FIXME musl-build-system
(define-public heads-pciutils
  (package
    (inherit pciutils)
    (name "heads-pciutils")
    (version "3.5.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://www.kernel.org/pub/software/utils/pciutils/pciutils-" version ".tar.xz"))
              (sha256
               (base32
                "0rpy7kkb2y89wmbcbfjjjxsk2x89v5xxhxib4vpl131ip5m3qab4"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-zlib" ,heads-zlib)))))

;; FIXME musl-build-system; TODO: Use Guix pinentry?
(define-public heads-pinentry
  (package
    (name "heads-pinentry")
    (version "1.1.0")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-"
                              version ".tar.bz2"))
              (sha256
               (base32
                "0w35ypl960pczg5kp6km3dyr000m1hf0vpwwlh72jjkjza36c1v8"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags
       '("--enable-pinentry-tty"
         "--disable-libsecret"
         "--disable-fallback-curses"
         "--disable-pinentry-curses"
         "--disable-pinentry-qt"
         "--disable-pinentry-gtk2"
         "--disable-pinentry-gnome3"
         "--disable-pinentry-fltk"
         "--disable-pinentry-emacs"
         "--disable-fallback-curses")))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-libgpg-error" ,heads-libgpg-error)
       ("heads-libassuan" ,heads-libassuan)))
    (synopsis "pinentry")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-qrencode
  (package
    (inherit qrencode)
    (name "heads-qrencode")
    (version "3.4.4")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://fukuchi.org/works/qrencode/qrencode-"
                              version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0wiagx7i8p9zal53smf5abrnh9lr31mv0p36wg017401jrmf5577"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("heads-libpng" ,heads-libpng)))))

;; FIXME musl-build-system
(define-public heads-tpmtotp
  (package
    (name "heads-tpmtotp")
    (version "0.1") ; FIXME
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/osresearch/tpmtotp/archive/18b860fdcf5a55537c8395b891f2b2a5c24fc00a.tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0v30biwwqyqf06xnhmnwwjgb77m3476fvp8d4823x0xgwjqg50hh"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f                   ; No tests
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "LDFLAGS=-Wl,-rpath=" (assoc-ref %outputs "out") "/lib"))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'fix-installer
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "Makefile"
              (("/usr") (assoc-ref outputs "out")))
             #t))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (lib (string-append out "/lib")))
               (install-file "totp" bin)
               (install-file "hotp" bin)
               (install-file "base32" bin)
               (install-file "qrenc" bin)
               (install-file "util/tpm" bin)
               (install-file "libtpm/libtpm.so" lib)
               #t))))))
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `(("heads-mbedtls" ,heads-mbedtls)
       ("heads-qrencode" ,heads-qrencode)))
    (synopsis "tpmtotp")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
;; FIXME Copy board-specific stuff in here.
;; FIXME verify that that is the version that Heads upstream uses.
(define-public heads-u-root
  (package
    (name "heads-u-root")
    (version "6.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/u-root/u-root.git")
                    (commit (string-append "v" version))))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1d7xps86y6rnzh2g574jfpmbfigw0mmvls2qbrif3nm2b8lw8068"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())
    (synopsis "u-root")
    (description "FIXME")
    (home-page "FIXME")
    (license #f)))

;; FIXME musl-build-system
(define-public heads-zlib
  (package
    (inherit zlib)
    (name "heads-zlib")
    (version "1.2.11")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://www.zlib.net/zlib-" version ".tar.gz"))
              (sha256
               (base32
                "18dighcs333gsvajvvgqp8l4cx7h1x7yx9gd5xacnk80spyykrf3"))))
    (build-system gnu-build-system)
    (propagated-inputs
     `())
    (native-inputs
     `())
    (inputs
     `())))
