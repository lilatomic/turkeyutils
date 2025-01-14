# cython: language_level=3
#
# Copyright (c) SAS Institute Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from cython.cimports.keyutils import ckeyutils
from cython.cimports.keyutils.ckeyutils import gid_t, key_serial_t, uid_t
from libc cimport stdlib


cdef extern from "Python.h":
    object PyErr_SetFromErrno(exc)
    object PyBytes_FromStringAndSize(char *str, Py_ssize_t size)

class error(Exception):
    pass


class constants:
    KEY_SPEC_THREAD_KEYRING = ckeyutils.KEY_SPEC_THREAD_KEYRING
    KEY_SPEC_PROCESS_KEYRING = ckeyutils.KEY_SPEC_PROCESS_KEYRING
    KEY_SPEC_SESSION_KEYRING = ckeyutils.KEY_SPEC_SESSION_KEYRING
    KEY_SPEC_USER_KEYRING = ckeyutils.KEY_SPEC_USER_KEYRING
    KEY_SPEC_USER_SESSION_KEYRING = ckeyutils.KEY_SPEC_USER_SESSION_KEYRING
    KEY_SPEC_GROUP_KEYRING = ckeyutils.KEY_SPEC_GROUP_KEYRING
    KEY_SPEC_REQKEY_AUTH_KEY = ckeyutils.KEY_SPEC_REQKEY_AUTH_KEY

    KEY_POS_VIEW = ckeyutils.KEY_POS_VIEW
    KEY_POS_READ = ckeyutils.KEY_POS_READ
    KEY_POS_WRITE = ckeyutils.KEY_POS_WRITE
    KEY_POS_SEARCH = ckeyutils.KEY_POS_SEARCH
    KEY_POS_LINK = ckeyutils.KEY_POS_LINK
    KEY_POS_SETATTR = ckeyutils.KEY_POS_SETATTR
    KEY_POS_ALL = ckeyutils.KEY_POS_ALL

    KEY_USR_VIEW = ckeyutils.KEY_USR_VIEW
    KEY_USR_READ = ckeyutils.KEY_USR_READ
    KEY_USR_WRITE = ckeyutils.KEY_USR_WRITE
    KEY_USR_SEARCH = ckeyutils.KEY_USR_SEARCH
    KEY_USR_LINK = ckeyutils.KEY_USR_LINK
    KEY_USR_SETATTR = ckeyutils.KEY_USR_SETATTR
    KEY_USR_ALL = ckeyutils.KEY_USR_ALL

    KEY_GRP_VIEW = ckeyutils.KEY_GRP_VIEW
    KEY_GRP_READ = ckeyutils.KEY_GRP_READ
    KEY_GRP_WRITE = ckeyutils.KEY_GRP_WRITE
    KEY_GRP_SEARCH = ckeyutils.KEY_GRP_SEARCH
    KEY_GRP_LINK = ckeyutils.KEY_GRP_LINK
    KEY_GRP_SETATTR = ckeyutils.KEY_GRP_SETATTR
    KEY_GRP_ALL = ckeyutils.KEY_GRP_ALL

    KEY_OTH_VIEW = ckeyutils.KEY_OTH_VIEW
    KEY_OTH_READ = ckeyutils.KEY_OTH_READ
    KEY_OTH_WRITE = ckeyutils.KEY_OTH_WRITE
    KEY_OTH_SEARCH = ckeyutils.KEY_OTH_SEARCH
    KEY_OTH_LINK = ckeyutils.KEY_OTH_LINK
    KEY_OTH_SETATTR = ckeyutils.KEY_OTH_SETATTR
    KEY_OTH_ALL = ckeyutils.KEY_OTH_ALL

    ENOKEY = ckeyutils.ENOKEY
    EKEYEXPIRED = ckeyutils.EKEYEXPIRED
    EKEYREVOKED = ckeyutils.EKEYREVOKED
    EKEYREJECTED = ckeyutils.EKEYREJECTED

    KEYCTL_MOVE_EXCL = ckeyutils.KEYCTL_MOVE_EXCL

    KEYCTL_CAPS0_CAPABILITIES = ckeyutils.KEYCTL_CAPS0_CAPABILITIES
    KEYCTL_CAPS0_PERSISTENT_KEYRINGS = ckeyutils.KEYCTL_CAPS0_PERSISTENT_KEYRINGS
    KEYCTL_CAPS0_DIFFIE_HELLMAN = ckeyutils.KEYCTL_CAPS0_DIFFIE_HELLMAN
    KEYCTL_CAPS0_PUBLIC_KEY = ckeyutils.KEYCTL_CAPS0_PUBLIC_KEY
    KEYCTL_CAPS0_BIG_KEY = ckeyutils.KEYCTL_CAPS0_BIG_KEY
    KEYCTL_CAPS0_INVALIDATE = ckeyutils.KEYCTL_CAPS0_INVALIDATE
    KEYCTL_CAPS0_RESTRICT_KEYRING = ckeyutils.KEYCTL_CAPS0_RESTRICT_KEYRING
    KEYCTL_CAPS0_MOVE = ckeyutils.KEYCTL_CAPS0_MOVE
    # KEYCTL_CAPS1_NS_KEYRING_NAME = ckeyutils.KEYCTL_CAPS1_NS_KEYRING_NAME
    # KEYCTL_CAPS1_NS_KEY_TAG = ckeyutils.KEYCTL_CAPS1_NS_KEY_TAG
    # KEYCTL_CAPS1_NOTIFICATIONS = ckeyutils.KEYCTL_CAPS1_NOTIFICATIONS

def _throw_err(int rc):
    if rc < 0:
        PyErr_SetFromErrno(error)
    else:
        return rc

def add_key(bytes key_type, bytes description, bytes payload, int keyring):
    cdef int rc
    cdef char *key_type_p = key_type
    cdef char *desc_p = description
    cdef int payload_len
    cdef char *payload_p
    if payload is None:
        payload_p = NULL
        payload_len = 0
    else:
        payload_p = payload
        payload_len = len(payload)
    with nogil:
        rc = ckeyutils.add_key(key_type_p, desc_p, payload_p, payload_len, keyring)
    return _throw_err(rc)

def request_key(bytes key_type, bytes description, bytes callout_info, int keyring):
    cdef char *key_type_p = key_type
    cdef char *desc_p = description
    cdef char *callout_p
    cdef int rc
    if callout_info is None:
        callout_p = NULL
    else:
        callout_p = callout_info
    with nogil:
        rc = ckeyutils.request_key(key_type_p, desc_p, callout_p, keyring)
    return _throw_err(rc)

def get_keyring_id(int keyring, bint create) -> int:
    cdef int rc
    with nogil:
        rc = ckeyutils.get_keyring_id(keyring, create)
    return _throw_err(rc)

def join_session_keyring(name):
    cdef char *name_p
    cdef int rc
    if name is None:
        name_p = NULL
    else:
        name_p = name
    with nogil:
        rc = ckeyutils.join_session_keyring(name_p)
    return _throw_err(rc)

def update_key(int key, bytes payload):
    cdef int rc
    cdef int payload_len
    cdef char *payload_p
    if payload is None:
        payload_p = NULL
        payload_len = 0
    else:
        payload_p = payload
        payload_len = len(payload)
    with nogil:
        rc = ckeyutils.update(key, payload_p, payload_len)
    _throw_err(rc)
    return None

def revoke(int key):
    cdef int rc
    with nogil:
        rc = ckeyutils.revoke(key)
    _throw_err(rc)
    return None

def chown(key_serial_t key, uid_t uid, gid_t gid) -> int:
    cdef int rc
    with nogil:
        rc = ckeyutils.chown(key, uid, gid)
    return _throw_err(rc)

def set_perm(int key, int perm):
    cdef int rc
    cdef int keyperm
    with nogil:
        rc = ckeyutils.setperm(key, perm)
    _throw_err(rc)
    return None

def clear(int keyring):
    cdef int rc
    with nogil:
        rc = ckeyutils.clear(keyring)
    _throw_err(rc)
    return None

def link(int key, int keyring):
    cdef int rc
    with nogil:
        rc = ckeyutils.link(key, keyring)
    _throw_err(rc)
    return None

def unlink(int key, int keyring):
    cdef int rc
    with nogil:
        rc = ckeyutils.unlink(key, keyring)
    _throw_err(rc)
    return None

def search(int keyring, bytes key_type, bytes description, int destination):
    cdef char *key_type_p = key_type
    cdef char *desc_p = description
    cdef int rc
    with nogil:
        rc = ckeyutils.search(keyring, key_type_p, desc_p, destination)
    return _throw_err(rc)

def instantiate(int key, bytes payload, int keyring):
    cdef int rc
    cdef int payload_len
    cdef char *payload_p
    if payload is None:
        payload_p = NULL
        payload_len = 0
    else:
        payload_p = payload
        payload_len = len(payload)
    with nogil:
        rc = ckeyutils.instantiate(key, payload_p, payload_len, keyring)
    _throw_err(rc)
    return None

def negate(int key, unsigned int timeout, int keyring):
    cdef int rc
    with nogil:
        rc = ckeyutils.negate(key, timeout, keyring)
    _throw_err(rc)
    return None

def set_timeout(int key, int timeout):
    cdef int rc
    with nogil:
        rc = ckeyutils.set_timeout(key, timeout)
    _throw_err(rc)
    return None

def assume_authority(int key):
    cdef int rc
    with nogil:
        rc = ckeyutils.assume_authority(key)
    _throw_err(rc)
    return None

def session_to_parent():
    cdef int rc
    with nogil:
        rc = ckeyutils.session_to_parent()
    _throw_err(rc)
    return None

def reject(int key, unsigned int timeout, unsigned int error, int keyring):
    cdef int rc
    with nogil:
        rc = ckeyutils.reject(key, timeout, error, keyring)
    _throw_err(rc)
    return None

def invalidate(int key):
    cdef int rc
    with nogil:
        rc = ckeyutils.invalidate(key)
    _throw_err(rc)
    return None

def get_persistent(int uid, int key):
    cdef int rc
    with nogil:
        rc = ckeyutils.get_persistent(uid, key)
    return _throw_err(rc)

def dh_compute(int key_priv, int key_prime, int key_base):
    cdef int size
    cdef void *ptr
    cdef bytes obj
    with nogil:
        size = ckeyutils.dh_compute_alloc(key_priv, key_prime, key_base, &ptr)
    if size < 0:
        PyErr_SetFromErrno(error)
    else:
        obj = PyBytes_FromStringAndSize(<char *> ptr, size)
        stdlib.free(ptr)
        return obj

def dh_compute_kdf(int key_priv, int key_prime, int key_base, bytes hashname, int buflen, bytes otherinfo = None):
    cdef int rc
    cdef int otherinfo_len
    cdef char *hashname_p = hashname
    cdef char *otherinfo_p
    cdef char *buffer = <char *> stdlib.malloc(buflen)
    cdef bytes obj

    if otherinfo is None:
        otherinfo_p = NULL
        otherinfo_len = 0
    else:
        otherinfo_p = otherinfo
        otherinfo_len = len(otherinfo)

    with nogil:
        rc = ckeyutils.dh_compute_kdf(key_priv, key_prime, key_base, hashname_p, otherinfo_p, otherinfo_len, buffer, buflen)
    _throw_err(rc)
    # TODO: check we aren't leaving buffer allocated
    obj = PyBytes_FromStringAndSize(<char *> buffer, buflen)
    return obj

def restrict_keyring(int keyring, bytes key_type, bytes restriction):
    cdef int rc
    cdef char *type_p
    cdef char *restriction_p

    if key_type is None:
        type_p = NULL
    else:
        type_p = key_type

    if restriction is None:
        restriction_p = NULL
    else:
        restriction_p = restriction

    with nogil:
        rc = ckeyutils.restrict_keyring(keyring, type_p, restriction_p)
    _throw_err(rc)
    return None

def pkey_query(int key, bytes info):
    cdef int rc
    cdef const char * info_p = info
    cdef ckeyutils.keyctl_pkey_query result
    with nogil:
        rc = ckeyutils.pkey_query(key, info_p, &result)
    _throw_err(rc)
    return result

# TODO: proper output buffer length
# TODO: read bytes written from RC
def pkey_encrypt(int key, bytes info, bytes data):
    cdef int rc
    cdef const char *info_p = info
    cdef const char *data_p = data
    cdef int data_len = len(data)
    cdef void *enc_p = stdlib.malloc(256)
    cdef int enc_len = 256
    cdef bytes obj
    with nogil:
        rc = ckeyutils.pkey_encrypt(
            key, info_p, data_p, data_len, enc_p, enc_len
        )
    _throw_err(rc)
    # TODO: check we aren't leaving buffer allocated
    obj = PyBytes_FromStringAndSize(<char *> enc_p, enc_len)
    return obj

def pkey_decrypt(int key, bytes info, bytes enc):
    cdef int rc
    cdef const char *info_p = info
    cdef const char *enc_p = enc
    cdef int enc_len = len(enc)
    cdef void *data_p = stdlib.malloc(256)
    cdef int data_len = 256  # TODO: actually query this
    cdef bytes obj
    with nogil:
        rc = ckeyutils.pkey_decrypt(
            key, info_p, enc_p, enc_len, data_p, data_len
        )
    _throw_err(rc)
    # TODO: check we aren't leaving buffer allocated
    obj = PyBytes_FromStringAndSize(<char *> data_p, data_len)
    return obj

def pkey_sign(int key, bytes info, bytes data):
    cdef int rc
    cdef const char *info_p = info
    cdef const char *data_p = data
    cdef int data_len = len(data)
    cdef void *sig_p = stdlib.malloc(256)
    cdef int sig_len = 256  # TODO: actually query this
    cdef bytes obj

    with nogil:
        rc = ckeyutils.pkey_sign(
            key, info_p, data_p, data_len, sig_p, sig_len
        )
    _throw_err(rc)
    # TODO: check we aren't leaving buffer allocated
    obj = PyBytes_FromStringAndSize(<char *> sig_p, sig_len)
    return obj

def pkey_verify(int key, bytes info, bytes data, bytes sig):
    cdef int rc
    cdef const char *info_p = info
    cdef const char *data_p = data
    cdef int data_len = len(data)
    cdef const char *sig_p = sig
    cdef int sig_len = len(sig)
    cdef bytes obj
    with nogil:
        rc = ckeyutils.pkey_verify(
            key, info_p, data_p, data_len, <void *> sig_p, sig_len
        )
    return _throw_err(rc)

def move(int key, int from_ringid, int to_ringid, unsigned int flags):
    cdef int rc
    with nogil:
        rc = ckeyutils.move(key, from_ringid, to_ringid, flags)
    _throw_err(rc)
    return None


def capabilities():
    cdef int rc
    cdef int buflen = 4
    cdef unsigned char *buffer = <unsigned char *> stdlib.malloc(buflen)
    cdef bytes obj
    with nogil:
        rc = ckeyutils.capabilities(buffer, buflen)
    _throw_err(rc)
    # TODO: check we aren't leaving buffer allocated
    obj = PyBytes_FromStringAndSize(<char *> buffer, buflen)
    return obj


def describe_key(int key):
    cdef int size
    cdef char *ptr
    cdef bytes obj
    with nogil:
        size = ckeyutils.describe_alloc(key, &ptr)
    if size < 0:
        PyErr_SetFromErrno(error)
    else:
        obj = PyBytes_FromStringAndSize(<char *> ptr, size)
        stdlib.free(ptr)
        return obj

def read_key(int key):
    cdef int size
    cdef void *ptr
    cdef bytes obj
    with nogil:
        size = ckeyutils.read_alloc(key, &ptr)
    if size < 0:
        PyErr_SetFromErrno(error)
    else:
        obj = PyBytes_FromStringAndSize(<char *> ptr, size)
        stdlib.free(ptr)
        return obj

def get_security(int key):
    cdef int size
    cdef char *ptr
    cdef bytes obj
    with nogil:
        size = ckeyutils.get_security_alloc(key, &ptr)
    print(size)
    if size < 0:
        PyErr_SetFromErrno(error)
    else:
        obj = PyBytes_FromStringAndSize(ptr, size)
        stdlib.free(ptr)
        return obj
