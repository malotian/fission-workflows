'use strict';

const rp = require('request-promise-native');

module.exports = async function (context) {
    const stringBody = JSON.stringify(context.request.body);
    const body = JSON.parse(stringBody);

        return {
            status: 200,
            body: {
                text: `hello ${stringBody} `
            },
            headers: {
                'Content-Type': 'application/json'
            }
        };
}

