const sendTraceToLevo = async event => {
    try {
        const orgId = process.env.LEVO_ORG_ID
        const tracesEndpoint = process.env.LEVO_TRACES_ENDPOINT ?? "https://collector.levo.ai"
        
        await fetch(`${tracesEndpoint}/v1/cloudfront-event`, {
            method: "POST",
            headers: {
              'content-type': 'application/json',
              'x-levo-organization-id': orgId
            },
            body: JSON.stringify(event.Records[0].cf)
        })
    }
    catch (e) {
        console.error(e)
    }
}

// For CloudFront origin-request events
export const requestHandler = async event => {
    await sendTraceToLevo(event);
    return event.Records[0].cf.request
};

// For CloudFront origin-response events
export const responseHandler = async event => {
    await sendTraceToLevo(event);
    return event.Records[0].cf.response
};
