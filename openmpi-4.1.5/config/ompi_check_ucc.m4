dnl -*- shell-script -*-
dnl
dnl Copyright (c) 2021      Mellanox Technologies. All rights reserved.
dnl Copyright (c) 2013-2021 Cisco Systems, Inc.  All rights reserved.
dnl Copyright (c) 2015      Research Organization for Information Science
dnl                         and Technology (RIST). All rights reserved.
dnl $COPYRIGHT$
dnl
dnl Additional copyrights may follow
dnl
dnl $HEADER$
dnl

# OMPI_CHECK_UCC(prefix, [action-if-found], [action-if-not-found])
# --------------------------------------------------------
# check if ucc support can be found.  sets prefix_{CPPFLAGS,
# LDFLAGS, LIBS} as needed and runs action-if-found if there is
# support, otherwise executes action-if-not-found
AC_DEFUN([OMPI_CHECK_UCC],[
    OPAL_VAR_SCOPE_PUSH([ompi_check_ucc_dir ompi_check_ucc_happy CPPFLAGS_save LDFLAGS_save LIBS_save])

    AC_ARG_WITH([ucc],
                [AS_HELP_STRING([--with-ucc(=DIR)],
                                [Build UCC (Unified Collective Communication)])])

    AS_IF([test "$with_ucc" != "no"],
          [AS_IF([test -n "$with_ucc" && test "$with_ucc" != "yes"],
                 [ompi_check_ucc_dir=$with_ucc])

           CPPFLAGS_save=$CPPFLAGS
           LDFLAGS_save=$LDFLAGS
           LIBS_save=$LIBS

           OPAL_LOG_MSG([$1_CPPFLAGS : $$1_CPPFLAGS], 1)
           OPAL_LOG_MSG([$1_LDFLAGS  : $$1_LDFLAGS], 1)
           OPAL_LOG_MSG([$1_LIBS     : $$1_LIBS], 1)

           OPAL_CHECK_PACKAGE([$1],
                              [ucc/api/ucc.h],
                              [ucc],
                              [ucc_init_version],
                              [],
                              [$ompi_check_ucc_dir],
                              [],
                              [ompi_check_ucc_happy="yes"],
                              [ompi_check_ucc_happy="no"])

           AS_IF([test "$ompi_check_ucc_happy" = "yes"],
                 [
                     CPPFLAGS=$coll_ucc_CPPFLAGS
                     LDFLAGS=$coll_ucc_LDFLAGS
                     LIBS=$coll_ucc_LIBS
                     AC_CHECK_FUNCS(ucc_comm_free, [], [])
                 ],
                 [])

           AC_MSG_CHECKING([if UCC supports float128 and float32(64,128)_complex datatypes])
           AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <ucc/api/ucc.h>]],
                                         [[ucc_datatype_t dt = UCC_DT_FLOAT32_COMPLEX;]])],
                       [flag=1
                       AC_MSG_RESULT([yes])],
                       [flag=0
                       AC_MSG_RESULT([no])])
           AC_DEFINE_UNQUOTED(UCC_HAVE_COMPLEX_AND_FLOAT128_DT, $flag, [Check if float128 and float32(64,128)_complex dt are available in ucc.])

           CPPFLAGS=$CPPFLAGS_save
           LDFLAGS=$LDFLAGS_save
           LIBS=$LIBS_save],
          [ompi_check_ucc_happy=no])

    AS_IF([test "$ompi_check_ucc_happy" = "yes" && test "$enable_progress_threads" = "yes"],
          [AC_MSG_WARN([ucc driver does not currently support progress threads.  Disabling UCC.])
           ompi_check_ucc_happy="no"])

    AS_IF([test "$ompi_check_ucc_happy" = "yes"],
          [$2],
          [AS_IF([test -n "$with_ucc" && test "$with_ucc" != "no"],
                 [AC_MSG_ERROR([UCC support requested but not found.  Aborting])])
           $3])

    OPAL_VAR_SCOPE_POP
])
