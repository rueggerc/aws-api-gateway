"use strict";
const assert = require('chai').assert;
const expect = require('chai').expect;
const index = require("../src/index");
const sinon = require("sinon");

let sandbox = null;

describe("Test API Gateway Authorizer", function() {
    this.timeout(10000);

    before(async function() {
    });
    after(async function() {
    });

    beforeEach(function() {
        sandbox = sinon.createSandbox();
    });
    
    afterEach(function() {
        sandbox.restore();
    });

    it("Successful Authorization", function() {
        let event = {
            "type": "TOKEN",
            "authorizationToken": "Basic XYZ",
            "methodArn": "arn:aws:execute-api:us-east-1:123456:w63xjssnw/dev/GET/sensor-data"
        }
        return new Promise((resolve,reject) => {
            index.handler(event,null,null)
            .then(function(response) {
                assert.isNotNull(response);
                let effect = response.policyDocument.Statement[0].Effect;
                assert.equal(effect,"Allow");
                resolve();               
            })
            .catch(function(error) {
                console.log("CATCH!");
                // assert.isNotOk(error,'Promise Error');
                reject(error);
            });
        });
    });

});
