import path = require("path");
import { expect, assert } from 'chai';
var fs = require('fs');
const circom_tester = require('circom_tester');
const wasm_tester = circom_tester.wasm;

// TODO: Factor this out into some common code among all the tests
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);


function readFileAndConvertKeys(filePath: string): Array<[bigint, bigint]> {
    // Read the file synchronously
    const fileContent = fs.readFileSync(filePath, 'utf-8');

    // Split the file content by new line
    const lines: string[] = fileContent.trim().split('\n');

    // Map each line to an array of [E, N]
    const result: Array<[bigint, bigint]> = lines.map((line: string): [bigint, bigint] => {
        const [E, N] = line.split(',').map(item => item.trim());
        return [BigInt(E), BigInt(N)];
    });

    return result;
}


function bigint_to_array(n: number, k: number, x: bigint) {
    let mod: bigint = 1n;
    for (var idx = 0; idx < n; idx++) {
        mod = mod * 2n;
    }

    let ret: bigint[] = [];
    var x_temp: bigint = x;
    for (var idx = 0; idx < k; idx++) {
        ret.push(x_temp % mod);
        x_temp = x_temp / mod;
    }
    return ret;
}

function setupInput(numPublicKeys: number, inputContent: String) {
    const inputName = `input_${numPublicKeys}.json`;
    const inputPath = "./";
    const inputFullPath = `${__dirname}/${inputPath}/${inputName}`;
    if (!fs.existsSync(inputFullPath)) {
        
        fs.writeFileSync(inputFullPath, inputContent, 'utf-8');
    }
    else console.log('input already exists, no need to create.');
    return [inputPath, inputName];
}

//The public keys file must be in a structure such as E,N for any given line
const publicKeysfilePath = `${__dirname}/inputKeys.txt`;

console.log("Reading public keys from file.")
let publicKeys = readFileAndConvertKeys(publicKeysfilePath);
const numPublicKeys = publicKeys.length;
console.log(`Number of Public Keys provided:${numPublicKeys}`);


//signature decimal
let sign = BigInt("19970770434011356420695616570275995588733851736092916486111712132583641231522399849078260379017479208895803667652431366593883985802635999227638120171560060271785507252576191070096993051229216860066470378690422171938259912306738962186526007146103769150108002059810205462974903424990722607936274237920270872702180029184401091695395600924057276873789754646380608203609851792334985336197032772780502144607311769527475415342699750160560754943907331155361187938339206488970924682929057116994252391614878690800996605435792148903886765163146205141249146933886278846746712104071544235211937440019023711390224571884634365863432");
// hashed data. decimal
let hashed = BigInt("72155939486846849509759369733266486982821795810448245423168957390607644363272");


let publicKeys_array: bigint[][][] = [];

for (var i=0; i<numPublicKeys; i++) {
    publicKeys_array[i] = [];
    publicKeys_array[i][0] = bigint_to_array(64, 32, publicKeys[i][0]);
    publicKeys_array[i][1] = bigint_to_array(64, 32, publicKeys[i][1]);

}

//This is the first public key in the input file
let publicKeyM = BigInt("26877283975388232002065546470999785257065668437121277626422898829468295994425002534123931915945559617344634299463672464881786335501998933229817362492919530719356197980244178171682568314630456704843964235701169272840827403226569155673809960150900311743961237789646475480998560495177043349952420160197708953986181525637253074713500260384690148853022580356324720561179472725807442763843755515338818629917380201208369993837646911190634717770914200111131983791094934970474752204714209363619762523501868989404033152536987791077018610508510651331541408664242381532359216354015898457615549908800129418374861154322861098417303");
let publicKeyExp = BigInt(65537);

let publicKey_array: bigint[][] = [bigint_to_array(64, 32, publicKeyExp), bigint_to_array(64, 32, publicKeyM)];

let sign_array: bigint[] = bigint_to_array(64, 32, sign);
let hashed_array: bigint[] = bigint_to_array(64, 4, hashed);

let content = `{
            "publicKeys":${JSON.stringify(publicKeys_array)},
            "sign":${JSON.stringify(sign_array)},
            "hashed":${JSON.stringify(hashed_array)},
            "publicKey":${JSON.stringify(publicKey_array)}
            }`;
     
console.log('Setting up input JSON...')
console.log("\n");
console.log(content);
console.log("\n");

const [inputPath, inputName] = setupInput(numPublicKeys, content);
console.log(`Input JSON set up: ${inputName} at ${inputPath}`);
            