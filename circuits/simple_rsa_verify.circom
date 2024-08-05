pragma circom 2.0.0;

include "./pow_mod.circom";
//include "../circomlib/circuits/comparators.circom";

template NumToBits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

// Pkcs1v15 + Sha256
// exp 65537
template simple_RsaVerifyPkcs1v15(w, nb, e_bits, hashLen) {
    signal input exp[nb];
    signal input sign[nb];
    signal input modulus[nb];

    signal input hashed[hashLen];

    signal output out[32];

    // sign ** exp mod modulus
    component pm = PowerMod(w, nb, e_bits);
    for (var i  = 0; i < nb; i++) {
        pm.base[i] <== sign[i];
        pm.exp[i] <== exp[i];
        pm.modulus[i] <== modulus[i];
    }


    signal interm[32];

    //signal aux = 0; //aux will be 1 if at any time the subtraction of bytes doesnt equal 0 

    //var diff = 0;

    // 1. Check hashed data
    // 64 * 4 = 256 bit. the first 4 numbers
    component lessThan[32];
    for (var i = 0; i < hashLen; i++) {
        lessThan[i] = LessThan(64);
        lessThan[i].in[0] <== pm.out[i];
        lessThan[i].in[1] <== hashed[i];
        var less = lessThan[i].out;
        var bigger = less * (pm.out[i] - hashed[i]);
        var lesser = less * (hashed[i] - pm.out[i]);
        interm[i] <== bigger + lesser;        
    }

    // 2. Check hash prefix and 1 byte 0x00
    // sha256/152 bit
    // 0b00110000001100010011000000001101000001100000100101100000100001100100100000000001011001010000001100000100000000100000000100000101000000000000010000100000
    // and remain 24 bit
    // 3. Check PS and em[1] = 1. the same code like golang std lib rsa.VerifyPKCS1v15
    var hashprefix[3] = [217300885422736416, 938447882527703397, 18446744069417742640];
    //var hashprefixIdx = 0;
    for (var i = 4; i<7; i++) {
        lessThan[i] = LessThan(64);
        lessThan[i].in[0] <== pm.out[i];
        lessThan[i].in[1] <== hashprefix[i-4];
        var less = lessThan[i].out;
        var bigger = less * (pm.out[i] - hashprefix[i-4]);
        var lesser = less * (hashprefix[i-4] - pm.out[i]);
        interm[i] <== bigger + lesser;
    }

    var ff = 18446744073709551615;
    for (var i = 7; i < 31; i++) {
        // 0b1111111111111111111111111111111111111111111111111111111111111111
        lessThan[i] = LessThan(64);
        lessThan[i].in[0] <== pm.out[i];
        lessThan[i].in[1] <== ff;
        var less = lessThan[i].out;
        var bigger = less * (pm.out[i] - ff);
        var lesser = less * (ff - pm.out[i]);
        interm[i] <== bigger + lesser;
    }

    // 0b1111111111111111111111111111111111111111111111111
    var paddingStart = 562949953421311;
    lessThan[31] = LessThan(64);
        lessThan[31].in[0] <== pm.out[31];
        lessThan[31].in[1] <== paddingStart;
        var less = lessThan[31].out;
        var bigger = less * (pm.out[31] - paddingStart);
        var lesser = less * (paddingStart - pm.out[31]);
        interm[31] <== bigger + lesser;

    //-------------result-------------

    out[0] <== interm[0];

    //we can add all numbers because even though they are 64 bit, 32*(2**64) is only under 70 bits < 254 and therefore circom can handle it.
    for (var i=1; i<31; i++) {
        out[i] <== out[i-1]+interm[i];
    }

    out[31] <== out[30]+interm[31];

    //Comment this out before going for group signatures:
    out[31] === 0;

}

