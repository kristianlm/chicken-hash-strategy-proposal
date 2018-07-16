;;;; sha2-test.scm
(import test)

(let ()
  (import (hash sha256))

  (test-group "Strings"

              (test-group "Bits 256"
		          (test "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" (message-digest-string (sha256-primitive) "abc"))
		          (test "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1" (message-digest-string (sha256-primitive) "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
                          )

              (test-group "Bits 384"
		          (test "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7" (message-digest-string (sha384-primitive) "abc"))
		          (test "3391fdddfc8dc7393707a65b1b4709397cf8b1d162af05abfe8f450de5f36bc6b0455a8520bc4e6f5fe95b1fe3c8452b" (message-digest-string (sha384-primitive) "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
                          )

              (test-group "Bits 512"
		          (test "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f" (message-digest-string (sha512-primitive) "abc"))
		          (test "204a8fc6dda82f0a0ced7beb8e08a41657c16ef468b228a8279be331a703c33596fd15c13b1b07f9aa1d3bea57789ca031ad85c7a71dd70354ec631238ca3445" (message-digest-string (sha512-primitive) "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
                          )
              )

  (print init))



(test-exit)
