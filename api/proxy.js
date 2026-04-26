export const config = {
  runtime: 'edge',
};

export default async function handler(request) {
  const url = new URL(request.url);
  
  const targetUrl = "https://your-target-server.com" + url.pathname + url.search;

  const modifiedRequest = new Request(targetUrl, {
    headers: request.headers,
    method: request.method,
    body: request.body,
    redirect: 'follow'
  });

  return fetch(modifiedRequest);
}
