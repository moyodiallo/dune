Test for the `dune describe package-entries` command
====================================

  $ cat >dune-project <<EOF
  > (lang dune 2.7)
  > (package
  >  (name foo)
  >  (synopsis "describe package-entries"))
  > (generate_opam_files)
  > EOF

  $ cat >dune <<EOF
  > (library
  >  (public_name foo)
  >  (modules foo))
  > 
  > (executable
  >  (name main)
  >  (libraries foo)
  >  (modules main))
  > 
  > (install
  >  (section bin)
  >  (package foo)
  >  (files main.exe))
  > EOF

  $ touch main.ml
  $ touch foo.ml

  $ dune describe package-entries
  ((foo
    ((dune
      ((src
        (In_build_dir default/META.foo))
       (kind file)
       (dst META)
       (section LIB)))
     (dune
      ((src
        (In_build_dir default/foo.dune-package))
       (kind file)
       (dst dune-package)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/foo.a))
       (kind file)
       (dst foo.a)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/foo.cma))
       (kind file)
       (dst foo.cma)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/.foo.objs/byte/foo.cmi))
       (kind file)
       (dst foo.cmi)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/.foo.objs/byte/foo.cmt))
       (kind file)
       (dst foo.cmt)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/.foo.objs/native/foo.cmx))
       (kind file)
       (dst foo.cmx)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/foo.cmxa))
       (kind file)
       (dst foo.cmxa)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/foo.ml))
       (kind file)
       (dst foo.ml)
       (section LIB)))
     (user
      ((src
        (In_build_dir default/foo.cmxs))
       (kind file)
       (dst foo.cmxs)
       (section LIBEXEC)))
     (user
      ((src
        (In_build_dir default/main.exe))
       (kind file)
       (dst main.exe)
       (section BIN))))))
