module.exports.handler = async function (event,context,callback) {

    console.log("Sensor API Authorizer BEGIN");
    
    try {  
        console.log("==== AUTHORIZATION LAMBDA BEGIN====");
        console.log("EVENT=\n" + JSON.stringify(event,null,4));
  
        // Get the Authorization Token and Endpoint
        let token = event.authorizationToken;
        let resource = event.methodArn;
  
        let response = {};
        response.principalId = "sensor-api-user";
        response.context = {stringKey: 'Basic XYZ'};
  
        // Get the policy
        let policyDocument = generatePolicy(resource,token);
        response.policyDocument = policyDocument;
        // console.log("GOT POLICY=\n" + JSON.stringify(response,null,4));
  
        // Done
        return response;
        
    } catch (err) {
        // Authentication failure or any failure
        console.log("ERROR:\n" + err);
        return("Unauthorized");
    
    } 
};
  
function generatePolicy(resource,token) {
    let effect = "Allow";
    let policyDocument = {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "execute-api:Invoke",
          "Effect": effect,
          "Resource": resource
        }
      ]
    };
    return policyDocument;
}
  