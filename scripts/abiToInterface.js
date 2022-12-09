var fs = require('fs');
const infinityAbi = require('../abi/KlimaInfinity.json');


function parseItem(i) {
    let line = `${i.type} ${i.name}(`
    line = i.inputs.reduce((acc, input) => {
        acc = `${acc}${input.type} ${input.name}, `
        return acc;
    }, line)
    if (i.inputs.length > 0)
        line = `${line.substring(0, line.length - 2)}`
    line = `${line})`
    if (i.stateMutability) {
        line = `${line} external ${i.stateMutability}`
    }

    return `${line};`
}

function rip() {
    for (let i = 0; i < infinityAbi.length; i++) {
        if (infinityAbi[i].type == 'function') {
            console.log(parseItem(infinityAbi[i]))
        }
    }

    console.log('\n')

    for (let i = 0; i < infinityAbi.length; i++) {
        if (infinityAbi[i].type == 'event') {
            console.log(parseItem(infinityAbi[i]))
        }
    }
}

rip()
