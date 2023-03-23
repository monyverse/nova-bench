/*
    Copyright 2018 0KIMS association.

    This file is part of circom (Zero Knowledge Circuit Compiler).

    circom is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    circom is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with circom. If not, see <https://www.gnu.org/licenses/>.
*/

pragma circom 2.0.3;

include "sha256_bytes.circom";

// Identical to https://raw.githubusercontent.com/celer-network/zk-benchmark/main/circom/circuits/sha256_test/sha256_test.circom
template Sha256Test(N) {

    signal input in[N];
    signal input hash[32];
    signal output out[32];

    component sha256 = Sha256Bytes(N);
    sha256.in <== in;
    out <== sha256.out;

    for (var i = 0; i < 32; i++) {
        out[i] === hash[i];
    }

    log("start ================");
    for (var i = 0; i < 32; i++) {
        log(out[i]);
    }
    log("finish ================");
}
 
// TODO: Treat first iteration separately? For arbitrary input
// N is the length of the input, K is the number of times to hash
// Can only declare components inside conditions if condition is known at compile time, so removing k
template RecursiveShaTest(N) {
    var depth = 5;

    signal input in[N];
    signal input hash[32];
    signal output out[32];

    signal value[depth+1][N];

    component hasher[depth];

    value[0] <== in;

    // Loop until DEPTH, taking output of Sha256 and using as input in next
    // Then ensure that the final output is the same as the expected hash
    for (var i = 0; i < depth; i++) {
        hasher[i] = Sha256Bytes(N);
        hasher[i].in <== value[i];

        value[i+1] <== hasher[i].out;
    }

    out <== value[depth];
}

template Main() {
    signal input in[32];
    signal input hash[32];
    signal output out[32];

    component chainedSha = RecursiveShaTest(32);
    chainedSha.in <== in;
    chainedSha.hash <== hash;

    // FIXME: The final outptu should be the inputed hash!
    out <== chainedSha.out;

}

component main = Main();