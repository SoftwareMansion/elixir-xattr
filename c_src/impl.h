#ifndef ELIXIR_XATTR_IMPL_H
#define ELIXIR_XATTR_IMPL_H

#include <erl_nif.h>
#include <stdbool.h>
#include <stdlib.h>

/* Portions of the documentation have been copy-pasted from Linux manpages */

/**
 * Retrieves the list of extended attribute names associated with the given
 * \a path in the filesystem.
 *
 * The retrieved list is placed in \a list, an Erlang list of attribute names.
 *
 * \return On success, `true` is returned. On failure, `false` is returned and
 *         `errno` is set appropriately.
 *
 * \retval list On success, list of attribute names is returned.
 *              On failure, this value is left untouched.
 */
bool listxattr_impl(ErlNifEnv *env, const char *path, ERL_NIF_TERM *list);

/**
 * Checks whether there is extended attribute associated with given \a path in
 * filesystem.
 *
 * \return On success, `true` is returned. On failure, `false` is returned and
 *         `errno` is set appropriately.
 *
 * \retval result On success, this value is set to `true` if there is given
 *                attribute, otherwise `false`. On failure, this value is left
 *                untouched.
 */
bool hasxattr_impl(ErlNifEnv *env, const char *path, const char *name,
                   bool *result);

/**
 * Retrieves the value of the extended attribute identified by \a name and
 * associated with the given \a path in the filesystem. The attribute value is
 * placed in the binary pointed to by \a bin.
 *
 * \return On success, `true` is returned. On failure, `false` is returned and
 *         `errno` is set appropriately.
 *
 * \retval bin On success, attribute value is written to binary pointed by
 *             this argument, which is reallocated if needed.
 *             On failure, this value is not guaranteed to be left untouched.
 */
bool getxattr_impl(ErlNifEnv *env, const char *path, const char *name,
                   ErlNifBinary *bin);

/**
 * Sets the \a value of the extended attribute identified by \a name and
 * associated with the given \a path in the filesystem.
 *
 * \return On success, `true` is returned. On failure, `false` is returned and
 *         `errno` is set appropriately.
 */
bool setxattr_impl(ErlNifEnv *env, const char *path, const char *name,
                   const ErlNifBinary value);

/**
 * Removes the extended attribute identified by \a name and associated with the
 * given \a path in the filesystem.
 *
 * \return On success, `true` is returned. On failure, `false` is returned and
 *         `errno` is set appropriately.
 */
bool removexattr_impl(ErlNifEnv *env, const char *path, const char *name);

/**
 * Constructs Erlang tuple representing system error.
 */
ERL_NIF_TERM make_errno_term(ErlNifEnv *env);

#endif
