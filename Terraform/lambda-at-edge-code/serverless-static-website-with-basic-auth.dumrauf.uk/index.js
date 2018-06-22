'use strict';


exports.handler = (event, context, callback) => {

    // Credentials definition - customise to fit your needs
    const credentials = {
        'guest': 'letmein'
    };

    // Placeholder list which eventually holds all credential strings
    let credential_strings = [];

    // Construct all credential strings and add to corresponding list
    for (let user in credentials) {
        const password = credentials[user];
        const auth_string = 'Basic ' + new Buffer(user + ':' + password).toString('base64');
        credential_strings.push(auth_string);
    }

    // Get request and request headers
    const request = event.Records[0].cf.request;
    const headers = request.headers;


    // Validate Basic Authentication
    if (typeof headers.authorization == 'undefined' || credential_strings.indexOf(headers.authorization[0].value) === -1) {
        const response = {
            status: '401',
            statusDescription: 'Unauthorized',
            body: 'Unauthorized',
            headers: {
                'www-authenticate': [{key: 'WWW-Authenticate', value:'Basic'}]
            },
        };
        callback(null, response);
    }

    // Return request in case Basic Authentication passed
    callback(null, request);
};