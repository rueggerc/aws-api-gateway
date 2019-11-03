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

    it("Generate Token", function() {
        let user = "chris";
        let password = "dakota";
        let authString = `${user}:${password}`;
        console.log("authString=" + authString);
        let authToken = `Basic ${Buffer.from(authString).toString('base64')}`;
        console.log("authToken=" + authToken);
    });

    // Basic TkF0TzAwMD3%RTo1NzA4MDEwNDM=

    it("Decode Token1", function() {
        let token = "Basic TkFOTzAwMDE5RTo1NzA4MDEwNDM=";
        let splitArray = token.split("Basic ");
        let decodedString = Buffer.from(splitArray[1],'base64').toString();
        console.log("Decoded String=" + decodedString);
    });

    it("Decode Token2", function() {
        let token = "Basic Y2hyaXM6ZGFrb3Rh";
        let splitArray = token.split("Basic ");
        let decodedString = Buffer.from(splitArray[1],'base64').toString();
        console.log("Decoded String=" + decodedString);
    });

});
