const orgId = process.env.LEVO_ORG_ID
const tracesEndpoint = process.env.LEVO_TRACES_ENDPOINT ?? "https://collector.levo.ai"

const dispatchEvent = async cf => {
    await fetch(`${tracesEndpoint}/v1/cloudfront-event`, {
        method: "POST",
        headers: {
            'content-type': 'application/json',
            'x-levo-organization-id': orgId
        },
        body: JSON.stringify(cf)
    })
}

const sendTraceRequestToLevo = async event => {
    try {
        const cf = event.Records[0].cf
        const reqContentType = cf.request.headers["content-type"]?.[0]?.value
        if (cf.request.method !== "GET" && !reqContentType?.includes("json")) {
            return
        }
        await dispatchEvent(cf)
    }
    catch (e) {
        console.error(e)
    }
}

const sendTraceResponseToLevo = async event => {
    try {
        const cf = event.Records[0].cf
        const resContentType = cf.response.headers["content-type"]?.[0]?.value
        if (!resContentType?.includes("json")) {
            return
        }
        await dispatchEvent(cf)
    }
    catch (e) {
        console.error(e)
    }
}

// For CloudFront origin-request events
export const requestHandler = async event => {
    await sendTraceRequestToLevo(event);
    return event.Records[0].cf.request
};

// For CloudFront origin-response events
export const responseHandler = async event => {
    await sendTraceResponseToLevo(event);
    return event.Records[0].cf.response
};
