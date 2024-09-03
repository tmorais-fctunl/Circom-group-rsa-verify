pragma circom 2.0.0;
 
include "../circom-ecdsa/circuits/bigint.circom";
// w = 32
// base ** exp mod modulus
// nb is the length of the input number
// exp = 65537
template PowerMod(w, nb, e_bits) {
    signal input base[nb];
    signal input exp[nb];
    signal input modulus[nb];

    signal output out[nb];
    
   
    component muls[e_bits + 2];
    for (var i = 0; i < e_bits + 2; i++) {
        muls[i] = BigMultModP(w, nb); //this is merely a*b mod p
        // modulus params
        for (var j = 0; j < nb; j++) {
            muls[i].p[j] <== modulus[j];
        }
    }

    // result/base muls component index
    var result_index=0;
    var base_index=0;
    var muls_index=0;
    for (var i = 0; i< e_bits; i++) {
        if (i == 0 || i == e_bits - 1) {
           if (i == 0) {
               for(var j = 0; j < nb; j ++) {
                    if (j == 0) {
                        muls[muls_index].a[j] <== 1; //muls[0].a[0] = 1
                    } else {
                        muls[muls_index].a[j] <== 0; //muls[0].a[1..nb] = 0
                    }
                    muls[muls_index].b[j] <== base[j]; //muls[0].b = base
               }
           } else {
               for(var j = 0; j < nb; j++) {
                   muls[muls_index].a[j] <== muls[result_index].out[j]; //muls[e_bits-1].a = 
                   muls[muls_index].b[j] <== muls[base_index].out[j];
               }
           }
            result_index = muls_index;
            muls_index++;
        }

        if (base_index == 0) {
             for (var j = 0; j < nb; j++) {
                 muls[muls_index].a[j] <== base[j];
                 muls[muls_index].b[j] <== base[j];
             }
        } else {
             for (var j = 0; j < nb; j++) {
                 muls[muls_index].a[j] <== muls[base_index].out[j];
                 muls[muls_index].b[j] <== muls[base_index].out[j];
             }
        }
        base_index = muls_index;
        muls_index++;
    }

    for (var i = 0; i < nb; i++) {
        out[i] <== muls[result_index].out[i];
    }
}

/**

snarkJS: Curve: bn-128
[INFO]  snarkJS: # of Wires: 530672
[INFO]  snarkJS: # of Constraints: 536212
[INFO]  snarkJS: # of Private Inputs: 96
[INFO]  snarkJS: # of Public Inputs: 0
[INFO]  snarkJS: # of Labels: 583695
[INFO]  snarkJS: # of Outputs: 32

**/
