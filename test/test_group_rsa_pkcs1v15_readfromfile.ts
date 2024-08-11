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

function setupCircuit(numPublicKeys: number) {
    const circuitName = `group_rsa_verify_pkcs1v15_nkeys_${numPublicKeys}.circom`;
    const circuitPath = "circuits/groupSignatureVaryingKeys";
    const circuitFullPath = `${__dirname}/${circuitPath}/${circuitName}`;
    if (!fs.existsSync(circuitFullPath)) {
        const circuitContent = `pragma circom 2.0.0;
        include "../../../circuits/group_sig_rsa_verify.circom";
        component main{public [publicKeys, hashed]} = GroupRsaVerifyPkcs1v15(64, 32, 17, 4, ${numPublicKeys});`;
        
        fs.writeFileSync(circuitFullPath, circuitContent, 'utf-8');
    }
    else console.log('Circuit already exists, no need to create.');
    return [circuitPath, circuitName];
}

//The public keys file must be in a structure such as E,N for any given line
const publicKeysfilePath = `${__dirname}/inputKeys.txt`;

console.log("Reading public keys from file.")
let publicKeys = readFileAndConvertKeys(publicKeysfilePath);
const numPublicKeys = publicKeys.length;
console.log(`Number of Public Keys provided:${numPublicKeys}`);

console.log('Setting up circuit...')
const [circuitPath, circuitName] = setupCircuit(numPublicKeys);
console.log(`Circuit set up: ${circuitName}`);

describe(`Test rsa group signature with pkcs1v15 n = 64, k = 32, nPk = ${numPublicKeys}`, function () {
    this.timeout(1000 * 1000);

    // runs circom compilation
    let circuit: any;
    before(async function () {
        circuit = await wasm_tester(path.join(__dirname, circuitPath, circuitName));
    });

    // a, e, m, (a ** e) % m
    let test_cases: Array<[bigint[][], bigint, bigint]> = [];
    
    //for testing purposes:
    //correct:
    /*let m = [
        BigInt("26877283975388232002065546470999785257065668437121277626422898829468295994425002534123931915945559617344634299463672464881786335501998933229817362492919530719356197980244178171682568314630456704843964235701169272840827403226569155673809960150900311743961237789646475480998560495177043349952420160197708953986181525637253074713500260384690148853022580356324720561179472725807442763843755515338818629917380201208369993837646911190634717770914200111131983791094934970474752204714209363619762523501868989404033152536987791077018610508510651331541408664242381532359216354015898457615549908800129418374861154322861098417303"),
        BigInt("27333278531038650284292446400685983964543820405055158402397263907659995327446166369388984969315774410223081038389734916442552953312548988147687296936649645550823280957757266695625382122565413076484125874545818286099364801140117875853249691189224238587206753225612046406534868213180954324992542640955526040556053150097561640564120642863954208763490114707326811013163227280580130702236406906684353048490731840275232065153721031968704703853746667518350717957685569289022049487955447803273805415754478723962939325870164033644600353029240991739641247820015852898600430315191986948597672794286676575642204004244219381500407"),
    ];*/

    //wrong:
    /*let m = [
        BigInt("26877283975388232002065546470999785257065668437121277626422898829468295994425002534123931915945559617344634299463672464881786335501998933229817362492919530719356147980244178171682568314630456704843964235701169272840827403226569155673809960150900311743961237789646475480998560495177043349952420160197708953986181525637253074713500260384690148853022580356324720561179472725807442763843755515338818629917380201208369993837646911190634717770914200111131983791094934970474752204714209363619762523501868989404033152536987791077018610508510651331541408664242381532359216354015898457615549908800129418374861154322861098417303"),
        BigInt("27333278531038650284292446400685983964543820405055158402397263907659995327446166369388984969315774410223081038389734916442552953312548988147687296936649645550823240957757266695625382122565413076484125874545818286099364801140117875853249691189224238587206753225612046406534868213180954324992542640955526040556053150097561640564120642863954208763490114707326811013163227280580130702236406906684353048490731840275232065153721031968704703853746667518350717957685569289022049487955447803273805415754478723962939325870164033644600353029240991739641247820015852898600430315191986948597672794286676575642204004244219381500407"),
    ];
    */
    /*let exp = [
        BigInt(65537),
        BigInt(65537)
    ]*/
    
    let sign = BigInt("19970770434011356420695616570275995588733851736092916486111712132583641231522399849078260379017479208895803667652431366593883985802635999227638120171560060271785507252576191070096993051229216860066470378690422171938259912306738962186526007146103769150108002059810205462974903424990722607936274237920270872702180029184401091695395600924057276873789754646380608203609851792334985336197032772780502144607311769527475415342699750160560754943907331155361187938339206488970924682929057116994252391614878690800996605435792148903886765163146205141249146933886278846746712104071544235211937440019023711390224571884634365863432");
    // hashed data. decimal
    let hashed = BigInt("72155939486846849509759369733266486982821795810448245423168957390607644363272");


    test_cases.push([publicKeys, sign, hashed]);

    let test_rsa_verify = function (x: [bigint[][], bigint, bigint]) {
        const [publicKeys, sign, hashed] = x;

        const numPublicKeys = publicKeys.length;

        let publicKeys_array: bigint[][][] = [];

        for (var i=0; i<numPublicKeys; i++) {
            publicKeys_array[i] = [];
            publicKeys_array[i][0] = bigint_to_array(64, 32, publicKeys[i][0]);
            publicKeys_array[i][1] = bigint_to_array(64, 32, publicKeys[i][1]);

        }

        let sign_array: bigint[] = bigint_to_array(64, 32, sign);
        let hashed_array: bigint[] = bigint_to_array(64, 4, hashed);

        /*
        console.log("exp"+exp_array);
        console.log("sign"+sign_array);
        console.log("modulus"+m_array);
        console.log("hashed"+hashed_array);
        */

        /*console.log("Input file:");
        console.log(`{
            "publicKeys":${publicKeys_array},
            "sign":${sign_array},
            "hashed":${hashed_array}
            }`);
        */

        it('Testing ', async function () {
            let witness = await circuit.calculateWitness({
                "publicKeys": publicKeys_array,
                "sign": sign_array,
                "hashed": hashed_array
            });

            await circuit.checkConstraints(witness);
            //let output = await circuit.getDecoratedOutput(witness);
            //console.log(output);
            //await circuit.getDecoratedOutput(witness);
        });
    }

    test_cases.forEach(test_rsa_verify);
});